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
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#  
#--------------------------params------------------------+
# -p : make version permanent, save version in ./kit/VERSION.INI |
# -t : make version temporary, export into 
#--------------------------------------------------------+
#  

#gets this scripts path
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
version=$(cat $SCRIPT_DIR/kit/VERSION.INI | grep "VERSION = ")

export build_version=$version
