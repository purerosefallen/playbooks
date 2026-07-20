#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
parent_dir=$(dirname -- "$script_dir")

ensure_linked_repository() {
    repository_name=$1
    repository_url=$2
    link_path=$3
    link_target=$4
    repository_path="$parent_dir/$repository_name"

    if [ ! -e "$repository_path" ]; then
        git clone "$repository_url" "$repository_path"
    elif [ ! -d "$repository_path" ]; then
        echo "error: $repository_path exists but is not a directory" >&2
        return 1
    fi

    if [ -L "$link_path" ]; then
        return 0
    fi

    if [ -e "$link_path" ]; then
        echo "error: $link_path exists but is not a symbolic link" >&2
        return 1
    fi

    ln -s "$link_target" "$link_path"
}

ensure_linked_repository \
    init \
    https://code.moenext.com/mycard/init.git \
    "$script_dir/roles/init" \
    ../../init

ensure_linked_repository \
    services \
    https://code.moenext.com/nanahira/services.git \
    "$script_dir/files/services" \
    ../../services
