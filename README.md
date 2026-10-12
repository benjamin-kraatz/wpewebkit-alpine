# wpewebkit-alpine

[![Build](https://github.com/benjamin-kraatz/wpewebkit-alpine/actions/workflows/build.yml/badge.svg)](https://github.com/benjamin-kraatz/wpewebkit-alpine/actions/workflows/build.yml)

[WPE WebKit](https://wpewebkit.org/) packages for [Alpine Linux](https://alpinelinux.org/), built for aarch64 and x86_64.

Alpine ships WebKitGTK but not WPE WebKit, the WebKit port made for embedded devices, kiosks and custom shells. Compiling it yourself takes one to three hours on a fast machine. This repository holds the recipe, builds it on GitHub Actions and publishes signed `.apk` files you can install with `apk`.

The build uses the WPE Platform API, which replaces libwpe and its backends from WPE 2.54 on. Audio and video are on.

This is an independent project. It isn't affiliated with Igalia, the WebKit project or Alpine Linux.

## Install

The packages are built against Alpine 3.24. Other Alpine releases ship different library versions, so use them on 3.24 only.

Trust the signing key once, then install the package for your architecture:

```sh
release=https://github.com/benjamin-kraatz/wpewebkit-alpine/releases/download/2.54.1-r1
wget -O /etc/apk/keys/wpewebkit-alpine.rsa.pub "$release/wpewebkit-alpine.rsa.pub"
wget "$release/wpewebkit-2.54.1-r1.$(apk --print-arch).apk"
apk add "./wpewebkit-2.54.1-r1.$(apk --print-arch).apk"
```

`apk` checks the package's signature against that key and pulls the libraries it links against from Alpine's own repositories. Add `wpewebkit-dev-2.54.1-r1.<arch>.apk` the same way if you're building something against WPE.

Each release also has a `SHA256SUMS` file. To pin a build in your own tooling, check against that.

### Codecs and audio output

WPE hands media to GStreamer, and GStreamer finds decoders and outputs as plugins at runtime. The package doesn't pull them in, because what you need depends on your device. A typical set:

```sh
apk add gst-plugins-base gst-plugins-good gst-plugin-pipewire
apk add gst-plugins-bad gst-libav   # more formats, including H.264 and AAC through FFmpeg
apk add libnice-gstreamer           # for WebRTC
```

Check the patent and licensing situation for H.264 and AAC in your country before you ship `gst-libav` on a product.

## Features

| Feature | State | Notes |
| --- | --- | --- |
| WPE Platform API | on | Wayland, DRM and headless backends |
| Legacy libwpe API | off | Deprecated upstream since 2.54 |
| Audio and video (`<audio>`, `<video>`) | on | Through GStreamer, with GStreamer GL |
| Web Audio | on | |
| Media Source Extensions | on | Adaptive streaming |
| WebCodecs | on | |
| Camera and microphone (`getUserMedia`) | on | |
| MediaRecorder | on | |
| WebRTC | on | Through GstWebRTC |
| Encrypted media (EME) | off | Needs a proprietary CDM such as Widevine |
| Speech synthesis | on | Flite |
| Spellcheck | on | Enchant. Install a dictionary such as `hunspell-en-us` |
| Accessibility | on | ATK and the AT-SPI bridge |
| Gamepad API | on | libmanette |
| AVIF and JPEG XL images | on | |
| Hyphenation | on | libhyphen |
| GObject introspection | on | `.gir` in `-dev`, typelib in the main package |
| MiniBrowser and WebDriver | on | `/usr/libexec/wpe-webkit-2.0/MiniBrowser`, `WPEWebDriver` |
| Bubblewrap sandbox | off | See below |
| Qt/QML API | off | Would pull in Qt 6 |

All features that cost nothing until a page uses them are on. You can still switch most of them off per web view at runtime through `WebKitSettings`.

### Why the bubblewrap sandbox is off

WebKit can wrap its web processes in bubblewrap. This build leaves that out because it targets embedders that sandbox the web process themselves, with namespaces, seccomp or Landlock, and a second sandbox nested inside theirs breaks or adds nothing. If you run WPE as a plain browser on a multi-user system, you lose WebKit's own process isolation. Weigh that before you use these packages there.

## Build it yourself

You need Docker. On an x86_64 machine, add `--platform linux/arm64` and QEMU to build for aarch64, and expect it to be many times slower.

```sh
git clone https://github.com/benjamin-kraatz/wpewebkit-alpine
cd wpewebkit-alpine
mkdir out
docker run --rm -v "$PWD:/src:ro" -v "$PWD/out:/out" alpine:3.24 /src/build.sh
```

The packages end up in `out/`, signed with a throwaway key. Install them with `apk add --allow-untrusted`, or set `ABUILD_PRIVKEY` to your own key's contents. The build needs about 6 GB of disk, and around 2 GB of memory per compile job.

## How releases are made

[`.github/workflows/build.yml`](.github/workflows/build.yml) builds both architectures on GitHub's native runners, in parallel, inside `alpine:3.24`. It runs when `APKBUILD`, `build.sh` or the workflow changes on `main`, or when started by hand. It never runs on pull requests, so the signing key stays out of reach of code from forks.

When both builds pass, the workflow publishes a release tagged `<pkgver>-r<pkgrel>` with the packages, the public key and `SHA256SUMS`.

A new WPE version means changing `pkgver` and `sha512sums` in `APKBUILD` and setting `pkgrel` back to 0. A recipe change on the same version increases `pkgrel`. WPE publishes security releases every few weeks, listed in the [WebKit security advisories](https://webkitgtk.org/security.html), and this repository follows them.

## Contributing to Alpine

The goal is to submit this recipe to Alpine's [aports](https://gitlab.alpinelinux.org/alpine/aports) once it has run in practice for a while. Alpine's own builders would then build and update it, and this repository would no longer be needed. The recipe follows Alpine's `webkit2gtk-6.0` package for that reason. If you use these packages, issues about what breaks or what's missing help that submission.

## License

The recipe and scripts in this repository are under the [MIT license](LICENSE). WPE WebKit itself is under the LGPL 2.0 or later and BSD 2-clause licenses. Its source is the release tarball from [wpewebkit.org](https://wpewebkit.org/releases/), checked against the SHA-512 sum in `APKBUILD`.
