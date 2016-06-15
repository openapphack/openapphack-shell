#!/bin/bash


function __oah_cleanup_folder {
	OPENAPPHACK_CLEANUP_DIR="${OPENAPPHACK_DIR}/${1}"
	OPENAPPHACK_CLEANUP_DU=$(du -sh "$OPENAPPHACK_CLEANUP_DIR")
	OPENAPPHACK_CLEANUP_COUNT=$(ls -1 "$OPENAPPHACK_CLEANUP_DIR" | wc -l)

	rm -rf "${OPENAPPHACK_DIR}/${1}"
	mkdir "${OPENAPPHACK_DIR}/${1}"

	echo "${OPENAPPHACK_CLEANUP_COUNT} archive(s) flushed, freeing ${OPENAPPHACK_CLEANUP_DU}."

	unset OPENAPPHACK_CLEANUP_DIR
	unset OPENAPPHACK_CLEANUP_DU
	unset OPENAPPHACK_CLEANUP_COUNT
}

function __oah_flush {
	QUALIFIER="$1"
	case "$QUALIFIER" in
		candidates)
			if [[ -f "${OPENAPPHACK_DIR}/var/candidates" ]]; then
		        rm "${OPENAPPHACK_DIR}/var/candidates"
		        echo "Candidates have been flushed."
		    else
		        echo "No candidate list found so not flushed."
		    fi
		    ;;
		broadcast)
			if [[ -f "${OPENAPPHACK_DIR}/var/broadcast" ]]; then
		        rm "${OPENAPPHACK_DIR}/var/broadcast"
		        echo "Broadcast has been flushed."
		    else
		        echo "No prior broadcast found so not flushed."
		    fi
		    ;;
		version)
			if [[ -f "${OPENAPPHACK_DIR}/var/version" ]]; then
		        rm "${OPENAPPHACK_DIR}/var/version"
		        echo "Version Token has been flushed."
		    else
		        echo "No prior Remote Version found so not flushed."
		    fi
		    ;;
		vms)
			__oah_cleanup_folder ".vms"
				;;
		archives)
			__oah_cleanup_folder "archives"
		    ;;
		temp)
			__oah_cleanup_folder "tmp"
		    ;;
		tmp)
			__oah_cleanup_folder "tmp"
		    ;;
		*)
			echo "Stop! Please specify what you want to flush."
			;;
	esac
}
