#! /bin/bash

ROOT_LOG_DIR=${1:-${ROOT_LOG_DIR:-/ceph/aeon/aeon/dj_store/logs}}
GET_LOGS_SINCE=${2:-${GET_LOGS_SINCE:-"24h"}}
SEARCH_CONTAINERS=${3:-${SEARCH_CONTAINERS:-"ingest_"}}

CIDS=()
CIDS+=($(docker ps --no-trunc -aqf name=${SEARCH_CONTAINERS}))

mkdir -p "${ROOT_LOG_DIR}"
find "${ROOT_LOG_DIR}"/docker_*.log -type f -mtime +6 -delete 2>/dev/null

write_container_logs() {
	local cid
	local cname
	local outfile
	if [[ $# -gt 0 ]]; then
		for cid in "$@"; do
			cname=$(docker ps --no-trunc -af id=$cid --format "{{.Names}}")
			outfile="${ROOT_LOG_DIR}/docker_${cname}.log"
			echo "Writing log: '$outfile'"
			docker logs --since $GET_LOGS_SINCE --timestamps $cid \
				2>&1 | tee "$outfile" >/dev/null
		done
	else
		echo "No container id's found using search: '${SEARCH_CONTAINERS}'"
	fi
}

write_container_logs "${CIDS[@]}"
