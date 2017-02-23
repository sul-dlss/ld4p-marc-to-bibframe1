#!/bin/bash

# Bash function to convert one MARC-XML file to a Bibframe RDF file.
# Depends on the environment variables defined in ld4p_configure.sh
# Depends on installation of the loc marc2bibframe project.
# Usage:  loc_marc2bibframe {MRC_XML}
#
# Output RDF files are placed in
# "${LD4P_MARCRDF}/{MRC_XML_filename}.rdf"
#
# To replace exisiting MARC-RDF files, set
#LD4P_MARCRDF_REPLACE=true loc_marc2bibframe {MRC_XML}
#

export LOC_M2B_PATH="${LD4P_LIB}/loc_marc2bibframe"
export LOC_M2B_XQUERY="${LOC_M2B_PATH}/xbin/saxon.xqy"

loc_marc2bibframe () {
    MRC_XML=$1

    log_stamp=$(date --iso-8601=sec)

    filename=$(basename "${MRC_XML}" ".xml")
    MRC_RDF="${LD4P_MARCRDF}/${filename}.rdf"

    if [ "${MRC_XML}" -nt "${MRC_RDF}" -o ${LD4P_MARCRDF_REPLACE} == true ]; then
        # LD4P_MARCRDF_REPLACE can force replacement for any existing RDF
        # "${MRC_XML}" -nt "${MRC_RDF}" is:
        #   True if MRC_XML exists and MRC_RDF does not, or
        #   True if MRC_XML has been changed more recently than MRC_RDF.
        if [ -f "${MRC_RDF}" ]; then
            msg="${log_stamp}  REPLACED  MARC-RDF file: ${MRC_RDF}"
        else
            msg="${log_stamp}  CREATED   MARC-RDF file: ${MRC_RDF}"
        fi

        java -cp ${LD4P_JAR} \
            net.sf.saxon.Query ${LOC_M2B_XQUERY} \
                marcxmluri="file://${MRC_XML}" \
                baseuri=${LD4P_BASEURI} \
                serialization="rdfxml" \
                1> ${MRC_RDF} \
                2>> ${LD4P_MARCRDF_LOG}

        SUCCESS=$?
        if [ ${SUCCESS} ]; then
            if [ ${LD4P_ARCHIVE_ENABLED} == true ]; then
                # Archive the MRC_XML file (preserve timestamps etc.)
                rsync -a --update "${MRC_XML}" "${LD4P_ARCHIVE_MARCXML}/"
                rm ${MRC_XML}
            fi
        else
            msg="${log_stamp}  FAILED    MARC-RDF file: ${MRC_RDF}"
        fi

    else
        # The MRC_RDF file must exist and it must be newer than MRC_XML and
        # there is no forced replacement, so this conversion can be skipped.
        msg="${log_stamp}  SKIPPED   MARC-RDF file: ${MRC_RDF}"
        SUCCESS=0 # skipping an existing record is OK
    fi

    echo "${msg}" >> ${LD4P_MARCRDF_LOG}
    return ${SUCCESS}
}

