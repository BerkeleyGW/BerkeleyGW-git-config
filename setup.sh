#!/bin/bash
# Automatically sets the "git update-config" alias for BerkeleyGW git development.
# Run me with:
# curl -sL https://raw.githubusercontent.com/BerkeleyGW/BerkeleyGW-git-config/master/update-config.sh | bash
#
# Felipe H. da Jornada (2018)

git config alias.update-config '!cd $(git rev-parse --show-toplevel) && curl -LsS -H "Cache-Control: no-cache" -o .git/bgw-config https://raw.githubusercontent.com/BerkeleyGW/git-config/master/bgw-config && echo "Configuration updated" || echo "Update failed"' && \
git config include.path bgw-config && \
echo 'Configuration installed' || echo 'Configuration script could not be installed'
git update-config