#!/bin/bash
#script for interacting with the git_safe service 

#Script constants
CONFIG_PATH="$HOME/.git_safe"
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
#add a repo to be tracked in the config file
# $1 : full path to the repo
function add_repo {
    if [ -d $1 ]; then                      # if the path is a directory
        if [ $(is_repo $1) = "true" ]; then # if the path is a git repo
            echo $1 >> $REPO_LIST
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
    echo "$minute $hour * * * $HOME/.git_safe/bin/git_safe.sh" >> mycron
    #install new cron file
    crontab mycron
    rm mycron
}
#configures the git_safe service and generates the appropriate config files
#Used on first run
function init_git_safe {
    mkdir "$HOME/.git_safe"
    mkdir "$CONFIG_PATH/bin"
    touch $REPO_LIST
    touch $CONFIG_FILE                              # might be used in the future
    cp ./git_safe.sh "$CONFIG_PATH/bin/git_safe.sh"
    chmod +x "$CONFIG_PATH/bin/git_safe.sh"         # make the script executable
}
function add_repos {
    read -p "Please Enter the absolute path of the github repos to autosave (Enter to continue): `echo $'\n> '`" repo
    while [ ! -z $repo ]; do
        add_repo $repo
        read -p "Please Enter the absolute path of the github repos to autosave (Enter to continue): `echo $'\n> '`" repo
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
        init_git_safe
    fi
    add_repos
    set_time    
    create_cronjob
}

main
