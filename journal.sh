#!/usr/bin/env bash
# A script that manages daily journal

SCRIPT_PATH=$(dirname "$0")
JOURNAL_SH=$(basename "$0")

one_line_usage="${JOURNAL_SH} [-h] action action-param"

usage()
{
    cat <<-EndUsage
		Usage: ${one_line_usage}
		Try '${JOURNAL_SH} -h' for more information.
	EndUsage
    exit 1
}

main_help() {
    cat <<EndHelp
Program open to edit and display journal files in the favorite editor.
To see or change configuration, see file: ${SCRIPT_PATH}/journal.cfg

Usage: ${one_line_usage}

Options:
  -h             display this help message

Actions:
  log            open today journal file in your editor
  show           show journal files from period of time, see ${JOURNAL_SH}  show -h for more information
EndHelp
}

show_help() {
    cat <<EndHelp
show journal files from period of time

Periods:
  day            show today
  week           show current week
  month          show current month
EndHelp
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


file_path() {
    local name=$1
    local extension=$([ -z "$JOURNAL_FILE_EXTENSION" ] && echo "" || echo ".${JOURNAL_FILE_EXTENSION}")
    echo "${JOURNAL_PATH}/${name}${extension}"
}

add_time_tag() {
    local path=$1
    local time_tag=$(date +%T)
    printf "\n[${time_tag}]\n" >> ${path}
}

open_file_to_log() {
    local path=$1
    ${JOURNAL_EDITOR} ${path}
}

show_in_viewer() {
    local content=$1
    local viewer=${JOURNAL_VIEWER:-JOURNAL_EDITOR};
    echo "${content}" | ${viewer}
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

show_month() {
    local day_of_moth=$(date '+%-d')

    local i
    for (( i=$day_of_moth-1; i>=0; i-- )) do
        local date=$(date_minus_days ${i})
        if [ -f $(file_path ${date}) ]; then
	        printf "\n"
	        show_day ${date}
	        printf "\n"
        fi
    done
}

main() {
    import_config

    local action=${1:-${JOURNAL_DEFAULT_ACTION:-"log"}}

    case ${action} in
        "log")
            local path=$(file_path $(today_date))
            if ${ADD_TIME_TAG}; then
                add_time_tag ${path}
            fi
            open_file_to_log ${path}
        ;;
        "show")
            local what_to_show=${2:-${JOURNAL_DEFAULT_SHOW_ACTION:-"week"}}
            case ${what_to_show} in
                "day")
                    show_in_viewer "$(show_day $(today_date))"
                ;;
                "week")
                    show_in_viewer "$(show_week $(current_week))"
                ;;
                "month")
                    show_in_viewer "$(show_month)"
                ;;
                * )
                    show_help
                ;;
            esac
        ;;
        "-h")
            main_help
        ;;
        * )
        usage
        ;;
    esac
}
main $*