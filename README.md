#  MuteSpotifyAds

[![size](https://img.shields.io/badge/size-10.6%20MB-brightgreen.svg)](https://github.com/MikeWLloyd/MuteSpotifyAds/releases)
[![download size](https://img.shields.io/badge/download%20size-3.3%20MB-brightgreen.svg)](https://github.com/MikeWLloyd/MuteSpotifyAds/releases)
[![macOS version support](https://img.shields.io/badge/macOS-11%2B-brightgreen.svg)](https://github.com/MikeWLloyd/MuteSpotifyAds/releases)

<p align="center"><img src="https://i.imgur.com/n12KjSw.png" height="200"></p>

This is a native and efficient macOS application automatically silencing ads on the Spotify desktop app.

This application is very CPU and power efficient, since it only checks for an ad when a new song gets played.

This application is not in any way affiliated with Spotify.

## Project origin

This repository is a community-maintained fork of the original MuteSpotifyAds project created by Simon Meusel.

- Original upstream repository: https://github.com/simonmeusel/MuteSpotifyAds
- This fork: https://github.com/MikeWLloyd/MuteSpotifyAds

The upstream project was archived, so this fork continues compatibility updates, build fixes, and release distribution for current macOS versions.

## Features

* Mute ads
* Endless private session
* Song log file
* Restart spotify to skip ads
* Auto-start Spotify with MuteSpotifyAds or run MuteSpotifyAds at startup

## Usage

Instead of running Spotify directly, start this application. It will automatically start Spotify. Furthermore it will mute any ads it sees. When you close Spotify this program will also terminate, and thus it no longer has any effect on your battery or CPU.

As of version `1.5.0` you can also enable an option to automatically skip ads by restarting Spotify. Click the `☀︎` in the status bar of your Mac (at the top of your screen), and then click `◎ Restart to skip ads`.

## Installation

Homebrew note: there is currently no official `mutespotifyads` formula/cask in Homebrew core/cask.

This repository now includes a custom tap cask in `Casks/mutespotifyads.rb`. Users can install from this tap:

```
brew tap MikeWLloyd/mutespotifyads
brew install --cask mutespotifyads
```

> The tap is hosted at https://github.com/MikeWLloyd/homebrew-mutespotifyads

For maintainers: this cask installs from the latest GitHub release asset at:

```
https://github.com/MikeWLloyd/MuteSpotifyAds/releases/latest/download/MuteSpotifyAds.app.tar.gz
```

To keep Homebrew installs working, publish each release with an asset named `MuteSpotifyAds.app.tar.gz`.

Example packaging command after a Release build:

```
./scripts/package_release.sh
```

Release checklist:

1. Run `./scripts/package_release.sh`
2. Create a GitHub Release tag (for example `v1.12.0`)
3. Upload assets from `dist/`:
	- `MuteSpotifyAds.app.tar.gz` (used by Homebrew cask)
	- `MuteSpotifyAds-source.tar.gz` (GPL source archive)
	- `checksums.txt`
4. Verify this URL resolves after publish:
	- `https://github.com/MikeWLloyd/MuteSpotifyAds/releases/latest/download/MuteSpotifyAds.app.tar.gz`

Manual installation:

1. Download this application from the [releases page](https://github.com/MikeWLloyd/MuteSpotifyAds/releases/)
2. Move it to your Applications folder
3. Run it using **Right Click -> Open** on first launch.
4. If the app is unsigned/not notarized, macOS may show a security prompt. This is expected for community builds.
5. If you like the app, leave a [star](https://github.com/MikeWLloyd/MuteSpotifyAds/stargazers)!

This project currently targets modern macOS (`11+`).

To uninstall the application, you can simply trash `MuteSpotifyAds.app`.

### Troubleshooting

If the application does not work, follow the steps for enabling an endless private Spotify session.

## Endless private Spotify session

You can also use this application to enforce an endless private session. **This requires you to grant this application additional privileges**. To enable them, do the following:

1. Go to `System Preferences` → `Security & Privacy` → `Privacy` tab → `Accessibility` → Enable the check mark next to this application. 
2. Go to `System Preferences` → `Security & Privacy` → `Privacy` tab → `Automation` → Enable the check marks next to this application (for `Spotify` and `System Events`).

To enable/disable the endless private session, click the `☀︎` in the status bar of your mac (at the top of your screen), and then click `∞ Private session`. This will ensure that the Spotify private session is enabled whenever the current song changes.

The state of the endless private session will be saved and restored on program restart.

This application enables the private session using [the following apple script](https://stackoverflow.com/a/51068836/6286431):

```
tell application "System Events" to tell process "Spotify"
tell menu bar item 2 of menu bar 1 -- AppleScript indexes are 1-based
tell menu item "Private Session" of menu 1
set isChecked to value of attribute "AXMenuItemMarkChar" is "✓"
if not isChecked then click it
end tell
end tell
end tell
```

## How is it so efficient?

Whenever the track changes, the following file will get modified by Spotify:

```
# When a song plays next
~/Library/Application Support/Spotify/Users/($SPOTIFY_USER_NAME)-user/recently_played.bnk
# When a ad plays next
~/Library/Application Support/Spotify/Users/($SPOTIFY_USER_NAME)-user/ad-state-storage.bnk
```

This application simply watches for a change at those files and then runs the following apple script, to detect ads:

```
tell application "Spotify" to (get spotify url of current track)
```

If the Spotify URL starts with `spotify:ad`, the volume will be set to `0`. Once a normal track plays, your initial volume will be restored (if you haven't already enabled sound man).

To set and get the volume, the following apple script is used:

```
tell application "Spotify" to (get sound volume)
tell application "Spotify" to set sound volume to ($VOLUME)
```

Using those techniques, it uses only `0.4%` CPU when the track changes (rate: 5 seconds), and `0%` in idle. It has a energy impact of less than one tenth of Spotify when the track changes, and a energy impact of `0.0 - 0.1` in idle.

## Contributing

If you want to contribute, feel free to do so. If you need help, just open a issue.

You can also contribute by adding support for another language. To do so, clone the repo, and then follow the instruction from [this image](https://cdn-images-1.medium.com/max/1791/1*K2hxQs-c2Q8aZkgjCl6q4Q.png). Then add the translations and open a pull request.

Currently supported languages are:

* Chinese
* English
* German
* Italian
* Spanish
* Turkish

## Thanks

Thanks to [Carlo Federico Vescovo](https://github.com/cfvescovo) for the restart-spotify feature, the auto-start option and help with the documentation!
Thanks to [Artem Gordinsky](https://github.com/ArtemGordinsky/) and the [other contributors](https://github.com/ArtemGordinsky/Spotifree#thanks) of [Spotifree](https://github.com/ArtemGordinsky/Spotifree)!
Thanks to [vadian](https://stackoverflow.com/users/5044042/vadian) for the [help](https://stackoverflow.com/questions/51068410/osx-tick-menu-bar-checkbox/51068836#51068836)!

## License

[GNU General Public License v3.0](https://github.com/MikeWLloyd/MuteSpotifyAds/blob/master/LICENSE)

Copyright (C) 2018 Simon Meusel
Copyright (C) 2026 MikeWLloyd contributors

### GPLv3 compliance notes for this fork

- This fork preserves the original GPLv3 licensing and attribution.
- A fork attribution/change notice is provided in `NOTICE`.
- If you redistribute this app (including binaries), you must also provide the corresponding source code for the distributed version under GPLv3 terms.
- Include the GPLv3 license text (`LICENSE`) and preserve copyright/attribution notices in source and releases.
