#!/bin/bash

if [[ -n "${AUTOMATION_DEBUG}" ]]; then set ${AUTOMATION_DEBUG}; fi
trap 'exit ${RESULT:-1}' EXIT SIGHUP SIGINT SIGTERM

# Defaults
TYPE_DEFAULT="application"

function usage() {
    cat <<EOF

Generate templates for one or more deployment units

Usage: $(basename $0) -u DEPLOYMENT_UNIT_LIST -s DEPLOYMENT_UNIT_LIST -c CONFIGURATION_REFERENCE -r REQUEST_REFERENCE -t TYPE

where

(m) -c CONFIGURATION_REFERENCE  is the id of the configuration (commit id, branch id, tag) used to generate the template
    -h                          shows this text
(o) -r REQUEST_REFERENCE        is an opaque value to link this template to a triggering request management system
(d) -s DEPLOYMENT_UNIT_LIST     same as -u
(m) -t TYPE                     is the template type - "account", "product", "segment", "solution" or "application"
(m) -u DEPLOYMENT_UNIT_LIST     is the list of deployment units to process

(m) mandatory, (o) optional, (d) deprecated

DEFAULTS:

TYPE = "${TYPE_DEFAULT}"

NOTES:

1. ACCOUNT, PRODUCT and SEGMENT must already be defined
2. All of the deployment units in DEPLOYMENT_UNIT_LIST must be the same type

EOF
    exit
}

# Parse options
while getopts ":c:hr:s:t:u:" opt; do
    case $opt in
        c)
            export CONFIGURATION_REFERENCE="${OPTARG}"
            ;;
        h)
            usage
            ;;
        r)
            export REQUEST_REFERENCE="${OPTARG}"
            ;;
        s)
            DEPLOYMENT_UNIT_LIST="${OPTARG}"
            ;;
        t)
            TYPE="${OPTARG}"
            ;;
        u)
            DEPLOYMENT_UNIT_LIST="${OPTARG}"
            ;;
        \?)
            echo -e "\nInvalid option: -${OPTARG}" >&2
            exit
            ;;
        :)
            echo -e "\nOption -${OPTARG} requires an argument" >&2
            exit
            ;;
     esac
done

# Apply defaults
export TYPE="${TYPE:-${TYPE_DEFAULT}}"

# Ensure mandatory arguments have been provided
if [[ (-z "${CONFIGURATION_REFERENCE}") ||
        (-z "${DEPLOYMENT_UNIT_LIST}") ||
        (-z "${TYPE}") ]]; then
    echo -e "\nInsufficient arguments" >&2
    exit
fi

cd ${AUTOMATION_DATA_DIR}/${ACCOUNT}/config/${PRODUCT}/solutions/${SEGMENT}

for CURRENT_DEPLOYMENT_UNIT in ${DEPLOYMENT_UNIT_LIST}; do

    # Generate the template for each deployment unit
    ${GENERATION_DIR}/createTemplate.sh -u "${CURRENT_DEPLOYMENT_UNIT}"
    RESULT=$?
    if [[ ${RESULT} -ne 0 ]]; then
 		echo -e "\nGeneration of template for deployment unit ${CURRENT_DEPLOYMENT_UNIT} failed" >&2
        exit
    fi

done

# All good
RESULT=0

