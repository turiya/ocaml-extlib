#!/bin/sh

# A script that's used to extract a release candidate out of trunk.
# The trunk version must always be a checked-in version, i.e., a
# revision number needs to be qualified when running "svn export" to
# ensure release candidates match a certain SVN revision exactly.

# The script does the following:
#
# 1) Extract trunk revision rNNN to directory t/extlib-x.y.z.
# 2) Create a tarball out of the directory (extlib-x.y.z.tar.gz)
# 3) Create a distinfo file to be used by the GODI package

echo "Not ready yet"
exit 1
