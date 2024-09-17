#!/bin/bash

# The version of the AdaCore installers to grab
# In the future, maybe make this dynamic
VERSION="24.2"
ZIPFILE="AdaCore-$VERSION.zip"
HASHFILE="AdaCore-$VERSION.md5"


# Prompt the user for the lemuria credentials, in order to download the zip archive
echo "Please enter your credentials to authenticate to: lemuria.cis.vermontstate.edu"
read -p "Username: " USERNAME
read -sp "Password: " PASSWORD
echo

# Conditional short circuiting allows us to avoid re-downloading an existing file
[[ -f $ZIPFILE ]] || wget --user $USERNAME --password $PASSWORD \
    http://lemuria.cis.vermontstate.edu/CubeSat/Installers/$ZIPFILE

[[ -f $HASHFILE ]] || wget --user $USERNAME --password $PASSWORD \
    http://lemuria.cis.vermontstate.edu/CubeSat/Installers/$HASHFILE

echo
echo "Validating checksum..."
echo

# Check the hash to make sure our download came through ok
CHECKSUM=$(md5sum $ZIPFILE)

# Bail out if it fails to validate
if [ "$CHECKSUM" != "$(cat $HASHFILE)" ]; then
    echo "Checksum failed to vefify!"
    echo "$ZIPFILE hashed to:"
    echo "$CHECKSUM"
    echo "Expected:"
    echo "$(cat $HASHFILE)"

    exit 1
fi

echo "Checksum validated!"
echo

# Don't extract if there directory already exists
if [ ! -d AdaCore ]; then
    echo "Unzipping archive..."
    python -m zipfile -e $ZIPFILE .
    echo "Extraction complete!"
fi

 # Move into the AdaCore Directory
echo "Moving into ./AdaCore/"
cd AdaCore

# Find all the .tar.gz files and extract them
find . -type f -name "*-bin.tar.gz" -exec tar -xzf {} \;

# Install

# Change our install context based on single user or all users
RUN_USER=$(whoami)
INSTALL_ROOT="$HOME/.ada_spark"

read -r -p "Would you like to install for all users? (Requires sudo privileges) [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    RUN_USER="root"
    INSTALL_ROOT="/opt"
fi

for installer in *-bin/; do
    cd $installer
    folder=$( echo $installer | cut -d"-" -f1 )ls
    sudo -u $RUN_USER ./doinstall $INSTALL_ROOT/$folder
    cd ..
done

echo "Please add the following directories to your path:"
echo $INSTALL_ROOT/*/bin
echo
echo "Also include the following exports for Ada language libraries:"
echo "GPR_PROJECT_PATH=$INSTALL_ROOT/libadalang/share/gpr:$GPR_PROJECT_PATH"
echo "LIBRARY_PATH=$INSTALL_ROOT/libadalang/lib:$LIBRARY_PATH"
echo "LD_LIBRARY_PATH=$INSTALL_ROOT/libadalang/lib:$LD_LIBRARY_PATH"
echo "export GPR_PROJECT_PATH LIBRARY_PATH LD_LIBRARY_PATH"
echo
echo "If you installed for all users, you may wish to add this to /etc/environment"

read -r -p "Would you like to clean up downloaded files? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    cd ..
    rm -rf AdaCore*
fi
