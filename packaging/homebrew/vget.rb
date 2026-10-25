class Vget < Formula
  desc "Universal Media Hub CLI for video, audio extraction and streaming"
  homepage "https://github.com/eulgen/vget"
  url "https://github.com/eulgen/vget/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/eulgen/vget.git", branch: "main"

  depends_on "bash"
  depends_on "yt-dlp"
  depends_on "ffmpeg"
  depends_on "fzf"
  depends_on "aria2" => :recommended
  depends_on "mpv" => :optional

  def install
    # Installation des bibliothèques dans pkgshare
    pkgshare.install Dir["lib/*.sh"]

    # Ajustement de la résolution de bibliothèque pour Homebrew
    inreplace "bin/vget", 'echo "$base_dir/lib"', "echo \"#{pkgshare}\""

    # Installation du binaire exécutable
    bin.install "bin/vget"

    # Installation des autocomplétions multi-shells
    bash_completion.install "completions/vget.bash" => "vget"
    zsh_completion.install "completions/_vget" => "_vget"
    fish_completion.install "completions/vget.fish" => "vget.fish"
  end

  test do
    assert_match "vget v#{version}", shell_output("#{bin}/vget --version")
    assert_match "USAGE:", shell_output("#{bin}/vget --help")
  end
end
