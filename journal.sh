#!/usr/bin/env bash
# A script that manages daily journal

SCRIPT_PATH=$(dirname "$0")
JOURNAL_DEFAULT_ACTION="open"
JOURNAL_DEFAULT_SHOW_ACTION="week"

help() {
    echo "To be done"
}

help_show() {
    echo "To be done"
}

die() {
    echo "$*"
    exit 1
}

import_config() {
    source ${SCRIPT_PATH}/journal.cfg
    [ -z "$JOURNAL_PATH" ] && die "JOURNAL_PATH has to be defined"
    [ -z "$JOURNAL_EDITOR" ] && die "JOURNAL_EDITOR has to be defined"
}

today_date() {
    echo $(date +%Y-%m-%d)
}

date_minus_days() {
    local minus_days=$1
    echo $(date -v-${minus_days}d +%Y-%m-%d)
}

current_week() {
    echo $(date +%V)
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

open_file() {
    local path=$1
    ${JOURNAL_EDITOR} ${path}
}

show_header() {
    local date=$1
    printf "\n${date}\n$(printf -- -%.0s {1..50})\n"
}

show_day() {
    local date=$1
    show_header ${date}
    cat $(file_path ${date})
}

show_week() {
    local week_to_show=$1
    [ "$week_to_show" -gt "$(current_week)" ] && die "You can not show a week from future"

    local days_to_adjust=$((  ($(current_week) - ${week_to_show}) * 7 ))
    local day_of_week=$(date +%u)

    local i
    for (( i=$day_of_week-1; i>=0; i-- )) do
        local date=$(date_minus_days $(( ${i}+days_to_adjust )))
        if [ -f $(file_path ${date}) ]; then
	        printf "\n"
	        show_day ${date}
	        printf "\n"
        fi
    done
}

main() {
    import_config

    local action=${1:-$JOURNAL_DEFAULT_ACTION}

    case ${action} in
        "open")
            open_file $(file_path $(today_date))
        ;;
        "show")
            local what_to_show=${2:-$JOURNAL_DEFAULT_SHOW_ACTION}
            case ${what_to_show} in
                "day")
                    show_day $(today_date)
                ;;
                "week")
                    show_week $(current_week)
                ;;
                * )
                help_show
            esac
        ;;
        * )
        help
        ;;
    esac
}
main $*