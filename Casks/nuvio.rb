cask "nuvio" do
  version "0.1.34-alpha"

  on_arm do
    sha256 "497856e825f4efe1a27d286de7925dc5b7abbd7644ec6b0ae2abdf6df4e75e94"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-arm64-0.1.34-alpha.dmg"
  end
  on_intel do
    sha256 "058e4657d5b08af08ca54e93d6aae0109c9af601251e6d29a35c688d16dbc517"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-x86_64-0.1.34-alpha.dmg"
  end

  name "Nuvio"
  desc "Nuvio Desktop client"
  homepage "https://github.com/NuvioMedia/NuvioDesktop"

  livecheck do
    url :url
    strategy :github_releases
  end

  app "Nuvio.app"

  uninstall quit: "com.nuvio.media.desktop"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Nuvio.app"]
  end
end
