class Mkpasswd < Formula
  desc "Generate encrypted mkpasswd password strings"
  homepage "https://github.com/rfc1036/whois"
  url "https://github.com/rfc1036/whois/archive/refs/tags/v5.5.18.tar.gz"

  sha256 "f0ecc280b5c7130dd8fe4bd7be6acefe32481a2c29aacb1f5262800b6c79a01b"
  license "GPL-2.0-or-later"

  depends_on "pkg-config" => :build
  depends_on macos: :ventura
  depends_on "openssl"

  patch :DATA
  patch :p0, :DATA

  def install
    OS.mac? do
      ENV.append "LDFLAGS", "-L/usr/lib -liconv"
    end

    have_iconv = "HAVE_ICONV=1"

    OS.linux? do
      have_iconv = "HAVE_ICONV=0"
    end

    system "make", "mkpasswd", have_iconv
    bin.install "mkpasswd"
    man1.install "mkpasswd.1"
  end

  test do
    system "#{bin}/mkpasswd", "test"
  end
end

__END__
diff --git a/Makefile b/Makefile
index da93d4c..d0559f9 100644
--- a/Makefile
+++ b/Makefile
@@ -65,6 +65,8 @@ else ifdef HAVE_LIBOWCRYPT
 # owl and openSUSE have crypt_gensalt(3) in libowcrypt
 DEFS += -DHAVE_CRYPT_H -DHAVE_LINUX_CRYPT_GENSALT -D_OW_SOURCE
 mkpasswd_LDADD += -lcrypt -lowcrypt
+else ifeq ($(shell $(PKG_CONFIG) --exists 'libcrypto' || echo NO),)
+mkpasswd_LDADD += $(shell $(PKG_CONFIG) --libs libcrypto)
 else
 mkpasswd_LDADD += -lcrypt
 endif
