#!/bin/bash

# This script is used to push my project for github and gitlab simultaneously. To to this, i do this steps:

# Obs: I had my local project vinculated with github account yet.

# 1 - Import my projet from github to gitlab. (I do it on gitlab platform, serching for "Import from github")
# 2 - Autenticate my local public key with my gitlab account.
# 3 - git remote add gitlab git@gitlab.com:yohrannes/website-portifolio.git

echo "Be sure that you're in the develop branch."
read -p "Commit comment:" coment

push-main () {
	git add .
	git commit -m "${coment}"
	git fetch origin develop
	git pull origin develop
	git push origin develop
	git checkout main
	git merge develop
	git fetch origin main
        git pull origin main
	git push gitlab main
	git checkout develop

}

push-main
