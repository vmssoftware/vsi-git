#!/bin/bash

GIT_TEST_SUITE_PATH=$GIT_TEST_SUITE
cd $GIT_TEST_SUITE_PATH
[ -d $1 ] && echo "Directory $1 exists." && exit

mkdir -p $1
cd $1
touch clean_test.com
touch runtest.com
touch $1.exp
