cask "nuvio" do
  version "0.1.35-alpha"

  on_arm do
    sha256 "927b9a29da9dd3215fecbb4108e7a91731e3583c9f8a4056d5635ba04a5db778"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-arm64-0.1.35-alpha.dmg"
  end
  on_intel do
    sha256 "6e652baca94bf7181a93d25fee977940cc350c92521819889f0b024341cd851e"

    url "https://github.com/NuvioMedia/NuvioDesktop/releases/download/#{version}/Nuvio-macOS-x86_64-0.1.35-alpha.dmg"
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
