# !/bin/bash
#
# Copyright (C) VMS Software Inc. (VSI) 2024

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
