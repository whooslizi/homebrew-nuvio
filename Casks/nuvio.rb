cask "nuvio" do
  version "0.1.37-alpha"

  on_arm do
    sha256 "9835d5a800672ffeb7be759f358d1a190bcaf56545ccdaed502016da243c87de"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-arm64-0.1.37-alpha.dmg"
  end
  on_intel do
    sha256 "1ded3b9c87d167806889f290dd471f66c73049465cb36e900be6b90a529f3bb8"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-x86_64-0.1.37-alpha.dmg"
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
