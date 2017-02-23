#!/bin/bash

# To replace existing MARC-RDF files, run this script with
#LD4P_MARCRDF_REPLACE=true

LOG_DATE=$(date +%Y%m%dT%H%M%S)
export LD4P_MARCRDF_LOG="${LD4P_LOGS}/Marc2bibframe_${LOG_DATE}.log"
echo "Converter logs to LD4P_MARCRDF_LOG: ${LD4P_MARCRDF_LOG}"

# Source bash function to run converter
source ./loc_marc2bibframe.sh

echo
echo "Searching for MARC-XML files: ${LD4P_MARCXML}/*.xml"
for XML_FILE in `find ${LD4P_MARCXML} -type f -name '*.xml' | sort`
do
    loc_marc2bibframe ${XML_FILE}
done
