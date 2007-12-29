#!/bin/sh

set -e

# A script that's used to extract a release candidate out of trunk.
# The trunk version must always be a checked-in version, i.e., a
# revision number needs to be qualified when running "svn export" to
# ensure release candidates match a certain SVN revision exactly.

# The script does the following:
#
# 1) Extract trunk revision rNNN to directory t/extlib-x.y.z.
# 2) Create a tarball out of the directory (extlib-x.y.z.tar.gz)
# 3) Create a distinfo file to be used by the GODI package

error_wrong_dir ()
{
    echo "Wrong working directory."
    echo "You need to be at top of the tree /svn"
    exit 1
}

# Check that we're in the right location
if [ ! -d util ]; then
    error_wrong_dir
fi

# Check that we're in the right location
if [ ! -d trunk ]; then
    error_wrong_dir
fi

if [ -d tmp ]; then
    echo "Directory tmp already exists.  Please remove the "
    echo "directory before trying to create a new release package."
    exit 1
fi

# Parse the command line:
TRUNK_REV=""
VERSION=""
while test -n "$1"; do
    case "$1" in
        "")
            echo "Invalid command line"
            exit 1 ;;
        -r)
            shift
            TRUNK_REV=$1 ;;

        -v)
            shift
            VERSION=$1 ;;
        
        *)
            echo "Invalid command line option \"$1\""
            exit 1
    esac
    shift
done

if [ "$TRUNK_REV" = "" ]; then
    echo "Need to specify SVN trunk revision"
    exit 1
fi

if [ "$VERSION" = "" ]; then
    echo "Need to specify extlib version (major.minor.patch)"
    exit 1
fi

echo "Creating release for revision $TRUNK_REV"

mkdir -p tmp
cd tmp
svn export -r $TRUNK_REV http://ocaml-extlib.googlecode.com/svn/trunk extlib

TARBALL=extlib-$VERSION.tar.gz
# Create the release tarball
cp -R extlib/extlib extlib-$VERSION
tar cf extlib-$VERSION.tar extlib-$VERSION
gzip extlib-$VERSION.tar

# Create GODI distinfo
sha1=`sha1sum $TARBALL|cut -d " " -f 1`
sz=`cat $TARBALL|wc -c`

echo "\$NetBSD\$" > distinfo
echo "" >> distinfo
echo "SHA1 ($TARBALL) = $sha1" >> distinfo
echo "Size ($TARBALL) = $sz bytes" >> distinfo
