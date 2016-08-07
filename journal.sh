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

main() {
  import_config
  echo ${JOURNAL_EDITOR}
}
main
