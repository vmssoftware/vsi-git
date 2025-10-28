#!/bin/bash
# Copyright (C) 2025 VMS Software, Inc.
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation version 2 of the License.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see https://www.gnu.org/licenses/
#
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
