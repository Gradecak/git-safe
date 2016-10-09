# Git-Sync


### What is it?
Git-sync is a small script that ensures that all of the tracked git repos are commited and pushed to the remote host.
It accomplishes this by setting up a cron job to run the script at a time specified by the user.


### How should I use it?
The intended use of Git-sync is to make sure that all of your personal projects are always backed up in case of data loss.


**Git-safe is especially usefull for ensuring that your dotfiles are always backed up.**


However, while Git-sync might seem convenient, it is best to not track any group projects or repos where commited code must be kept
stable due to the following:

1. Git-sync will run at a specified time every day. Meaning that most likely it will result in broken code being pushed to the remode
repo.
2. Git-sync does not handle the case where the remote branch is ahead of the local branch. As such the push will fail.



### Installation
In order to get Git-sync up and running, you must first setup a couple of pre requisites:

1. Ensure that ssh authentication for github is configured on your machine.[See guide here](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)
2. Ensure that the local repository is configured to push using ssh [See guide here](https://help.github.com/articles/changing-a-remote-s-url/)

After that is complete simply clone the repo and run the setup.sh script.
```bash
git clone https://github.com/Gradecak/git-sync.git
```
Once cloned, make the script executable by running `chmod +x setup.sh` followed by `./setup.sh` This will begin the
configuration process and prompt you for any input it requires.

once you run setup.sh if you wish for Git-sync to track any aditional repositories simply add the absolute path to `~/.git_sync/repos`. You will also have to ensure that a post-commit hook is setup for the newly entered repo by running the
following command. `echo "#!/bin/bash \n git push" >> <path_to_repo>/.git/hooks/post-commit && chmod +x <path_to_repo>/.git/hooks/post-commit`.


### Issues
1. Right now there is no user friendly way to change the cron job time or add new repos once they habe been set by the setup script. If you are familiar with crontab you can manually edit the file to change the time that the script will execute. If you wish to add more repositories 
