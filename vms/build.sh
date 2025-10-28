# !/bin/bash
#
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

# Ensure BUILD_DIR is passed as an argument.
if [ -z "$1" ]; then
	echo "[ERROR] Missing argument for BUILD_DIR."
	exit 1
fi

BUILD_DIR="${1}_BUILD"
# Convert BUILD_DIR to uppercase for consistency.
BUILD_DIR=$(echo "$BUILD_DIR" | tr '[:lower:]' '[:upper:]')
echo "[INFO] BUILD_DIR set to $BUILD_DIR"

echo "[INFO] Building for $ARCH_NAME..."

# Check if the build directory exists.
if [ ! -d "$BUILD_DIR" ]; then
	echo "[ERROR] Build directory $BUILD_DIR does not exist."
	exit 1
fi

cd "$BUILD_DIR" || {
	echo "[ERROR] Failed to enter directory $BUILD_DIR"
	exit 1
}
# Needed OpenVMS build setups for GNV.
export GNV_CC_QUALIFIERS=/WAR="(DIS=(QUESTCOMPARE1, MAYLOSEDATA3))"

# Run the build process and check for success.
if make; then
	echo "[INFO] Build succeeded."
	cd .. || {
		echo "[ERROR] Failed to return to the parent directory."
		exit 1
	}
else
	echo "[FATAL] Build failed."
	cd .. || {
		echo "[ERROR] Failed to return to the parent directory."
		exit 1
	}
	exit 1
fi
