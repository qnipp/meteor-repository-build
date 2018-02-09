# meteor-repository-build

Build a Meteor app from a Git or SVN repository for using it in a nginx + Passenger environment

## Motivation

I run a server with a number of Meteor apps on [nginx](https://nginx.org/) and [Passenger](https://www.phusionpassenger.com/). To simplify the roll-out of a new version of an app, I've written the script *repository_build.sh*. It retrieves the source code from the SVN or Git repository, builds the Meteor app and installs it. Afterwards, Passenger is instructed to restart the app. For easier rebuild a script is stored into the app root directory with the used parameters.

As different Meteor versions need different versions of node, the script copies the approbriate node version as delivered as part of the Meteor installation into the root directory of the app. So, you can run different Meteor/node versions on the same installation.

## Installation

nginx, Passender and Meteor must already be installed on the server.

1. Copy the script *repository_build.sh* to */usr/local/bin*
2. Give it execution permission by `sudo chmod 755 /usr/local/bin/repository_build.sh`
3. Replace the */srv/meteor-apps* at the start of the script to your preferred path, where the Meteor apps should be running.
4. Set the the **METEOR_WAREHOUSE_DIR** variable, if you want to use a central repository for all Meteor packages instead of *~/.meteor*.

If you use the **METEOR_WAREHOUSE_DIR** variable, all users can use the same directory for the Meteor packages. You have to take care of the right permissions, so the respective users have read and write access. For initiatlization, [install Meteor as usual](https://www.meteor.com/install) and move the contents of the directory *~/.meteor* into **METEOR_WAREHOUSE_DIR**.

## Usage

```repository-build.sh project repository```
  
The **project** parameter is used to determine the path underneath the app directory (*/srv/meteor-apps*). **repository** contains a URL or path to retrieve the source code using Subversion or Git. The Subversion URL must start with **svn**.

## nginx configuration

The configuration files resist typically (at least within Debian) in */etc/nginx/sites-available*, where the files are symbolically linked to */etc/nginx/sites-enabled*. Take [nginx.example.com] and alter it according your own needs.

## Integration into Git

The script can be used to rebuild an app upon pushing into a local repository by creating an executable file in *REPOSITORY.git/hooks/post-update* with the contents:

```
#!/bin/bash

/usr/local/bin/repository-build.sh PROJECT $GIT_DIR
```

## License

MIT
