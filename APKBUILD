# Maintainer: Benjamin Kraatz <benjaminkraatz@yahoo.com>
# Based on Alpine's community/webkit2gtk-6.0 APKBUILD.
#
# WPE WebKit 2.x with the WPE Platform API (Wayland, DRM and headless
# backends) and the features a desktop or kiosk needs: GStreamer media with
# audio, video, MSE, WebCodecs, WebRTC, camera and microphone, speech,
# spellcheck, ATK accessibility, gamepads and GObject introspection.
#
# Off on purpose: the legacy libwpe API (deprecated upstream since 2.54),
# encrypted media (needs a proprietary CDM) and WebKit's bubblewrap sandbox,
# so embedders that sandbox the web process themselves don't nest a second
# sandbox inside their own.
pkgname=wpewebkit
pkgver=2.54.1
pkgrel=1
pkgdesc="WPE WebKit, the embedded-first WebKit port, with the WPE Platform API and media"
url="https://wpewebkit.org/"
arch="aarch64 x86_64"
license="LGPL-2.0-or-later AND BSD-2-Clause"
makedepends="
	at-spi2-core-dev
	bison
	clang
	cmake
	enchant2-dev
	eudev-dev
	flex
	flite-dev
	fontconfig-dev
	freetype-dev
	gettext-dev
	glib-dev
	gobject-introspection-dev
	gperf
	gst-plugins-bad-dev
	gst-plugins-base-dev
	gstreamer-dev
	harfbuzz-dev
	hyphen-dev
	icu-dev
	lcms2-dev
	libavif-dev
	libdrm-dev
	libepoxy-dev
	libgcrypt-dev
	libinput-dev
	libjpeg-turbo-dev
	libjxl-dev
	libmanette-dev
	libpng-dev
	libsoup3-dev
	libtasn1-dev
	libwebp-dev
	libxkbcommon-dev
	libxml2-dev
	libxslt-dev
	lld
	llvm
	mesa-dev
	openssl-dev
	perl
	python3
	ruby
	ruby-getoptlong
	samurai
	sqlite-dev
	sysprof-dev
	sysprof-static
	unifdef
	wayland-dev
	wayland-protocols
	woff2-dev
	zlib-dev
	"
options="!check" # tests aren't in the release tarball
subpackages="$pkgname-dev"
source="https://wpewebkit.org/releases/wpewebkit-$pkgver.tar.xz"
builddir="$srcdir/wpewebkit-$pkgver"

build() {
	export CC=clang
	export CXX=clang++
	export LDFLAGS="$LDFLAGS -fuse-ld=lld"
	export AR=llvm-ar
	export NM=llvm-nm
	export RANLIB=llvm-ranlib
	# Same as Alpine's WebKitGTK: smaller debug info, and fortify breaks the build.
	export CFLAGS="$CFLAGS -g1 -U_FORTIFY_SOURCE"
	export CXXFLAGS="$CXXFLAGS -g1 -U_FORTIFY_SOURCE"
	# musl has no gettext; glib's headers route bindtextdomain to libintl.
	# Passed explicitly so a re-run of cmake in an existing build dir picks it up.
	local linker_flags="$LDFLAGS -lintl"

	cmake -B build -G Ninja \
		-DPORT=WPE \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SKIP_RPATH=ON \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DCMAKE_SHARED_LINKER_FLAGS="$linker_flags" \
		-DCMAKE_EXE_LINKER_FLAGS="$linker_flags" \
		-DENABLE_WPE_PLATFORM=ON \
		-DENABLE_WPE_PLATFORM_WAYLAND=ON \
		-DENABLE_WPE_PLATFORM_DRM=ON \
		-DENABLE_WPE_PLATFORM_HEADLESS=ON \
		-DENABLE_WPE_LEGACY_API=OFF \
		-DENABLE_WPE_QT_API=OFF \
		-DENABLE_MINIBROWSER=ON \
		-DENABLE_WEBDRIVER=ON \
		-DENABLE_BUBBLEWRAP_SANDBOX=OFF \
		-DUSE_GSTREAMER=ON \
		-DUSE_GSTREAMER_GL=ON \
		-DUSE_GSTREAMER_WEBRTC=ON \
		-DENABLE_VIDEO=ON \
		-DENABLE_WEB_AUDIO=ON \
		-DENABLE_MEDIA_SOURCE=ON \
		-DENABLE_MEDIA_STREAM=ON \
		-DENABLE_MEDIA_RECORDER=ON \
		-DENABLE_WEB_CODECS=ON \
		-DENABLE_WEB_RTC=ON \
		-DENABLE_ENCRYPTED_MEDIA=OFF \
		-DENABLE_SPEECH_SYNTHESIS=ON \
		-DUSE_FLITE=ON \
		-DENABLE_SPELLCHECK=ON \
		-DENABLE_GAMEPAD=ON \
		-DENABLE_INTROSPECTION=ON \
		-DENABLE_DOCUMENTATION=OFF \
		-DENABLE_JOURNALD_LOG=OFF \
		-DUSE_ATK=ON \
		-DUSE_AVIF=ON \
		-DUSE_JPEGXL=ON \
		-DUSE_LIBHYPHEN=ON \
		-DUSE_LIBBACKTRACE=OFF \
		-DUSE_SYSPROF_CAPTURE=ON
	cmake --build build -j "${JOBS:-$(nproc)}"
}

package() {
	DESTDIR="$pkgdir" cmake --install build
}

sha512sums="
6db56d34219615c07838c63c99b562d1c6acdfc4499af80c34b00027fc51558ce5c4c3b8cecfd11efb78c037b5408388422633cbf77e0e572266ec55fcb443d7  wpewebkit-2.54.1.tar.xz
"
