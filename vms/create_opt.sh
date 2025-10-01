#!/bin/bash
# This script is called from buildall.com for creating version.opt file before make
vgit=/sys\$system/vgit2.exe 

if [ -f "$vgit" ]
then
	build_commit=$($vgit log -1 | grep "commit ")
	if [[ ${#build_commit} -eq 0 ]]
	then
		build_commit="commit 00000000"
	fi
else
	build_commit="commit 00000000"
fi

build_commit=${build_commit:7:8}

source ./vms/adjust_build_version.sh	-p

build_version=${build_version:10}

rm -f version.opt

cat >version.opt <<__ANYEOF
IDENTIFICATION="$build_version"
BUILD_IDENT="$build_commit"
__ANYEOF
