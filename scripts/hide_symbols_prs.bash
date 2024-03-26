#!/bin/bash -ex

set +x
echo "----- $PWD ---------------------------------------------------------"
git checkout main
branch=$(git rev-parse --abbrev-ref HEAD)
new_pr_branch='jrivero/disable_hide_symbols_default'
git checkout "${new_pr_branch}" || git checkout -b "${new_pr_branch}"
git reset --hard
sed -i -e '/[[:space:]]*HIDE_SYMBOLS_BY_DEFAULT[[:space:]]*$/d' CMakeLists.txt
sed -i -e 's/HIDE_SYMBOLS_BY_DEFAULT //' CMakeLists.txt
if  git diff --quiet; then
  sed -i -e '/.*HIDE_SYMBOLS_BY_DEFAULT)$/d' CMakeLists.txt
  sed -i -e 's:_build(QUIT_IF_BUILD_ERRORS:_build(QUIT_IF_BUILD_ERRORS):' CMakeLists.txt
fi
git diff
git commit -m "Remove HIDE_SYMBOLS_BY_DEFAULT: replace by a default configuration in gz-cmake." -m "See https://github.com/gazebosim/gz-cmake/issues/166#issuecomment-1887521423" CMakeLists.txt --signoff
git push origin "${new_pr_branch}"
gh pr create --base "${branch}" --fill --head "${new_pr_branch}" --body "See https://github.com/gazebosim/gz-cmake/issues/166"
