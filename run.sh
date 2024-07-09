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
    tmux send-keys "flutter run" C-m
    sleep 2
    tmux send-keys "1" C-m # This line selects the device number. Change this accordingly for the device you want
done

# Attach to the session
tmux attach-session