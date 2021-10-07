ifndef terminfo-mk

this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

terminfo-mk:=$(this-mk)

xterm-direct~install: xterm-%~install: terminfo.src
	tic -s -x -o ~/.terminfo $(<)
.PHONY: xterm-direct~install

install: xterm-direct~install

terminfo.src:
	$(file >$(@),$(xterm-24bit-template))

define xterm-24bit-template :=
# Use colon separators.
xterm-24bit|xterm-24bits|xterm with 24-bit direct color mode,
  use=xterm-256color,
  setb24=\E[48:2:%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm,
  setf24=\E[38:2:%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm,
tmux-24bit|tmux with 24-bit direct color mode,
  use=xterm-256color, use=tmux,
endef

endif
