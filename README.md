# Git-Safe


### What is it?
Git-safe is a small script that ensures that all of the tracked git repos are commited and pushed to the remote host.
It accomplishes this by setting up a cron job to run the script at a time specified by the user.


### How should I use it?
The intended use of Git-safe is to make sure that all of your personal projects are always backed up in case of data loss.


**Git-safe is especially usefull for ensuring that your dotfiles are always backed up.**


However, while Git-safe might seem convenient, it is best to not track any group projects or repos where commited code must be kept
stable due to the following:

1. Git-safe will run at a specified time every day. Meaning that most likely it will result in broken code being pushed to the remode
repo.
2. Git-safe does not handle the case where the remote branch is ahead of the local branch. As such the push will fail.



### Installation
To get git-safe up and running, simply clone the repo and run the setup.sh script. 
```bash
git clone https://github.com/Gradecak/git-safe.git
```
once cloned make the script executable by running `chmod +x setup.sh` followed by `./setup.sh` This will begin the
configuration process and prompt you for any input it requires.

once you run setup.sh if you wish to track any aditional repositories using git-safe simply add the absolute path to ~/.git_safe/repos


### Issues
Right now there is no user friendly way to change the cron job time once it has been set by the setup script. If you are familiar with crontab you can
manually edit the file to change the time that the script will execute.
