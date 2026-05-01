#!/bin/bash
source srcpkgs/.ENV

# clone void package repository
git clone --depth 1 https://github.com/void-linux/void-packages srcpkgs/packages

# move templates
cp -RfvT srcpkgs/nekobox srcpkgs/packages/srcpkgs/nekobox
ln -s nekobox srcpkgs/packages/srcpkgs/nekobox-core

ln -s srcpkgs/nekobox srcpkgs/packages/srcpkgs/nekobox-core
cd srcpkgs/packages
echo "libthrift.so.0.22.0 thrift-0.22.0_1" >> common/shlibs
tail -5 common/shlibs

# If local source exists
if [[ -f "$XBPS_TARGET_SOURCE" && -n "$XBPS_TARGET_VERSION" ]]
then
  # Update version
  sed -i "s/^version=.*/version=$XBPS_TARGET_VERSION/" srcpkgs/nekobox/template
  # Update checksum
  CHECKSUM=$(sha256sum "$XBPS_TARGET_SOURCE" | cut -d' ' -f1)
  sed -i "s/^checksum=.*/checksum=$CHECKSUM/" srcpkgs/nekobox/template
  # Copy sources
  install -Dm644 "$XBPS_TARGET_SOURCE" srcpkgs/packages/hostdir/sources/nekobox-${XBPS_TARGET_VERSION}/nekobox-unified-source-${XBPS_TARGET_VERSION}.tar.xz
  install -Dm644 "$XBPS_TARGET_SOURCE" srcpkgs/packages/hostdir/sources/by_sha256/${CHECKSUM}_nekobox-unified-source-${XBPS_TARGET_VERSION}.tar.xz
fi

# create package
echo "=== Building nekobox for ${XBPS_TARGET_ARCH} ==="
bash ./xbps-src -A "${XBPS_TARGET_ARCH}" binary-bootstrap
bash ./xbps-src pkg -j$(nproc) -A "${XBPS_TARGET_ARCH}" nekobox

echo "=== Signing packages ==="
# Only sign if secrets are available
if [ -n "${PRIVATE_KEY}" ]
then
  xbps-rindex -r $PWD
  xbps-rindex -s --signedby "nekobox-void <noreply@github.com>" \
   --privkey <(printf '%s' "${PRIVATE_KEY}") $PWD
  xbps-rindex -S --privkey <(printf '%s' "${PRIVATE_KEY}") *.xbps
  xbps-rindex -c $PWD
  echo "Packages signed successfully"
else
  echo "Signing skipped - no private key configured"
fi
