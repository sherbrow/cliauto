module cliauto

import cli

fn test_autocomplete() {
	cmd_depth := cli.Command{
		name:     'root'
		commands: [cli.Command{
			name: 'act1'
		}, cli.Command{
			name: 'act2'
		}, cli.Command{
			name:     'foo'
			commands: [
				cli.Command{
					name: 'sub1'
				},
				cli.Command{
					name: 'sub2'
				},
				cli.Command{
					name: 'bar'
				},
			]
		}]
	}
	assert autocomplete(cmd_depth, 'oth') == []
	assert autocomplete(cmd_depth, 'act') == ['act1', 'act2']
	assert autocomplete(cmd_depth, 'foo') == ['foo']
	assert autocomplete(cmd_depth, 'foo ') == ['sub1', 'sub2', 'bar']
	assert autocomplete(cmd_depth, 'foo ba') == ['bar']

	// Not standard bash compliant
	assert autocomplete(cmd_depth, 'oo') == ['foo']
}
