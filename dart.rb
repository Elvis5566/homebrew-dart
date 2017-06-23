class Dart < Formula
  desc "The Dart SDK"
  homepage "https://www.dartlang.org/"

  version "1.24.2"
  if MacOS.prefer_64_bit?
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.2/sdk/dartsdk-macos-x64-release.zip"
    sha256 "06215d2c7b51308dba4041bf2c110144947fc114c25c2bdffc4920f52f677e3b"
  else
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.2/sdk/dartsdk-macos-ia32-release.zip"
    sha256 "a282902f2e6a1ab8772a619f209f396856bcd070724c1b65f9ce463eec891c27"
  end

  devel do
    version "1.25.0-dev.3.0"
    if MacOS.prefer_64_bit?
      url "https://storage.googleapis.com/dart-archive/channels/dev/release/1.25.0-dev.3.0/sdk/dartsdk-macos-x64-release.zip"
      sha256 "262ab14f532bc53705b43a041dae7e5e1f25cf2eed072a87007d6b2e59542af5"
    else
      url "https://storage.googleapis.com/dart-archive/channels/dev/release/1.25.0-dev.3.0/sdk/dartsdk-macos-ia32-release.zip"
      sha256 "0718b0f5e83578ca4237e4c2808c098a1359a170ca8f54ca4f2f7d5259a1cf00"
    end

    resource "content_shell" do
      version "1.25.0-dev.3.0"
      url "https://storage.googleapis.com/dart-archive/channels/dev/release/1.25.0-dev.3.0/dartium/content_shell-macos-x64-release.zip"
      sha256 "760909ccb450a814aa31e383ae8f15fdbded23da2b64e95f408f2e89808096a5"
    end

    resource "dartium" do
      version "1.25.0-dev.3.0"
      url "https://storage.googleapis.com/dart-archive/channels/dev/release/1.25.0-dev.3.0/dartium/dartium-macos-x64-release.zip"
      sha256 "fdaa43a1c36b136fff1a5ca8121df753d24e9a13a8bc1be6d5c494c666491250"
    end
  end

  option "with-content-shell", "Download and install content_shell -- headless Dartium for testing"
  option "with-dartium", "Download and install Dartium -- Chromium with Dar"

  resource "content_shell" do
    version "1.24.2"
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.2/dartium/content_shell-macos-x64-release.zip"
    sha256 "01efc473c68aed830307d1dafb0cbcbfe77f40ceeeab3ef3ebe58a9912d05b13"
  end

  resource "dartium" do
    version "1.24.2"
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.2/dartium/dartium-macos-x64-release.zip"
    sha256 "188a038bd6367fddb434338bf6549bae25f5ad89b2f5b462acf8fb1fa20a3916"
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/dart"
    bin.write_exec_script Dir["#{libexec}/bin/{pub,dart?*}"]

    if build.with? "dartium"
      dartium_binary = "Chromium.app/Contents/MacOS/Chromium"
      prefix.install resource("dartium")
      (bin+"dartium").write shim_script dartium_binary
    end

    if build.with? "content-shell"
      content_shell_binary = "Content Shell.app/Contents/MacOS/Content Shell"
      prefix.install resource("content_shell")
      (bin+"content_shell").write shim_script content_shell_binary
    end
  end

  def shim_script(target)
    <<-EOS.undent
      #!/usr/bin/env bash
      exec "#{prefix}/#{target}" "$@"
    EOS
  end

  def caveats; <<-EOS.undent
    Please note the path to the Dart SDK:
      #{opt_libexec}

    --with-dartium:
      To use with IntelliJ, set the Dartium execute home to:
        #{opt_prefix}/Chromium.app
    EOS
  end

  test do
    (testpath/"sample.dart").write <<-EOS.undent
      void main() {
        print(r"test message");
      }
    EOS

    assert_equal "test message\n", shell_output("#{bin}/dart sample.dart")
  end
end
