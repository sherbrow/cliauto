module cliauto

import cli
import os

pub fn command() cli.Command {
	return cli.Command{
		name:    '_autocomplete'
		execute: fn (cmd cli.Command) ! {
			line := cmd.args[0] or { ' ' }

			for suggest in autocomplete(cmd.parent, line) {
				println(suggest)
			}
		}
		defaults: struct {
			help:    false
			man:     false
			version: false
		}
	}
}

pub fn autocomplete(cmd cli.Command, line string) []string {
	mut suggestions := []string{}

	raw_args := line.split(' ').filter(it.len > 0)
	pos := if line.ends_with(' ') { raw_args.len } else { raw_args.len - 1 }

	mut parent_flags := []cli.Flag{}
	mut cmd_it := cmd
	depth: for depth in 0 .. raw_args.len {
		if pos == depth {
			break depth
		}

		for subcmd in cmd_it.commands {
			if subcmd.name == raw_args[depth] {
				parent_flags << cmd_it.flags.filter(it.global)
				cmd_it = subcmd
				continue depth
			}
		}
	}

	cur := raw_args[pos] or { '' }

	mut count_cmd := 0

	for subcmd in cmd_it.commands {
		if subcmd.name.starts_with('_') && !cur.starts_with('_') {
			continue
		}
		if cur.len == 0 || subcmd.name.contains(cur) {
			suggestions << '${subcmd.name}'
			count_cmd++
			continue
		}
	}

	if cur.len > 0 || count_cmd == 0 {
		for flag in cmd_it.flags {
			if suggest_flag(cur, flag) {
				suggestions << '--${flag.name}'
			}
		}
		for flag in parent_flags {
			if suggest_flag(cur, flag) {
				suggestions << '--${flag.name}'
			}
		}
	}

	return suggestions
}

fn suggest_flag(cur string, flag cli.Flag) bool {
	cur_name := if cur.starts_with('--') {
		cur[2..]
	} else if cur.starts_with('-') {
		cur[1..]
	} else {
		cur
	}
	if cur.starts_with('-') || flag.name.contains(cur_name)
		|| (flag.abbrev.len > 0 && flag.abbrev.contains(cur_name)) {
		return true
	}
	return false
}

pub fn command_bash() cli.Command {
	return cli.Command{
		name:    '_autocomplete_bash'
		execute: fn (cmd cli.Command) ! {
			fq_bin := os.real_path(os.args[0])
			name := cmd.parent.name
			bin_name := cmd.parent.name
			bash := '#!/bin/bash
_${name}_autocomplete() {
    local cur prev

    # The current word being completed
    cur="\${COMP_WORDS[COMP_CWORD]}"

    # The previous word
    prev="\${COMP_WORDS[COMP_CWORD - 1]}"

    local suggestions=$(${fq_bin} _autocomplete "\${COMP_LINE}")
    # local suggestions=$(v run ${fq_bin}.v _autocomplete "\${COMP_LINE}")

    # Generate the possible completions
    COMPREPLY=( $(compgen -W "\${suggestions}" -- "\${cur}") )
}

complete -F _${name}_autocomplete ${bin_name}'

			println(bash)
			return
		}
	}
}
