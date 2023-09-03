#!/usr/bin/env bash

# ==================================================================
# entrypoint.sh
# ==================================================================
# Release Manager
#
# File:         entrypoint.sh
# Author:       Ragdata
# Date:         03/09/2023
# License:      MIT License
# Copyright:    Copyright © 2023 Darren (Ragdata) Poulton
# ==================================================================
# Parameters are normalized to ensure that the Dockerfile can be
# called using a variety of ways to pass in parameters:
#
#	1. Double-Quoted Parameters
#		eg: "--parameter value" "--parameter2 value"
#		Designed for GitHub Actions because actions.yml args are sent like this
#		Parameters are parsed and sent unquoted
#	2. Parameter Value Chain
#		This is the most common usage - parameters are sent as they are
#		eg: --parameter value --parameter2 value
#
# See ./tests/entrypoint.sh for instructions on testing locally
# ==================================================================
# FUNCTIONS
# ==================================================================
# ------------------------------------------------------------------
# parseParameters
# ------------------------------------------------------------------
parseParameters()
{
	local -r value="${1}"
	if startsWith "$value" '--' && includes "$value" ' '; then
		return 0
	else
		return 1
	fi
}
# ------------------------------------------------------------------
# includes
# ------------------------------------------------------------------
includes()
{
	local -r value="${1}"
	local -r prefix="${2}"
	[[ $value = $prefix* ]]
}
# ------------------------------------------------------------------
# startsWith
# ------------------------------------------------------------------
startsWith()
{
	local -r value="${1}"
	local -r pattern="${2}"
	[[ $value =~ $pattern ]]
}
# ==================================================================
# MAIN
# ==================================================================
parameters=()

for part in "$@"
do
	if parseParameters "$part"; then
		name="${part%% *}"
		value="${part#* }"
		parameters+=("$name" "$value")
	else
		parameters+=("$part")
	fi
done

echo "[entrypoint.sh] Parameters:" "${parameters[@]}"

thisDir="$(dirname "$0")"

bash "$thisDir"/src/bin/release-manager "${parameters[@]}"
