#!/bin/bash

PROJECT="$1"
BUILDDIR="/srv/meteor-apps/$PROJECT"

# Check parameters
if [ $# -lt 2 ] ; then
	echo "Syntax; $0 project repository"
	echo ""
	echo "The type of repository is retrieved from the URL."
	echo "The build software is installed into $BUILDDIR."
	exit 1
fi

REPOSITORY="$2"
TMPDIR="/tmp/$PROJECT-$RANDOM"
REBUILD="$BUILDDIR/rebuild.sh"
REALPATH=`realpath $0`

# Set this variable, if you use a central meteor directory instead of ~/.meteor
# export METEOR_WAREHOUSE_DIR=/opt/meteor

# Checkout source code into temporary directory
mkdir -p "$TMPDIR"

if [ "${REPOSITORY:0:3}" = "svn" ] ; then
	svn checkout "$REPOSITORY" "$TMPDIR"
else
	git clone "$REPOSITORY" "$TMPDIR"
fi

# Build Meteor application
cd "$TMPDIR"
meteor npm install
meteor build "$BUILDDIR" --directory $BUILDFLAGS

# Save right version of node into $BUILDDIR
cp `meteor node -e 'console.log(process.argv[0])'` $BUILDDIR

# Install Meteor application and its dependencies
cd "$BUILDDIR/bundle/programs/server"
npm install
rm -rf "$TMPDIR"

# Restart app within passenger
sudo passenger-config restart-app "$BUILDDIR"

# Save build settings to file for easier rebuild
cat <<EOF > $REBUILD
#!/bin/sh

BUILDFLAGS="$BUILDFLAGS" $REALPATH $@
EOF

chmod 775 $REBUILD

echo "File to rebuild with the same parameters saved to $REBUILD"
