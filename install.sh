#!/usr/bin/env bash

# Provide a nice wrapper for using the keepassxc docker container

# Set these to where you normally keep your stuff
IMG_TAG="westonsteimel/keepassxc:latest"
KEEPASSXC_CONFIG="${HOME}/.config/keepassxc"
KEEPASSXC_DATABASES="${HOME}/kdbx"
KEEPASSXC_DESKTOP="${HOME}/Desktop/keepassxc.desktop"
KEEPASSXC_HELPER_DIR="${HOME}/bin"
KEEPASSXC_HELPER="${KEEPASSXC_HELPER_DIR}/keepassxc.sh"

# Make sure the config location is present and owned by your user
# Use the short option version here so it works on both Linux and macOS
if [ ! -d "${KEEPASSXC_CONFIG}" ]; then
    mkdir -p "${KEEPASSXC_CONFIG}"
fi

# Make sure the helper script location actually exists.
if [ ! -d "${KEEPASSXC_HELPER_DIR}" ]; then
    mkdir -p "${KEEPASSXC_HELPER_DIR}"
fi

# Build the container image
docker build \
    --file stable/Dockerfile \
    --tag ${IMG_TAG} \
    .

# Prepare the helper wrapper script for running this container image
HELPER="docker run \
    --detach \
    --env "DISPLAY=unix${DISPLAY}" \
    --volume "${KEEPASSXC_CONFIG}:/home/keepassxc/.config/keepassxc" \
    --volume "${KEEPASSXC_DATABASES}:/home/keepassxc/kdbx" \
    --volume /etc/machine-id:/etc/machine-id:ro \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume /usr/share/X11/xkb:/usr/share/X11/xkb/:ro \
    ${IMG_TAG}"
echo "${HELPER}" > "${KEEPASSXC_HELPER}"
chmod +x "${KEEPASSXC_HELPER}"

# Prepare a helpful (GNOME) desktop icon for launching this application
DESKTOP="[Desktop Entry]
Comment=
Exec=${KEEPASSXC_HELPER}
Icon=preferences-system-privacy
Name=keepassxc
Terminal=false
Type=Application"
echo "${DESKTOP}" > "${KEEPASSXC_DESKTOP}"
chmod +x "${KEEPASSXC_DESKTOP}"
