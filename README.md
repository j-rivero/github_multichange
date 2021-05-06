# Manage multiple github repos at once

DISCLAIMER: tool not ready to use

## Use cases

Designed to work inside a directory where subdirectories are the github repositories.
Use vcs tool to create them from distros files.

### Show repos and branches detected by the tool

`python3 multi_manage.py show`

### Exec custom command in repositories

`python3 multi_manage.py exec git diff`

### Exec bash script inside all repositories

`python3 ~/code/github_multichange/multi_manage.py exec-script scripts/sed_open_pr.bash`
