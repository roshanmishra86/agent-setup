#!/usr/bin/env bash

SESSION_NAME="{{PROJECT_NAME}}"
EDITOR="${EDITOR:-vim}"

# Ensure tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "tmux could not be found. Please install it."
    exit 1
fi

tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
    # Create the session with the first window named 'editor'
    tmux new-session -d -s $SESSION_NAME -n "editor"

    # Send the editor command
    tmux send-keys -t $SESSION_NAME "$EDITOR ." C-m

    # Create 'server' window
    tmux new-window -t $SESSION_NAME -n "server"
    tmux send-keys -t $SESSION_NAME "just dev" C-m

    # Create 'test' window
    tmux new-window -t $SESSION_NAME -n "test"
    tmux send-keys -t $SESSION_NAME "just test" C-m

    # Select the editor window
    tmux select-window -t $SESSION_NAME:1
fi

# Attach to the session
tmux attach -t $SESSION_NAME
