#!/bin/bash +x

set -e

DISTRO=${DISTRO:-noble}

if [[ -z ${TOKEN} ]]; then
  echo "Provide a TOKEN for calling jobs"
  exit 1
fi

PACKAGE=$(dpkg-parsechangelog --file "${DISTRO}/debian/changelog" -S Source)
CANONICAL_NAME="sed 's/[[:digit:]]*$//' <<< ${PACKAGE}"
VERSION=$(dpkg-parsechangelog --file "${DISTRO}/debian/changelog" -S Version \
  | sed 's:-.*::')
REVISION=$(dpkg-parsechangelog --file "${DISTRO}/debian/changelog" -S Version \
  | sed 's:.*-::' | sed 's:~.*::')
 
SOURCE_TARBALL_URI="https://osrf-distributions.s3.amazonaws.com/${CANONICAL_NAME}/releases/${PACKAGE}-${VERSION}.tar.bz2"


_RELEASEPY_DEBUG=1 ~/code/release-tools/release.py --dry-run \
  --release-repo-branch "$(git branch --show-current)" \
  --source-tarball-uri "${SOURCE_TARBALL_URI}" \
  --upload-to prerelease \
  --release-version "${REVISION}" \
  --only-bump-revision-linux \
  "${PACKAGE}" "${VERSION}" "${TOKEN}"
