class RattlerBuild < Formula
  desc "Universal conda package builder for Windows, macOS and Linux"
  homepage "https://github.com/prefix-dev/rattler-build"
  url "https://github.com/prefix-dev/rattler-build/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "c2e62310e2fbc0da239514b606b0a2df7c3b5a417e0855a8193358d0c9f5dbf0"
  license "BSD-3-Clause"
  head "https://github.com/prefix-dev/rattler-build.git", branch: "main"

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "openssl@3"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_equal "rattler-build #{version}", shell_output("#{bin}/rattler-build --version").strip
    (testpath/"recipe.yaml").write <<~EOS
      package:
        name: test-package
        version: '0.1.0'

      build:
        noarch: generic
        string: buildstring
        script:
          - mkdir -p $PREFIX/bin
          - echo "echo Hello World!" >> $PREFIX/bin/hello
          - chmod +x $PREFIX/bin/hello

      test:
        commands:
          - test -d ${PREFIX}/bin/hello
          - hello | grep "Hello World!"
    EOS
    system "#{bin}/rattler-build", "build"
    assert_path_exists testpath/"output"/"noarch"/"test-package-0.1.0-buildstring.tar.bz2"
  end
end
