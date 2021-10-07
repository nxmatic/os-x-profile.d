ifndef tmuxinator-mk

this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

tmuxinator-mk := $(this-mk)


$(HOME)/.tmuxinator:
	mkdir $(@)

$(HOME)/.tmuxinator/%.yml: name = $(*)

$(HOME)/.tmuxinator/%.yml: | $(HOME)/.tmuxinator
	$(file >$(HOME)/.tmuxinator/$(name).yml,$(tmuxinator-project-template))

define tmuxinator-project-template =
name: $(name)
root: ~/
# Optional tmux socket
socket_name: $(name)

# Note that the pre and post options have been deprecated and will be replaced by
# project hooks.

# Project hooks

# Runs on project start, always
# on_project_start: command

# Run on project start, the first time
# on_project_first_start: command

# Run on project start, after the first time
# on_project_restart: command

# Run on project exit ( detaching from tmux session )
# on_project_exit: command

# Run on project stop
# on_project_stop: command

# Runs in each window and pane before window/pane specific commands. Useful for setting up interpreter versions.
# pre_window: rbenv shell 2.0.0-p247

# Pass command line options to tmux. Useful for specifying a different tmux.conf.
# tmux_options: -f ~/.tmux.mac.conf

# Change the command to call tmux.  This can be used by derivatives/wrappers like byobu.
tmux_command: byobu

# Specifies (by name or index) which window will be selected on project startup. If not set, the first window is used.
startup_window: shell

# Specifies (by index) which pane of the specified window will be selected on project startup. If not set, the first pane is used.
# startup_pane: 1

# Controls whether the tmux session should be attached to automatically. Defaults to true.
attach: false

windows:
  - shell: 
endef

endif

