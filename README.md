# KenseiTheOne Homebrew tap

Homebrew formulae for KenseiTheOne's tools.

## Agent Hub

[Agent Hub](https://github.com/KenseiTheOne/agent-hub) is a macOS menu bar app that shows the status of every AI agent
on your Mac and gives you one place to act on them.

Requirements: macOS 26 or later, the Command Line Tools with the macOS 26 SDK (`xcode-select --install`). Homebrew
installs Node.js itself.

```sh
brew install KenseiTheOne/tap/agent-hub
agenthub setup
```

`brew install` puts the release source tree and the `agenthub` command in place; `agenthub setup` (in your own
Terminal — it asks for confirmation) builds the menu bar app with swift (2–5 min), pins the build, adds a launchd job
and starts the hub.

### Updating

```sh
brew upgrade agent-hub
```

Then press **Update** in the Agent Hub menu (or Settings → Hub updates). The hub builds the new version next to the
running one, test-runs it and rolls back by itself if it fails. A Homebrew-installed hub does not look at git tags:
new versions come only from `brew upgrade`.

### Uninstalling

In this order — Homebrew does not know about the hub's launchd job and data:

```sh
agenthub uninstall --apply     # stops the hub, removes the launchd job and the installed versions
brew uninstall agent-hub
```

`agenthub uninstall --apply --purge` also removes settings, the journal and plugin data.

### Private repository

While the Agent Hub repository is private, Homebrew fetches it with git and your own credentials (the git keychain),
so you need read access to it. When the repository becomes public, the formula switches to the release tarball.
