#!/bin/bash -e

branch=$(git rev-parse --abbrev-ref HEAD)
new_pr_branch=codecov_port_${branch}
git checkout -b "${new_pr_branch}"
sed -i -e 's:codecov-token.*:codecov-enabled\: true:g' .github/workflows/ci.yml
git commit -m "Port codecov to new configuration" -m "See https://github.com/ignition-tooling/action-ignition-ci/pull/32/" --all --signoff
git push origin "${new_pr_branch}"
gh pr create --base "${branch}" --fill --head "${new_pr_branch}" | tee -a /tmp/codecov.log
