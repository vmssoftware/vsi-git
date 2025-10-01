#!/bin/bash	
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