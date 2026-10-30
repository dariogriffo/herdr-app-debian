![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/herdr-app-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/herdr-app-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/herdr-app-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/herdr-app-debian)

<h1>
   <p align="center">
     <a href="https://herdr.dev"><img src="https://github.com/dariogriffo/herdr-app-debian/blob/main/herdr-app.svg" alt="Herdr Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/herdr-app-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>herdr-app for Debian
   </p>
</h1>
<p align="center">
 A desktop app for terminals and coding agents.
</p>

# herdr-app for Debian

This repository contains build scripts to produce the _unofficial_ Debian and
Ubuntu packages (.deb) for [Herdr](https://github.com/herdrdev/herdr-app/), the
desktop app, hosted at [deb.griffo.io](https://deb.griffo.io)

The package and the command are both called `herdr-app`. It is a desktop (GPU,
Vulkan) application: launch Herdr from the application menu, or run
`herdr-app`. It is not the same program as the `herdr` package (the terminal
agent multiplexer).

Currently supported distros are:
- Debian Bookworm (v12), Trixie (v13), Forky (v14), Sid
- Ubuntu Jammy (22.04), Noble (24.04), Questing (25.10), Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - All distributions

Upstream builds both architectures against glibc 2.35, so they run on every
suite above. Upstream only publishes Linux builds for these two architectures,
so there are no i386, armhf, armel or riscv64 packages.

One package per architecture is built and shared by every suite
(`herdr-app_<version>-<build>~griffo_<arch>.deb`). It repackages upstream's
own Linux build from [releases.herdr.dev](https://releases.herdr.dev) (the
GitHub repository has tags but no release assets): the `herdr-app` binary in
`/usr/bin`, its icon, a desktop entry matching the one upstream's installer
writes, and the license and third-party notices. The dependencies are declared
so they resolve on every supported suite, including `curl` and `xdg-utils`,
which Herdr calls to check for herdr-core releases and to open links. A Vulkan driver
(`mesa-vulkan-drivers`), a sound player for the alert sounds (`paplay` or
`pw-play`) and `openssh-client` are recommended.

The binary is installed without its icon beside it, which is how Herdr tells
an installer-managed copy from any other: its self-updater stays off and
updates come through apt.

Terminals run in herdr-core, a separate upstream project packaged as
[herdr-core](https://github.com/dariogriffo/herdr-core-debian). `herdr-app`
depends on it, versioned with the oldest core the release accepts (upstream's
`distribution/core-version`, read at build time), so apt always installs a
core this Herdr can use and keeps both updated. Herdr may still offer an
"update herdr-core" button when upstream is ahead of the mirror; it cannot
replace `/usr/bin/herdr-core`, so wait for `sudo apt upgrade`. If you let an
earlier Herdr install a core into `~/.local/bin`, delete
`~/.local/bin/herdr-core` and `~/.local/bin/hc` so the packaged one is used.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the Herdr source code, see
[herdr-app](https://github.com/herdrdev/herdr-app/).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-herdr-app-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-herdr-app-in-ubuntu.html)

### The Debian way

> ⚠️ **apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/herdr-app-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y herdr-app
```

### Manual Installation

1. Download the .deb package for your architecture from
   the [Releases](https://github.com/dariogriffo/herdr-app-debian/releases) page.
2. Install it with apt, so the dependencies are pulled in.

```sh
sudo apt install ./<filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <herdr_app_version> <build_version> <architecture>
# Example: ./build.sh 0.1.9 1 arm64
```

### Build for all architectures
```sh
./build.sh <herdr_app_version> <build_version> all
# Example: ./build.sh 0.1.9 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to Herdr. This repo is only for _unofficial_ Debian packaging.
