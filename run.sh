#!/bin/bash

# Create a new session
tmux new-session -d

# Split the window into a 2x2 grid
tmux split-window -h
tmux split-window -v

tmux select-pane -t 0
tmux split-window -v

for i in {0..3}; do
    tmux select-pane -t $i
    tmux send-keys "flutter run -d linux" C-m
    sleep 5
done

# Attach to the session
tmux attach-session