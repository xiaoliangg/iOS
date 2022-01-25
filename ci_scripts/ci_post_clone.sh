#!/bin/bash

export HOMEBREW_NO_INSTALL_CLEANUP=1

DIRECTORY="$(cd "$(dirname "$0")" && pwd)"

brew install swiftlint

$DIRECTORY/install_xcode_cloud_resources.sh
