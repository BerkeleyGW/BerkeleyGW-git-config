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
update_config_url='"!curl -sL https://raw.githubusercontent.com/BerkeleyGW/BerkeleyGW-git-config/master/setup.sh | sh"'
git config alias.update-config "$update_config_url" || {\
	echo 'ERROR: could not set "update-config" git alias.'
	exit 2
}


# Determine if we need to configure upstream
#git remote | grep -q '^upstream'; has_upstream=$?
#if [ $has_upstream -ne 0 ]; then
if ! git remote | grep -q '^upstream'; then
	# Find out if we are using HTTPS or SSH
	origin=`git config --get remote.origin.url`
	echo $origin | grep -q 'git@github.com:'; has_ssh=$?
	echo $origin | grep -q 'https://github.com/'; has_https=$?
	if [ $has_ssh -eq $has_https ]; then
		echo 'ERROR: could not determine if using HTTPS or SSH URL.'
		exit 3
	fi

	# Add upstream
	if [ $has_ssh -eq 0 ]; then
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
fi


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


# Setup commit template message
cat > .git/commit-template << EOF

################################################################################
# INSTRUCTIONS FOR WRITING YOUR COMMIT MESSAGE                                 #
################################################################################
#
# FIRST LINE: think of this as a SUBJECT LINE of an email. Write a SHORT
# SUMMARY, in < 50 characters, of your commit. Do not include a trailing period,
# and write your summary using verbs in the imperative form. Examples: 
#   "Fix bug in eqp corrections"
#   "Rewrite gmap"
#   "Optimize sigma for cache usage"
# These short commit messages appear in the "git lg" command, so it is
# important that they are SHORT and MEANINGFUL.
#
# SECOND LINE: add an EMPTY LINE. You don't need to include this empty line
# if you are not planning on writing a longer explanation below.
#
# THIRD LINE ON: add a long and descriptive explanation of what you did.
# This is optional for very small commits (eg: fix spelling, sign, etc.)
# but mandatory otherwise. Break each line after ~72 characters, and separate
# paragraphs with empty lines.
#
# Source: https://chris.beams.io/posts/git-commit/
#
################################################################################
EOF


echo 'Configuration script successfully (re)installed.'
