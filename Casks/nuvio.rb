cask "nuvio" do
  version "0.1.38-alpha"

  on_arm do
    sha256 "a456810871b957104164315cf30806b59fa61b220428f26afabea552f9d113d8"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-arm64-0.1.38-alpha.dmg"
  end
  on_intel do
    sha256 "ee28136d68cdc27f796e16b1251d830eb847008f4a8622ea0fc833e794a29baa"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-x86_64-0.1.38-alpha.dmg"
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
