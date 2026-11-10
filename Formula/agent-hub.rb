class AgentHub < Formula
  desc "Menu bar hub for the AI agents on your Mac: sessions, quota, plugins"
  homepage "https://github.com/KenseiTheOne/agent-hub"
  url "https://github.com/KenseiTheOne/agent-hub/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "59c3eb88aaaf8cf019ccd7f43adc04b71c640175ecceffadd0b39c0f7404d695"
  license "MIT"
  head "https://github.com/KenseiTheOne/agent-hub.git", branch: "main"

  depends_on macos: :tahoe
  depends_on "node"

  # libexec is the release source tree that `agenthub setup` copies into the hub's own install and builds there:
  # brew must not rewrite the `#!/usr/bin/env node` shebangs in it (the hub runs them with its launchd job's node).
  skip_clean "libexec"

  def install
    # Everything the hub needs to build itself (daemon, app sources, scripts, plugins, hook, bridge).
    # The screenshots in docs/ and the agents' CLAUDE.md are not needed; the docs themselves are small and stay.
    libexec.install Dir["*"] - %w[docs CLAUDE.md]
    (libexec/"docs").install Dir["docs/*.md"]
    # The commit — the hub shows it under "Details". Only a `head` build has .git; the release tarball has none,
    # and the hub works without the file.
    (libexec/"COMMIT").write "#{Utils.git_head(buildpath)}\n" if (buildpath/".git").exist?

    # The CLI. NODE_OPTIONS is dropped: preloads in it (e.g. from a terminal multiplexer) break the hub's
    # child node processes.
    (bin/"agenthub").write <<~SH
      #!/bin/bash
      exec /usr/bin/env -u NODE_OPTIONS "#{formula_opt_bin("node")}/node" "#{opt_libexec}/daemon/bin/agenthub" "$@"
    SH
    chmod 0755, bin/"agenthub"
  end

  def caveats
    <<~EOS
      Finish the install with one command in your own Terminal:
        agenthub setup
      It builds the menu bar app from this package (swift, 2-5 min), pins the build, adds a
      launchd job and starts the hub. It needs the Command Line Tools with the macOS 26 SDK
      (xcode-select --install) and asks for confirmation.

      Updates: brew upgrade agent-hub, then press "Update" in the Agent Hub menu — the hub
      builds the new version, test-runs it and rolls back by itself if it fails.

      Uninstall, in this order (brew does not know about the hub's launchd job and data):
        agenthub uninstall --apply
        brew uninstall agent-hub
    EOS
  end

  test do
    hub_version = (opt_libexec/"VERSION").read.strip
    assert_match "Agent Hub #{hub_version} (Homebrew package)", shell_output("#{bin}/agenthub version")
    assert_match "\"version\":\"#{hub_version}\"", shell_output("#{bin}/agenthub version --json")
  end
end
