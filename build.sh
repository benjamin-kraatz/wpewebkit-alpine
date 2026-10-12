#!/bin/sh
# Builds the wpewebkit packages from ./APKBUILD inside an Alpine container and
# copies them to /out. Runs as root; abuild itself runs as an unprivileged user.
#
#   docker run --rm -v "$PWD:/src:ro" -v "$PWD/out:/out" alpine:3.24 /src/build.sh
#
# ABUILD_PRIVKEY, if set, holds the private key that signs the packages.
# keys/wpewebkit-alpine.rsa.pub is its public half. Without it the build makes
# a throwaway key, which is fine for trying the recipe locally.
set -eu

src=${SRC:-/src}
out=${OUT:-/out}
keyname=wpewebkit-alpine.rsa
home=/home/builder

# Keeps the package index, which abuild needs to install the build dependencies.
apk update
apk add alpine-sdk
adduser -D -G abuild builder
mkdir -p "$home/.abuild" "$home/wpewebkit" "$home/packages"
cp "$src/APKBUILD" "$home/wpewebkit/"

if [ -n "${ABUILD_PRIVKEY:-}" ]; then
	printf '%s\n' "$ABUILD_PRIVKEY" > "$home/.abuild/$keyname"
	cp "$src/keys/$keyname.pub" "$home/.abuild/"
	echo "PACKAGER_PRIVKEY=$home/.abuild/$keyname" > "$home/.abuild/abuild.conf"
	chown -R builder:abuild "$home"
	chmod 600 "$home/.abuild/$keyname"
else
	chown -R builder:abuild "$home"
	su builder -c "abuild-keygen -a -n"
fi
# The build doesn't need the key in its environment.
unset ABUILD_PRIVKEY
# abuild -r indexes its output repository, which apk must trust.
cp "$home"/.abuild/*.rsa.pub /etc/apk/keys/

su builder -c "cd $home/wpewebkit && REPODEST=$home/packages abuild -r"

mkdir -p "$out"
cp "$home"/packages/*/"$(apk --print-arch)"/*.apk "$out/"
ls -la "$out"
