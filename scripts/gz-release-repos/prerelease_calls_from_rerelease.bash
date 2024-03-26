#!/bin/bash +x

set -e

DISTRO=${DISTRO:-noble}
DRY_RUN=${DRY_RUN:-true}

if [[ -z ${TOKEN} ]]; then
  echo "Provide a TOKEN for calling jobs"
  exit 1
fi

dry_run_str=""
if $DRY_RUN; then
  dry_run_str="--dry-run"
fi


PACKAGE=$(dpkg-parsechangelog --file "${DISTRO}/debian/changelog" -S Source)
CANONICAL_NAME="${PACKAGE%%[0-9]*}"
VERSION=$(dpkg-parsechangelog --file "${DISTRO}/debian/changelog" -S Version \
  | sed 's:-.*::')
REVISION=$(dpkg-parsechangelog --file "${DISTRO}/debian/changelog" -S Version \
  | sed 's:.*-::' | sed 's:~.*::')
 
SOURCE_TARBALL_URI="https://osrf-distributions.s3.amazonaws.com/${CANONICAL_NAME}/releases/${CANONICAL_NAME}-${VERSION}.tar.bz2"


 ~/code/release-tools/release.py ${dry_run_str} \
  --release-repo-branch "$(git branch --show-current)" \
  --source-tarball-uri "${SOURCE_TARBALL_URI}" \
  --upload-to prerelease \
  --release-version "${REVISION}" \
  --only-bump-revision-linux \
  "${PACKAGE}" "${VERSION}" "${TOKEN}"
