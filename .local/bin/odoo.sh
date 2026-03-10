#!/bin/bash
set -e

# Check firefox image
if ! podman image ls --format "{{.Repository}}" | rg -q -F "localhost/archlinux-firefox"; then
    echo "Create firefox container."
    $HOME/Documents/containers/firefox/create_image.sh
fi

# Launch Network
if ! podman network ls --format "{{.Name}}" | grep -q "odoo_net"; then
    echo "Create odoo network."
    podman network create odoo_net --internal
fi

# Check db
if ! podman ps -a --format "{{.Names}}" | grep -q "db"; then
    echo "Run db."
    podman run -d --rm --name db \
        --net odoo_net \
        -v odoo_db:/var/lib/postgresql/data \
        -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres \
        docker.io/library/postgres:13
else
    podman container start db
fi

# Check odoo
if ! podman ps --format "{{.Names}}" | grep -q "odoo"; then
    echo "Run odoo."
    podman run -d --rm --name odoo -t \
        --net container:db \
        -v odoo_data:/var/lib/odoo \
        -v odoo_addon:/mnt/extra-addons \
        -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres \
        docker.io/library/odoo:14
fi

# Check firefox
if ! podman ps --format "{{.Names}}" | grep -q "odoo_firefox"; then
    echo "Launch firefox."
    podman run -d --rm \
        --net container:db \
        -e XDG_RUNTIME_DIR=/tmp \
        -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
        -e PULSE_SERVER=/tmp/pulse/native \
        -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY \
        -v $XDG_RUNTIME_DIR/pulse/native:/tmp/pulse/native \
        --name odoo_firefox \
        --umask 0077 \
        --userns keep-id \
        -v odoo_firefox:/home/user/.mozilla \
        -v /home/hugh/Desktop:/home/user/Desktop \
        -e MOZ_ENABLE_WAYLAND=1 \
        localhost/archlinux-firefox
fi

setsid /bin/bash -c "podman wait odoo_firefox; if podman container exists odoo; then podman container stop odoo; fi; if podman container exists db; then podman container stop db; fi;" 2>/dev/null >/dev/null </dev/null &



