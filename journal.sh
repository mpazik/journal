#!/usr/bin/env bash
# A script that manages daily journal

die() {
    echo "$*"
    exit 1
}

import_config() {
    source ./journal.cfg
    [ -z "$JOURNAL_PATH" ] && die "JOURNAL_PATH has to be defined"
    [ -z "$JOURNAL_EDITOR" ] && die "JOURNAL_EDITOR has to be defined"
}

today_date() {
    echo $(date +%Y-%m-%d)
}

file_name() {
    local date=$1
    local extension=$([ -z "$JOURNAL_FILE_EXTENSION" ] && echo "" || echo ".${JOURNAL_FILE_EXTENSION}")

    echo ${date}${extension}
}

file_path() {
    local date=$1
    echo "${JOURNAL_PATH}/$(file_name ${date})"
}

main() {
    import_config
    file_path $(today_date)
}
main
