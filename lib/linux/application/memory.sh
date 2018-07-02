#!/usr/bin/env bash

# Log

readonly LOG_STDOUT_FILE="${GEOFFREY_LOGS}/${GEOFFREY_APPLICATION_PREFIX}.stdout.log"
readonly LOG_STDERR_FILE="${GEOFFREY_LOGS}/${GEOFFREY_APPLICATION_PREFIX}.stderr.log"

exec > >(tee ${LOG_STDOUT_FILE}) 2> >(tee ${LOG_STDERR_FILE} >&2)

# Execution

# Generate jmap output
date >> jmapHeapOutput.${PID}.txt
jmap -heap ${PID} >> jmapHeapOutput.${PID}.txt
echo $(date) "jmapHeapOutput.${PID}.txt file generated."
date >> jmapHistoOutput.${PID}.txt
jmap -histo -F ${PID} >> jmapHistoOutput.${PID}.txt
echo $(date) "jmapHistoOutput.${PID}.txt file generated."

# Brief pause to make sure all data is collected.
echo $(date) "Packaging data and preparing for cleanup."
sleep 10

tar -cvf ${GEOFFREY_APPLICATION_MEMORY_ARCHIVE} jmapHeapOutput.${PID}.txt jmapHistoOutput.${PID}.txt

# GZip the tar file to create jenkinsjmap.${PID}.tar.gz
gzip ${GEOFFREY_APPLICATION_MEMORY_ARCHIVE}

# Clean up the jmapHeapOutput.${PID}.txt and jmapHistoOutput.${PID}.txt files
rm jmapHeapOutput.${PID}.txt
rm jmapHistoOutput.${PID}.txt

# Notify end user
echo $(date) "The jmapHeapOutput.${PID}.txt and jmapHistoOutput.${PID}.txt files have been removed."
echo $(date) "The $(basename $0) script is complete."
echo
echo $(date) "Please upload the ${GEOFFREY_APPLICATION_MEMORY_ARCHIVE}.gz file to your ticket for review."

##############################################################################################################################

# Generate jmap output
date >> jmapHeapOutput.${PID}.txt
jmap -heap ${PID} >> jmapHeapOutput.${PID}.txt
echo $(date) "jmapHeapOutput.${PID}.txt file generated."
date >> jmapHistoOutput.${PID}.txt
jmap -histo -F ${PID} >> jmapHistoOutput.${PID}.txt
echo $(date) "jmapHistoOutput.${PID}.txt gile generated."

# Generate a heap dump
jmap -dump:live,format=b,file=${GEOFFREY_APPLICATION_HEAP_DUMP_FILE} -F ${PID}
echo $(date) "${GEOFFREY_APPLICATION_HEAP_DUMP_FILE} file generated."

# Brief pause to make sure all data is collected.
echo $(date) "Packaging data and preparing for cleanup."
sleep 10

tar -cvf ${GEOFFREY_APPLICATION_MEMORY_ARCHIVE} jmapHeapOutput.${PID}.txt jmapHistoOutput.${PID}.txt
tar -cvf ${GEOFFREY_APPLICATION_HEAP_DUMP_TAR} ${GEOFFREY_APPLICATION_HEAP_DUMP_FILE}

# GZIP
gzip ${GEOFFREY_APPLICATION_MEMORY_ARCHIVE}
gzip ${GEOFFREY_APPLICATION_HEAP_DUMP_TAR}

# Clean up the jmapHeapOutput.${PID}.txt, jmapHistoOutput.${PID}.txt, and heap dump files
rm jmapHeapOutput.${PID}.txt
rm jmapHistoOutput.${PID}.txt
rm ${GEOFFREY_APPLICATION_HEAP_DUMP_FILE}

# Notify end user
echo $(date) "The jmapHeapOutput.${PID}.txt, jmapHistoOutput.${PID}.txt, ${GEOFFREY_APPLICATION_HEAP_DUMP_FILE} files have been removed."
echo $(date) "The $(basename $0) script is complete."
echo
echo $(date) "Please upload the ${GEOFFREY_APPLICATION_MEMORY_TAR_GZ}, and ${GEOFFREY_APPLICATION_HEAP_DUMP_TAR_GZ} files to your ticket for review."