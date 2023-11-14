# This file is intendet to patch packages from pub.dev
#
# Path rive_common to remove build-id
RIVE_COMMON_VERSION="$(grep -A7 -P '^..rive_common' pubspec.lock | sed -E -n -e 's/^.*version:\ "([0-9.]+)"/\1/p')"

# get path to pub_cache directory
if [[ -v PUB_CACHE ]]; then
    PUB_PATH="$PUB_CACHE"
else
    PUB_PATH="$HOME/.pub-cache"
fi

patch -N "${PUB_PATH}/hosted/pub.dev/rive_common-${RIVE_COMMON_VERSION}/premake5_rive_plugin.lua" "rive_common.patch"
