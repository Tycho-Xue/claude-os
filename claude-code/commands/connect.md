Connect to a remote VM and operate on it. Arguments: $ARGUMENTS (SSH host alias)

1. Establish ControlMaster persistent connection: `ssh -fN $ARGUMENTS` (skip if already connected)
2. Verify connection: `ssh -O check $ARGUMENTS`
3. Confirm VM identity: `ssh $ARGUMENTS "hostname && whoami && pwd"`
4. Report: Connected to {host}, subsequent commands via `ssh {host} "cmd"`

Working mode after connection:
- Execute commands: `ssh {host} "command"`
- Read files: `ssh {host} "cat -n /path/to/file"`
- Write files: via ssh heredoc
- Long tasks: `ssh {host} "tmux new -d -s {name} 'command'"` to protect processes
- Check output: `ssh {host} "tmux capture-pane -t {name} -p -S -50"`
