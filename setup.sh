#!/bin/sh
# Automatically sets and run the "git update-config" alias for BerkeleyGW git development.
# Run me the first time with with:
# curl -sL https://raw.githubusercontent.com/BerkeleyGW/BerkeleyGW-git-config/master/setup.sh | sh
#
# Felipe H. da Jornada (2018)


# Go to top-level directory for this repo.
cd `git rev-parse --show-toplevel` || {\
	echo 'ERROR: could not go to the top-level Git repo.'
	echo 'Are you sure you are in a Git repo?'
	exit 1
}


# Configure the "git update-config" alias
update_config_url="'!curl -sL https://raw.githubusercontent.com/BerkeleyGW/BerkeleyGW-git-config/master/setup.sh | sh'"
git config alias.update-config "$update_config_url" || {\
	echo 'ERROR: could not set "update-config" git alias.'
	exit 2
}


# Find out if we are using HTTPS or SSH
origin=`git config --get remote.origin.url`
echo $origin | grep -q 'git@github.com:'; has_ssh=$?
echo $origin | grep -q 'https://github.com/'; has_https=$?
if [ $has_ssh -a $has_https -o !$has_ssh -a !$has_https ]; then
	echo 'ERROR: could not determine if using HTTPS or SSH URL.'
	exit 3
fi


# Add upstream
if $has_ssh; then
	url='git@github.com:BerkeleyGW/BerkeleyGW.git'
	url_kind=SSH
else
	url='https://github.com/BerkeleyGW/BerkeleyGW.git'
	url_kind=HTTPS
fi
git remote add upstream $url && \
	echo "Configured upstream with $url_kind URL." || \
{
	echo "ERROR: could not configure upstream with $url_kind URL."
	exit 4
}


# Download "bgw-config" script
bgw_config_url="https://raw.githubusercontent.com/BerkeleyGW/git-config/master/bgw-config"
curl -LsS -H "Cache-Control: no-cache" -o .git/bgw-config $bgw_config_url || {\
	echo "ERROR: Could not download bgw-config from ${bgw_config_url}."
	echo "$bgw_config_url"
	exit 5
}


# Setup "bgw-config"
git config include.path bgw-config || {\
	echo 'ERROR: could not setup configuration script "bgw-config".'
	exit 6
}


echo 'Configuration script successfully (re)installed.'
