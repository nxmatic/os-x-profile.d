ifndef launch-agents-mk

this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath$(this-dir)/..)

launch-agents-mk := $(this-mk)

include tmuxinator.mk

environment~%: label = $(USER).environment
environment~%: program = /bin/sh
environment~%: arguments = launchctl setenv PATH $(PATH)

home.tmux~%: label = $(USER).tmux.home
home.tmux~%: program = /usr/local/bin/tmuxinator
home.tmux~%: arguments = start home

home.tmux~load: $(HOME)/.tmuxinator/home.yml
home.tmux~load: $(HOME)/.termcap

work.tmux~%: label = $(USER).tmux.work
work.tmux~%: program = /usr/local/bin/tmuxinator
work.tmux~%: arguments = start work

work.tmux~load: $(HOME)/.tmuxinator/work.yml
home.tmux~load: $(HOME)/.termcap

code.emacs~%: label = $(USER).emacs.code
code.emacs~%: program = /usr/local/bin/emacs
code.emacs~%: arguments = --bg-daemon=code

note.emacs~%: label = $(USER).emacs.note
note.emacs~%: program = /usr/local/bin/emacs
note.emacs~%: arguments = --bg-daemon=note

launch-agents-dir := $(HOME)/Library/LaunchAgents

launch-agents := environment home.tmux work.tmux code.emacs note.emacs

define launch-agents-targets-variable =
launch-agents-$(target)-targets := $(foreach agent,$(launch-agents),$(agent)~$(target))
endef

$(foreach target,check load unload list,$(eval $(call launch-agents-targets-variable)))

define launch-agents-rules =
(launch-agents-dir)/%: %
	cp $$(<) $$(@)

$(launch-agents-check-targets): %~check: $(USER).%.plist
	plutil $$(<)
.PHONY: $(launch-agents-check-targets)

install: $(launch-agents-load-targets)
$(launch-agents-load-targets): %~load : $(launch-agents-dir)/$(USER).%.plist
	launchctl load -w $$(<)
.PHONY: $(launch-agents-load-targets)

uninstall: $(launch-agents-unload-targets)
$(launch-agents-unload-targets): %~unload: $(launch-agents-dir)/$(USER).%.plist
	launchctl unload -w $$(<)
	rm -f $$(<)
.PHONY: $(launch-agents-unload-targets)

$(launch-agents-list-targets): %~list: $(launch-agents-dir)/$(USER).%.plist
	launchctl list $$(*:-=.)
.PHONY: $(launch-agents-list-targets)
endef

$(eval $(call launch-agents-rules))

%.plist:
	@: $(call check-variable-defined,label program arguments)
	$(file >$(@),$(launch-agents-template))

define environment-template =
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- tmux/byobu new-session new-session -d -s login -m emacsclient --tty-->
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>$(USER).environment</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
      <key>SuccessfulExit</key>
      <false/>
      <key>Crashed</key>
      <true/>
    </dict>
    <key>ProcessType</key>
    <string>Standard</string>
    <key>EnableGlobbing</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>/Users/$(USER)</string>
    <key>Program</key>
    <string>/bin/sh</string>
    <key>ProgramArguments</key>
    <array>
      <string>sh</string>
      <string>-c</string>
      <string>launchctl launchctl setenv PATH $(PATH)</string>
    </array>
    <key>StandardOutPath</key>
    <string>/Users/$(USER)/.local/var/log/$(USER).environment.out</string>
    <key>StandardErrorPath</key>
    <string>/Users/$(USER)/.local/var/log/$(USER).environment.err</string>
  </dict>
</plist>
endef

define launch-agents-template =
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- tmux/byobu new-session new-session -d -s login -m emacsclient --tty-->
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>$(label)</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
      <key>SuccessfulExit</key>
      <false/>
      <key>Crashed</key>
      <true/>
      <key>OtherJobEnabled</key>
      <string>nuxeo.environment</string>
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
      $(foreach word,$(arguments),<string>$(word)</string>)
    </array>
    <key>StandardOutPath</key>
    <string>$(HOME)/.local/var/log/$(label).stdout</string>
    <key>StandardErrorPath</key>
    <string>$(HOME)/.local/var/log/$(label).stderr</string>
  </dict>
</plist>
endef


endif
