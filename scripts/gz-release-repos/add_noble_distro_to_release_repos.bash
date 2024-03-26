#!/bin/bash +x

set -e

DISTRO=${DISTRO:-noble}
new_branch="multi/add_${DISTRO}"

git checkout main
git reset --hard
git clean -f -d
git branch -D "${new_branch}" || true
git checkout -b "${new_branch}"
~/code/release-tools3/release-repo-scripts/new_ubuntu_distribution.bash "${DISTRO}"
git status
git ci -m "Add Noble distribution" "${DISTRO}"
git push origin "${new_branch}"

gh pr create --base main --fill --head "${new_branch}" --body "Add support for releasing noble. Do not merge"
