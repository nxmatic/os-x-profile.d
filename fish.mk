ifndef fish-mk

this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

fish-mk:=$(this-mk)

fish~setup:
	set -x -U EDITOR 'emacsclient --tty'
	set -x -U fish_term24bit 1
	set -x -U TERM xterm-direct
endif
