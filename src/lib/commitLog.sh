#!/usr/bin/env bash
# shellcheck disable=SC2034
# ==================================================================
# commitLog.sh
# ==================================================================
# Release Manager
#
# File:         commitLog.sh
# Author:       Ragdata
# Date:         03/09/2023
# License:      MIT License
# Copyright:    Copyright © 2023 Darren (Ragdata) Poulton
# ==================================================================
# VARIABLES
# ==================================================================
readonly RM_BIN="$(dirname "$0")"
readonly RM_LIB="$(dirname "$(dirname "$0")")"
readonly PLACEHOLDER="{{version}}"
# ==================================================================
# DEPENDENCIES
# ==================================================================
source "$RM_LIB"/utilities.sh
# ==================================================================
# FUNCTIONS
# ==================================================================
# ------------------------------------------------------------------
# regex::escape
# ------------------------------------------------------------------
regex::escape()
{
	local -r text="${1}"
	echo "$text" | sed -e 's/[\/&]/\\&/g'
}
# ------------------------------------------------------------------
# commit::validateRef
# ------------------------------------------------------------------
commit::validateRef()
{
	local ref="${1}"
	if ! git merge-base --is-ancestor "$ref" HEAD; then
		echo "Reference does not exist in the current branch '$1'"
		exit 1
	fi
}
# ==================================================================
# MAIN
# ==================================================================
[[ "$#" -lt 3 ]] && { echo "Missing Argument!"; exit 1; }

commit::validateRef "${PREVIOUS}" && commit::validateRef "${CURRENT}"

declare commitLineStart="* "
declare lineStartPattern
declare versionPattern="(([v]?[\-]?)([0-9]+)\+.([0-9]+)\+\.([0-9]+))"	# version must be escaped to match this pattern

if ! lineStartPattern="$(regex::escape "$commitLineStart")"; then
	echo "Could not escape regex (noooooo...)"
	exit 1
fi

git log "${PREVIOUS}".."${CURRENT}" \
	--pretty-format:"$commitLineStart%s | [%h](https://github.com/$REPOSITORY/commit/%H)" \
	--reverse \
		| grep -v Merge \
		| sed "/^${commitLineStart}.*${versionPattern}/d;" \
		| sed "/^${commitLineStart}Merge PR/d;" \
		| sed "/^${commitLineStart}Merge pull request/d;" \
		| sed "/^${commitLineStart}Merge branch/d;"
