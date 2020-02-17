#!/bin/bash

PROJECT="$1"

# Change the path according your needs
PROJECTDIR="/srv/meteor-apps/$PROJECT"

if [ $# -lt 2 ] ; then
	echo "Syntax; $0 project repository [branch]"
	echo ""
	echo "The type of repository is retrieved from the URL."
	echo "The build software is installed into $PROJECTDIR."
	exit 1
fi

REPOSITORY="$2"
BRANCH="$3"
REALPATH=`realpath $0`

TS=$(date +'%Y%m%d_%H%M%S')
TMPDIR="/tmp/$PROJECT-$TS"
BUILDDIR="$PROJECTDIR-$TS"
OLDDIR="$PROJECTDIR-$TS.old"
REBUILD="$BUILDDIR/rebuild.sh"

# Set this, if you want a central repository for the Meteor packages
# export HOME=/home/meteor

mkdir -p "$TMPDIR"

if [ "${REPOSITORY:0:3}" = "svn" ] ; then
	svn checkout "$REPOSITORY" "$TMPDIR"
else
	git clone -b "${BRANCH:-master}" "$REPOSITORY" "$TMPDIR"
fi

cd "$TMPDIR"
meteor --version
meteor npm install || exit 2
meteor build "$BUILDDIR" --directory $BUILDFLAGS || exit 2

# get right version of node and npm
NODE_BINARY=`meteor node -e 'console.log(process.argv[0])'`
NPM_BINARY="${NODE_BINARY%/*}/npm"

cd "$BUILDDIR/bundle/programs/server"
"$NPM_BINARY" install || exit 2
rm -rf "$TMPDIR"
rm -rf $BUILDDIR/.bundle-garbage*

cp "$NODE_BINARY" "$BUILDDIR"

cat <<EOF > $REBUILD
#!/bin/sh

BUILDFLAGS="$BUILDFLAGS" $REALPATH $@
EOF

chmod 775 $REBUILD

echo "File to rebuild with the same parameters saved to $REBUILD"

mv $PROJECTDIR $OLDDIR
mv $BUILDDIR $PROJECTDIR

sudo passenger-config restart-app "$PROJECTDIR"

rm -rf $OLDDIR
