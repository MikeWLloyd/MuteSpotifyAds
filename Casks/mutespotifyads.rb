cask "mutespotifyads" do
  version :latest
  sha256 :no_check

  url "https://github.com/MikeWLloyd/MuteSpotifyAds/releases/latest/download/MuteSpotifyAds.app.tar.gz"
  name "MuteSpotifyAds"
  desc "Automatically mutes Spotify ads"
  homepage "https://github.com/MikeWLloyd/MuteSpotifyAds"

  app "MuteSpotifyAds.app"
end
