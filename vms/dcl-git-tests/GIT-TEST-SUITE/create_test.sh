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

GIT_TEST_SUITE_PATH=$GIT_TEST_SUITE
cd $GIT_TEST_SUITE_PATH
[ -d $1 ] && echo "Directory $1 exists." && exit

mkdir -p $1
cd $1
touch clean_test.com
touch runtest.com
touch $1.exp
