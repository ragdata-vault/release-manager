#!/usr/bin/env bash

# ==================================================================
# utilities.sh
# ==================================================================
# Release Manager
#
# File:         utilities.sh
# Author:       Ragdata
# Date:         03/09/2023
# License:      MIT License
# Copyright:    Copyright © 2023 Darren (Ragdata) Poulton
# ==================================================================
# FUNCTIONS
# ==================================================================
# ------------------------------------------------------------------
# utilities::hasValue
# ------------------------------------------------------------------
utilities::hasValue()
{
	local -r text="${1}"
	[[ -n "$text" ]]
}
# ------------------------------------------------------------------
# utilities::isEmpty
# ------------------------------------------------------------------
utilities::isEmpty()
{
	local -r text="${1}"
	[[ -z "$text" ]]
}
# ------------------------------------------------------------------
# utilities::countTags
# ------------------------------------------------------------------
utilities::countTags() { git tag | wc -l; }
# ------------------------------------------------------------------
# utilities::hasTags
# ------------------------------------------------------------------
utilities::hasTags()
{
	local -i total_tags
	if ! total_tags=$(utilities::countTags); then
		echo "No Tags to count"
		exit 1
	fi
	[[ "$total_tags" -ne 0 ]]
}
# ------------------------------------------------------------------
# utilities::isValidVersion
# ------------------------------------------------------------------
utilities::isValidVersion()
{
	local version="${1}"
	local -i -r MAX_LENGTH=256		# for package.json compatibility: https://github.com/npm/node-semver/blob/master/internal/constants.js
	if (( "${#version}" > MAX_LENGTH )); then
		echo "Version \"$version\" is too long (max: $MAX_LENGTH, vs: ${#version})"
		return 1
	fi
	if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
		echo "Version \"$version\" is invalid (must be in 'major.minor.patch' format)"
		return 1
	fi
	return 0
}
# ------------------------------------------------------------------
# utilities::latestVersion
# ------------------------------------------------------------------
utilities::latestVersion()
{
	[[ ! "$(utilities::hasTags)" ]] && exit 1
	local -r latest_tag="$(git tag | sort -V | tail -1)"
	[[ ! "$(utilities::isValidVersion "$latest_tag")" ]] && exit 1
	echo "$latest_tag"
}
# ------------------------------------------------------------------
# utilities::singleVersion
# ------------------------------------------------------------------
utilities::singleVersion()
{
	local -t total_tags
	if ! total_tags=$(utilities::countTags); then
		echo "No Tags to Count"
		exit 1
	fi
	[[ "$total_tags" -eq 1 ]] && return 0	# because there is only one tag
	return 1	# because there are either multiple tags or none
}
# ------------------------------------------------------------------
# utilities::previousVersion
# ------------------------------------------------------------------
utilities::previousVersion()
{
	local -i total_tags
	if ! total_tags="$(utilities::countTags)"; then
		echo "No Tags to Count"
		exit 1
	fi
	if [[ "$total_tags" -le 1 ]]; then
		echo "Found only one version"
		exit 1
	fi
	local -r previous_tag="$(git tag | sort -V | tail -2 | head -1)"
	if ! utilities::isValidVersion "$previous_tag"; then exit 1; fi
	echo "$previous_tag"
}
# ------------------------------------------------------------------
# utilities::fileExists
# ------------------------------------------------------------------
utilities::fileExists()
{
	local -r file="${1}"
	[[ -f "$file" ]]
}
# ------------------------------------------------------------------
# utilities::equals
# ------------------------------------------------------------------
utilities::equals() { [[ "${1,,}" = "${2,,}" ]]; }
