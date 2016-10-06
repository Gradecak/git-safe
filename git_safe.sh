#!/bin/bash

#constants
CONFIG_PATH="$HOME/.git_safe"
REPO_LIST="$CONFIG_PATH/repos"
CONFIG_FILE="$CONFIG_PATH/config"
#runtime variables
arr=""
# fetch the list of registered repos
function get_repo_list {
    IFS=$'\n'              # set the delimiter for reading file to the newline char
    arr=($(<"$REPO_LIST"))
    unset $IFSi            # cleaning up
}
#takes a path to a git repository and returns 'true'/'false' if path is valid
#ensures that there hasn't been an invalid entry in the repos file
#$1     : full path to git directory
#return : valid repo?
function is_valid_repo {
    if [ -d $1 ]; then
        cd $1
        if [[ $(git rev-parse --show-toplevel 2>/dev/null) = "$PWD" ]]; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
}
# get the status of the repo passed as a paramater $1 : full path to the git
# directory return : status of the repository adding another comment casdf
function test_and_push {
    echo "Testing $1"
    if [ $(is_valid_repo $1) = "true" ]; then
        cd $1
        if [ ! -z "$(git status --porcelain)" ]; then #if there are uncommited changes
            echo "commiting and pushing changes"
            git add .
            git commit -m 'auto commit'
            git push
        elif [ "$(git push -n 2>&1)" != "Everything up-to-date" ]; then #if there are unpushed changes
            echo "pushing changes"
            git push
        fi
    fi
}
function main {
    get_repo_list
    for i in "${arr[@]}"; do
        test_and_push $i
    done
}
main
