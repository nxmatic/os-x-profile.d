ifndef launch-agents-mk

this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath$(this-dir)/..)

launch-agents-mk := $(this-mk)

include tmuxinator.mk

define nl :=

endef

environment~%: label = $(USER).environment
environment~%: respawn = false
environment~%: program = /bin/sh
environment~%: arguments  = -x -e -c
environment~%: commands  =
environment~%: commands += launchctl setenv PATH $(PATH);
environment~%: commands += launchctl setenv XDG_CACHE_HOME /Users/$(USER)/Library/Caches;
environment~%: commands += launchctl setenv XDG_STATE_HOME /Users/$(USER)/Library/States;
environment~%: commands += launchctl setenv XDG_CONFIG_HOME /Users/$(USER)/Library/Preferences;
environment~%: commands += launchctl setenv XDG_RUNTIME_DIR /Users/$(USER)/Library/Runs;
environment~%: commands += launchctl setenv XDG_DATA_HOME /Users/$(USER)/Library/ApplicationSupport;

home.tmux~%: label = $(USER).home.tmux
home.tmux~%: program = /usr/local/bin/tmuxinator
home.tmux~%: arguments = start home

home.tmux~bootstrap: $(HOME)/.tmuxinator/home.yml
home.tmux~bootstrap: $(HOME)/.termcap

home.emacs~%: label = $(USER).home.emacs
home.emacs~%: program = /usr/local/bin/emacs
home.emacs~%: arguments = --bg-daemon=note

work.tmux~%: label = $(USER).work.tmux
work.tmux~%: program = /usr/local/bin/tmuxinator
work.tmux~%: arguments = start work

work.tmux~bootstrap: $(HOME)/.tmuxinator/work.yml
work.tmux~bootstrap: $(HOME)/.termcap

work.emacs~%: label = $(USER).work.emacs
work.emacs~%: program = /usr/local/bin/emacs
work.emacs~%: arguments = --bg-daemon=code

launch-agents-dir := $(HOME)/Library/LaunchAgents

launch-agents := environment home.tmux work.tmux work.emacs home.emacs

define launch-agents-targets-variable =
launch-agents-$(target)-targets := $(foreach agent,$(launch-agents),$(agent)~$(target))
endef


$(foreach target,check bootstrap bootout list,$(eval $(call launch-agents-targets-variable)))

launch-agents-domain := gui/$(shell id -u)

define launch-agents-rules =
$(launch-agents-check-targets): %~check: $(launch-agents-dir)/$(USER).%.plist
	plutil $$(<)
.PHONY: $(launch-agents-check-targets)

bootstrap: $(launch-agents-bootstrap-targets)

%~bootstrap: uid=$(id -u)

$(launch-agents-bootstrap-targets): %~bootstrap : $(launch-agents-dir)/$(USER).%.plist
	launchctl bootstrap $(launch-agents-domain) $$(<)
.PHONY: $(launch-agents-bootstrap-targets)

bootout: $(launch-agents-bootout-targets)


$(launch-agents-bootout-targets): %~bootout: $(launch-agents-dir)/$(USER).%.plist
	-launchctl bootout $(launch-agents-domain) $$(<)
	rm -f $$(<)
.PHONY: $(launch-agents-bootout-targets)

$(launch-agents-list-targets): %~list: $(launch-agents-dir)/$(USER).%.plist
	launchctl list $$(*:-=.)
.PHONY: $(launch-agents-list-targets)
endef

$(eval $(call launch-agents-rules))

$(launch-agents-dir)/$(USER).%.plist: respawn=true

$(launch-agents-dir)/$(USER).%.plist:
	@: $(call check-variable-defined,label program arguments)
	$(file >$(@),$(launch-agents-template))

define launch-agents-template =
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- tmux/byobu new-session new-session -d -s login -m emacsclient --tty-->
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>$(label)</string>
    <key>RunAtBootstrap</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
      <key>SuccessfulExit</key>
      <$(respawn)/>
      <key>Crashed</key>
      <true/>
      <key>OtherJobEnabled</key>
      <string>$(USER).environment</string>
    </dict>
    <key>ProcessType</key>
    <string>Background</string>
    <key>EnableGlobbing</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>$(HOME)</string>
    <key>Program</key>
    <string>$(program)</string>
    <key>ProgramArguments</key>
    <array>
      <string>$(notdir $(program))</string>
$(foreach string,$(arguments),$(launch-agents-string-template))
$(let string,$(command),$(launch-agents-string-template))
    </array>
    <key>StandardOutPath</key>
    <string>$(HOME)/.local/var/log/$(label).stdout</string>
    <key>StandardErrorPath</key>
    <string>$(HOME)/.local/var/log/$(label).stderr</string>
  </dict>
</plist>
endef

define launch-agents-string-template =
    <string>$(string)</string>

endef
endif
