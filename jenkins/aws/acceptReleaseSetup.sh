#!/bin/bash

if [[ -n "${AUTOMATION_DEBUG}" ]]; then set ${AUTOMATION_DEBUG}; fi
trap 'exit ${RESULT:-1}' EXIT SIGHUP SIGINT SIGTERM

# Get all the deployment unit commit information
${AUTOMATION_DIR}/manageBuildReferences.sh -f \
    -g ${AUTOMATION_DATA_DIR}/${ACCOUNT}/config/${PRODUCT}/appsettings/${SEGMENT}
RESULT=$?
if [[ "${RESULT}" -ne 0 ]]; then exit; fi

# Include the build information in the detail message
${AUTOMATION_DIR}/manageBuildReferences.sh -l
RESULT=$?


