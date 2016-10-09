#!/bin/bash
#script for interacting with the git_sync service 

#Script constants
CONFIG_PATH="$HOME/.git_sync"
REPO_LIST="$CONFIG_PATH/repos"
CONFIG_FILE="$CONFIG_PATH/config"

# runtime variables
hour=""
minute=""

#check if the path passed as the argument is a git repository
#$1 : full path to the repo
function is_repo {
    cd $1
    if [[ $(git rev-parse --show-toplevel 2>/dev/null) = "$PWD" ]]; then
        echo "true"
    else
        echo "false"
    fi
}
# check if ssh authentication is setup
function check_ssh_authentication {
    response="$(ssh -oStrictHostKeyChecking=no -T git@github.com 2>&1)"
    echo "$response"
    if [[ $(grep -o "authenticated" <<<  "$response") = "authenticated" ]] ; then
        printf "true"
    else
        printf "SSH keys not properly configured see this guide for instructions \n
https://help.github.com/articles/generating-an-ssh-key/\n"
        exit 0
    fi
}
# check if the remote for the repo is set up to use ssh for pushing
# params:
# $1     : a full path to the repository
# return : 'ssh' | 'not ssh'
function check_origin {
    cd $1
    origin="$(git remote -v | grep -o -m 1 'git@github.com')"
    if [[ $origin != 'git@github.com' ]]; then
       echo 'not ssh'
    else
        echo 'ssh'
    fi
}
# add a repo to be tracked in the config file
# $1 : full path to the repo
function add_repo {

    if [ -d $1 ]; then                           # if the path is a directory
        if [ $(is_repo $1) = "true" ]; then      # if the path is a git repo
            if [[ $(check_origin $1)  = "ssh" ]]; then # if the git repo is configured to use ssh
                echo $1 >> $REPO_LIST
                create_hook $1                  # create a post commit hook on the repo
            else
                printf "Please set the remote origin to use ssh and try again\nsee: https://help.github.com/articles/changing-a-remote-s-url/ \n"
            fi
        else
            echo "path given is not a git repository"
        fi
    else
        echo "path given is not a directory"
    fi
}
#create cronjob
function create_cronjob {
    #write out current crontab
    crontab -l > mycron
    #echo new cron into cron file
    echo "$minute $hour * * * $HOME/.git_sync/bin/git_sync.sh" >> mycron
    #install new cron file
    crontab mycron
    rm mycron
}
#create a hook so that the repository will be pushed every time a commit is made
# $1 path to the repo that we want to be auto commited
function create_hook {
    if [ -e "$1/.git/hooks/post-commit" ]; # if a post-commit hook exists
        echo 'git push' >> "$1/.git/hooks/post-commit"
    else
        echo $'#!/bin/bash \n git push' > "$1/.git/hooks/post-commit"
        cd "$1/.git/hooks/"
        chmod +x "$1/.git/hooks/post-commit"
    fi
}
#configures the git_sync service and generates the config files
#Used on first run
function init_git_sync {
    mkdir "$CONFIG_PATH"
    mkdir "$CONFIG_PATH/bin"
    touch $REPO_LIST
    touch $CONFIG_FILE                              # might be used in the future
    cp ./git_sync.sh "$CONFIG_PATH/bin/git_sync.sh"
    chmod +x "$CONFIG_PATH/bin/git_sync.sh"         # make the script executable
}
function add_repos {
    read -p "Please Enter the absolute path of the github repos to autosave (Blank to continue): `echo $'\n> '`" repo
    while [ ! -z $repo ]; do
        add_repo $repo
        printf "Repo Added!\n\n"
        read -p "Please Enter the absolute path of the github repos to autosave (Blank to continue): `echo $'\n> '`" repo
    done
}
function set_time {
    read -p "Please enter the time for the daily backups to occur (HH:MM)[00-23:00-59]: `echo $'\n>'`" t
    IFS=':' read -r -a arr <<< "$t"
    hour="${arr[0]}"
    minute="${arr[1]}"
    unset $IFS  #squeaky clean
}
function main {
    #if config path doesnt exist
    if [ ! -d $CONFIG_PATH ]; then
        init_git_sync
    fi
    add_repos
    set_time
    create_cronjob
}
main
