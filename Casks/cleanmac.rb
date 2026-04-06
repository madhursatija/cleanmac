cask "cleanmac" do
  version "1.0.0"
  sha256 :no_check # Avoids hash mismatch for rapid updates, can be updated later

  url "https://github.com/madhursatija/cleanmac/releases/download/v#{version}/CleanMac.dmg"
  name "CleanMac"
  desc "Menu bar utility to disable input while cleaning your Mac"
  homepage "https://github.com/madhursatija/cleanmac"

  # Requires macOS Ventura (13.0) or later
  depends_on macos: ">= :ventura"

  app "CleanMac.app"

  zap trash: [
    "~/Library/Preferences/com.madhursatija.CleanMac.plist",
    "~/Library/Application Scripts/com.madhursatija.CleanMac",
    "~/Library/Containers/com.madhursatija.CleanMac"
  ]
end
