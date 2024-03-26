#!/bin/bash

git checkout -b jrivero/noble_ci
sed -n '/^  jammy-ci:/,/^  \S/p' .github/workflows/ci.yml | \
  sed 's/jammy/noble/g' | \
  sed 's/Jammy/Noble/g' | \
  sed 's:action-gz-ci@noble:action-gz-ci@jrivero/jrivero/noble_fixes_1:g' \
  > .github/workflows/ci.yml.noble
cat .github/workflows/ci.yml.noble >> .github/workflows/ci.yml
git diff
rm .github/workflows/ci.yml.noble 
git ci -m "Add noble testing CI" .github/workflows/ci.yml
