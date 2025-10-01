# !/bin/bash
#
# Copyright (C) VMS Software Inc. (VSI) 2024
#
# Needed OpenVMS build setups for GNV.
export GNV_CC_QUALIFIERS=/WAR="(DIS=(QUESTCOMPARE1, MAYLOSEDATA3))"

# Architecture name. By default the architecture of the current node the script is being run on is taken.
arch_name=$1
if [ -z "$arch_name" ]; then
	if cc --version | grep -q "X86"; then
		arch_name="X86"
	else
		arch_name=$(uname -p) # Returns the processor type or architecture of the system.
	fi
fi

# Determine project build directory based on architecture.
if [ "$arch_name" == "IA64" ]; then
	builddir="IA64_BUILD"
elif [ "$arch_name" == "X86" ]; then
	builddir="X86_64_BUILD"
fi

# List of additional directories to create.
additional_dirs=(
	"block-sha1"
	"builtin"
	"compat"
	"compat/fsmonitor"
	"compat/linux"
	"compat/nedmalloc"
	"compat/poll"
	"compat/regex"
	"compat/simple-ipc"
	"compat/stub"
	"compat/vcbuild"
	"compat/win32"
	"ewah"
	"negotiator"
	"oss-fuzz"
	"refs"
	"reftable"
	"sha1"
	"sha1dc"
	"sha256"
	"t"
	"t/helper"
	"t/unit-tests"
	"sha256/block"
	"trace2"
	"vms"
	"xdiff"
)

# Create the build directory if it doesn't exist.
parent_dir="$(dirname "$(dirname "$(readlink -f $0)")")"
build_path="$parent_dir/$builddir"

if [ ! -d "$build_path" ]; then
	mkdir -p "$build_path"
	echo "Created build directory: $build_path"
else
	echo "Build directory already exists: $build_path"
fi

# Loop through the additional directories and create them if they don't exist.
for dir in "${additional_dirs[@]}"; do
	if [ ! -d "$build_path/$dir" ]; then
		mkdir -p "$build_path/$dir"
		echo "Created directory: $build_path/$dir"
	fi
done

# Determine build mode.
build_mode=$2
if [ "$build_mode" != "DEBUG" ]; then
	build_mode="RELEASE"
fi

# Define the necessary variables in Makefile.
makefile="$parent_dir/vms/Makefile"

if [ -f "$makefile" ]; then
	# Delete the lines between the specified comments.
	sed -i '/# == OpenVMS defines\/undefines ==/,/# ===============================/ {
		/# == OpenVMS defines\/undefines ==/!{/# ===============================/!d}
	}' "$makefile"

	# Insert new variable definitions.
	sed -i '/# == OpenVMS defines\/undefines ==/a\
__VMS = 1\
SOURCE_DIR = '"$parent_dir"'\
ARCH_NAME = '"$arch_name"'\
VMS_BUILD_DIR = '"$builddir"'\
BUILD_MODE = '"$build_mode"'\n' "$makefile"

	echo "Variables defined in $makefile"
else
	echo "Makefile not found in the current directory"
fi

# Copy the Makefile to the build directory.
if cp $makefile $build_path; then
	echo "File '$makefile' copied to '$build_path'"
else
	echo "Error: Failed to copy file '$makefile' to '$build_path'"
	exit 1
fi
