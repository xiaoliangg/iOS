#!/usr/bin/env bash

set -e # Fail if any command fails
set -x # Debug log

pwd

DIRECTORY_NAME=XcodeCloudResources

git clone "$XCODE_CLOUD_RESOURCES_URL" $DIRECTORY_NAME

ls -la $DIRECTORY_NAME/Fonts

cp $DIRECTORY_NAME/Fonts/*.otf "fonts/licensed"
