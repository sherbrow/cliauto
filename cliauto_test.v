module cliauto

import cli

fn test_autocomplete() {
	cmd_depth := cli.Command{
		name:     'root'
		commands: [cli.Command{
			name:     'act1'
			commands: []
		}, cli.Command{
			name:     'act2'
			commands: []
		}, cli.Command{
			name:     'foo'
			commands: [cli.Command{
				name:     'sub1'
				commands: []
			}, cli.Command{
				name:     'sub2'
				commands: []
			}, cli.Command{
				name:     'bar'
				commands: []
			}]
		}]
	}
	assert autocomplete(cmd_depth, 'ac') == ['act1', 'act2']
}
