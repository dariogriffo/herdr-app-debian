<div align="center">

# Herdr

**A desktop app for terminals and coding agents.**

![GitHub License](https://img.shields.io/github/license/herdrdev/herdr-app)

</div>

## About

Herdr keeps terminal work in **spaces**, usually one per repository. Each
space has tabs, and tabs split into panes holding terminals or mod panels.
The agents sidebar brings the coding agents from every space into one list and
shows which are working, blocked waiting for you, or done.

Closing the window leaves the terminals running. They run in herdr-core,
which apt installs with this package (the `herdr-core` package) and keeps
updated with it.
Add SSH machines from Settings, Machines, and a space's terminals run on that
machine, still running when your laptop sleeps.

**The command is `herdr-app`.** Launch Herdr from your desktop's application
menu or run `herdr-app` from a terminal. It needs a desktop session (X11 or
Wayland) and a working Vulkan driver (`mesa-vulkan-drivers` is recommended).
The app's own self-updater is off in this package; updates come through apt.

Ctrl+Shift+P opens the command palette. Layouts and mods (small JavaScript
programs that draw the panels, menus and dialogs) live in
`~/.config/herdr-app`.

**[Read the documentation](https://github.com/herdrdev/herdr-app)**
