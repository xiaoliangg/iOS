#!/usr/bin/env bash

set -e # Fail if any command fails
set -x # Debug log

if [[ -z "${CI_PRIMARY_REPOSITORY_PATH}" ]]; then
  echo "Running CI script locally"
else
  pushd $CI_PRIMARY_REPOSITORY_PATH
fi

DIRECTORY_NAME=XcodeCloudResources

git clone "$XCODE_CLOUD_RESOURCES_URL" $DIRECTORY_NAME

ls -la $DIRECTORY_NAME/Fonts

cp $DIRECTORY_NAME/Fonts/*.otf "fonts/licensed"
