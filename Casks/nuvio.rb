cask "nuvio" do
  version "0.1.36-alpha"

  on_arm do
    sha256 "8da41505125e1c164024aa57a89186318a2a8ca6af725983bd023c805fcf2a31"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-arm64-0.1.36-alpha.dmg"
  end
  on_intel do
    sha256 "16f6a5a6fb7377778cd703cc7de955aa4ee7ba653448f4b4d1483b45a1af803f"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-x86_64-0.1.36-alpha.dmg"
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

  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Nuvio.app"], must_succeed: false
  end
end
