#!/bin/bash


function __oah_uninstall {
	CANDIDATE="$1"
	VERSION="$2"
	__oah_check_candidate_present "${CANDIDATE}" || return 1
	__oah_check_version_present "${VERSION}" || return 1
	CURRENT=$(readlink "${OPENAPPHACK_DIR}/.vms/${CANDIDATE}/current" | sed "s_${OPENAPPHACK_DIR}/.vms/${CANDIDATE}/__g")
	if [[ -h "${OPENAPPHACK_DIR}/.vms/${CANDIDATE}/current" && ( "${VERSION}" == "${CURRENT}" ) ]]; then
		echo ""
		echo "Unselecting ${CANDIDATE} ${VERSION}..."
		unlink "${OPENAPPHACK_DIR}/.vms/${CANDIDATE}/current"
	fi
	echo ""
	if [ -d "${OPENAPPHACK_DIR}/.vms/${CANDIDATE}/${VERSION}" ]; then
		echo "Uninstalling ${CANDIDATE} ${VERSION}..."
		rm -rf "${OPENAPPHACK_DIR}/.vms/${CANDIDATE}/${VERSION}"
	else
		echo "${CANDIDATE} ${VERSION} is not installed."
	fi
}
