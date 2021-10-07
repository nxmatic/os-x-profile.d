this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

SHELL := fish

#: install in the home
install:

# run required setup commands
setup:

#: install in the home
uninstall:

$(HOME)/.termcap: termcap
	cp termcap $(HOME)/.termcap

install: $(HOME)/.termcap

include $(this-dir)/launch-agents.mk
include $(this-dir)/tmuxinator.mk
include $(this-dir)/fish.mk

define check-variable-defined =
$(strip $(foreach 1,$1,
        $(call __check-variable-defined,$1,$(strip $(value 2)))))
endef

define __check-variable-defined =
$(info checking $(1)='$(value $(1))')
$(if $(value $1),,
     $(error Undefined variable '$1'$(if $2, ($2))$(if $(value @),
             required by target '$@')))
endef
