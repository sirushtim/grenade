#!/usr/bin/env bash

# ``upgrade-ceilometer``

echo "*********************************************************************"
echo "Begin $0"
echo "*********************************************************************"

# Clean up any resources that may be in use
cleanup() {
    set +o errexit

    echo "*********************************************************************"
    echo "ERROR: Abort $0"
    echo "*********************************************************************"

    # Kill ourselves to signal any calling process
    trap 2; kill -2 $$
}

trap cleanup SIGHUP SIGINT SIGTERM

# Keep track of the grenade directory
RUN_DIR=$(cd $(dirname "$0") && pwd)

# Import common functions
source $GRENADE_DIR/functions

# Determine what system we are running on.  This provides ``os_VENDOR``,
# ``os_RELEASE``, ``os_UPDATE``, ``os_PACKAGE``, ``os_CODENAME``
# and ``DISTRO``
GetDistro

# Source params
source $GRENADE_DIR/grenaderc

# This script exits on an error so that errors don't compound and you see
# only the first error that occurred.
set -o errexit

# Print the commands being run so that we can see the command that triggers
# an error.  It is also useful for following allowing as the install occurs.
set -o xtrace

# Set for DevStack compatibility
TOP_DIR=$TARGET_DEVSTACK_DIR


# Upgrade Ceilometer
# ==================

# Get functions from current DevStack
source $TARGET_DEVSTACK_DIR/functions
source $TARGET_DEVSTACK_DIR/stackrc
source $TARGET_DEVSTACK_DIR/lib/stack

source $TARGET_DEVSTACK_DIR/lib/oslo
source $TARGET_DEVSTACK_DIR/lib/ceilometer

# install_ceilometer()
stack_install_service ceilometer

# calls upgrade-ceilometer for specific release
upgrade_project ceilometer $RUN_DIR $BASE_DEVSTACK_BRANCH $TARGET_DEVSTACK_BRANCH

# Migrate the database
$CEILOMETER_BIN_DIR/ceilometer-dbsync || die $LINENO "DB sync error"

# Start Ceilometer
start_ceilometer

set +o xtrace
echo "*********************************************************************"
echo "SUCCESS: End $0"
echo "*********************************************************************"
