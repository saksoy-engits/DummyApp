#!/bin/bash

# Define paths
BUILD_DIR="build"
OPENVDB_INSTALL_DIR="${BUILD_DIR}/openvdb_install"
BACKUP_DIR="build_backup"  # New backup folder outside of build

# Create a backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Check if the OpenVDB install directory exists
if [ -d "$OPENVDB_INSTALL_DIR" ]; then
  echo "Backing up OpenVDB installation to $BACKUP_DIR/openvdb_install"
  # Copy OpenVDB installation to the backup folder
  cp -r $OPENVDB_INSTALL_DIR $BACKUP_DIR/
else
  echo "OpenVDB installation directory not found: $OPENVDB_INSTALL_DIR"
fi

# Backup any additional directories you might want to preserve (e.g., other libs, etc.)
# You can uncomment and customize these lines as needed
# For example, backing up the external submodule folder
# EXTERNAL_DIR="${BUILD_DIR}/external"
# if [ -d "$EXTERNAL_DIR" ]; then
#   echo "Backing up external libraries to $BACKUP_DIR/external"
#   cp -r $EXTERNAL_DIR $BACKUP_DIR/
# fi

# You can also add more directories to backup as needed

echo "Backup completed."

# End of the script

# Usage:
# chmod +x backup_build.sh
#./backup_build.sh
