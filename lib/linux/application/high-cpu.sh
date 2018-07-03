#!/usr/bin/env bash

# Log

readonly LOG_STDOUT_FILE="${GEOFFREY_LOGS}/${GEOFFREY_APPLICATION_PREFIX}.stdout.log"
readonly LOG_STDERR_FILE="${GEOFFREY_LOGS}/${GEOFFREY_APPLICATION_PREFIX}.stderr.log"

exec > >(tee ${LOG_STDOUT_FILE}) 2> >(tee ${LOG_STDERR_FILE} >&2)

# Execution

if [ -n "$GEOFFREY_APPLICATION_JENKINS_USER_ID" ]; then
    GEOFFREY_APPLICATION_JSTACK_EXEC_FILE="sudo -u $GEOFFREY_APPLICATION_JENKINS_USER_ID $GEOFFREY_APPLICATION_JSTACK_EXEC_FILE"
    echo $(date) "Jenkins user $GEOFFREY_APPLICATION_JENKINS_USER_ID"
fi

# Create temporary directories
echo $(date) "Temporal dir ${GEOFFREY_APPLICATION_TEMP_DIR}"
mkdir -p ${GEOFFREY_APPLICATION_TEMP_DIR}
mkdir "${GEOFFREY_APPLICATION_TEMP_DIR}"/iostat "${GEOFFREY_APPLICATION_TEMP_DIR}"/jstack "${GEOFFREY_APPLICATION_TEMP_DIR}"/netstat "${GEOFFREY_APPLICATION_TEMP_DIR}"/topdashHOutput "${GEOFFREY_APPLICATION_TEMP_DIR}"/topOutput "${GEOFFREY_APPLICATION_TEMP_DIR}"/vmstat "${GEOFFREY_APPLICATION_TEMP_DIR}"/nfsiostat "${GEOFFREY_APPLICATION_TEMP_DIR}"/nfsstat

# Begin script and notify the end user
echo $(date) "The $(basename $0) script $SCRIPT_VERSION is starting in custom mode." && echo $(date) "The $(basename $0) script $SCRIPT_VERSION is starting in custom mode." >> "${GEOFFREY_APPLICATION_TEMP_DIR}"/mode.txt
echo $(date) "The pid is $PID" >> "${GEOFFREY_APPLICATION_TEMP_DIR}"/mode.txt
echo $(date) "The custom duration is $GEOFFREY_APPLICATION_DURATION" >> "${GEOFFREY_APPLICATION_TEMP_DIR}"/mode.txt
echo $(date) "The custom thread dump generation frequency is ${GEOFFREY_APPLICATION_FREQUENCY}" >> "${GEOFFREY_APPLICATION_TEMP_DIR}"/mode.txt


# Output the Default Settings to the end user
echo $(date) "The custom mode should only be used if requested && if data should be collected for longer than 1 minute"
echo $(date) "The $(basename $0) script will run for $GEOFFREY_APPLICATION_DURATION seconds."
echo $(date) "It will generate a full data generation (threadDump, iostat, vmstat, netstat, top) every ${GEOFFREY_APPLICATION_FREQUENCY} seconds."
echo $(date) ">>>>>>>>>>>>>>>The frequency Has To Divide into the duration by a whole integer.<<<<<<<<<<<<<<<"
echo $(date) ">>>>>>>>>>>>>>>The duration Divided by 60 should also be a whole integer.<<<<<<<<<<<<<<<"
echo $(date) ">>>>>>>>>>>>>>>The duration Divided by 5 should also be a whole integer.<<<<<<<<<<<<<<<"
echo $(date) ">>>>>>>>>>>>>>>Setting the frequency to low, i.e. 1 second, may cause the data to be inconclusive.<<<<<<<<<<<<<<<"

# Begin data generation once every $frequency seconds.
while [ $GEOFFREY_APPLICATION_DURATION -gt 0 ]
do
  # Taking top data collection
  echo $(date) "Taking top data collection."
  COLUMNS=300 top -bc -n 1 > "${GEOFFREY_APPLICATION_TEMP_DIR}"/topOutput/topOutput.$(date +%Y%m%d%H%M%S).txt &

  # Taking topdashH data collection
  echo $(date) "Taking TopdashH data collection."
  top -bH -p $PID -n 1 > "${GEOFFREY_APPLICATION_TEMP_DIR}"/topdashHOutput/topdashHOutput.$PID.$(date +%Y%m%d%H%M%S).txt &

  # Taking vmstat data collection in the background
  echo $(date) "Taking vmstat data collection."
  vmstat > "${GEOFFREY_APPLICATION_TEMP_DIR}"/vmstat/vmstat.$(date +%Y%m%d%H%M%S).out &

  # Taking netstat data
  echo $(date) "Taking netstat collection."
  netstat -pan > "${GEOFFREY_APPLICATION_TEMP_DIR}"/netstat/netstat.$(date +%Y%m%d%H%M%S).out &

  # Taking iostat data collection
  echo $(date) "Taking iostat data collection."
  if which iostat 2>/dev/null>/dev/null; then
        iostat -t > "${GEOFFREY_APPLICATION_TEMP_DIR}"/iostat/iostat.$(date +%Y%m%d%H%M%S).out &
      else
        echo $(date) "SEVERE: The command iostat was not found"
  fi

  # Taking nfsiostat data collection
  echo $(date) "Taking nfsiostat data collection."
  if which nfsiostat 2>/dev/null>/dev/null; then
        nfsiostat > "${GEOFFREY_APPLICATION_TEMP_DIR}"/nfsiostat/nfsiostat.$(date +%Y%m%d%H%M%S).out &
      else
        echo $(date) "SEVERE: The command nfsiostat was not found"
  fi

  # Taking nfsstat data collection
  echo $(date) "Taking nfsstat data collection."
  if which nfsstat 2>/dev/null>/dev/null; then
        nfsstat -c > "${GEOFFREY_APPLICATION_TEMP_DIR}"/nfsstat/nfsstat.$(date +%Y%m%d%H%M%S).out &
      else
        echo $(date) "SEVERE: The command nfsstat was not found"
  fi

  # Taking a threadDump
  $GEOFFREY_APPLICATION_JSTACK_EXEC_FILE -l $PID > "${GEOFFREY_APPLICATION_TEMP_DIR}"/jstack/"$GEOFFREY_APPLICATION_JSTACK_FILENAME" &
  echo $(date) "Collected a threadDump for PID $PID."

  wait

  if [ ! -s "${GEOFFREY_APPLICATION_TEMP_DIR}"/jstack/"$GEOFFREY_APPLICATION_JSTACK_FILENAME" ] ; then
    rm -r "${GEOFFREY_APPLICATION_TEMP_DIR}"
    echo "<<<<<<<<<<<<<<< ERROR: The script seems not to be launched with the same user jenkins is running. Try with sudo -u <JENKINS_USERID> >>>>>>>>>>>>>>>"
    exit 1
  fi

   # Pause for THREADDUMP_FREQUENCY seconds.
   echo $(date) "A new collection will start in ${GEOFFREY_APPLICATION_FREQUENCY} seconds."

   sleep ${GEOFFREY_APPLICATION_FREQUENCY}

   # Update duration
   GEOFFREY_APPLICATION_DURATION=`expr $GEOFFREY_APPLICATION_DURATION - ${GEOFFREY_APPLICATION_FREQUENCY}`
done

# Brief pause to make sure all data is collected.
echo $(date) "Packaging data and preparing for cleanup."

HERE="$(pwd)"

echo $(date) "Copying ${GEOFFREY_HIGH_CPU_OUTPUT_TAR}"
cd "${GEOFFREY_APPLICATION_TEMP_DIR}"
tar -cf "${GEOFFREY_HIGH_CPU_OUTPUT_TAR}" topOutput topdashHOutput mode.txt jstack vmstat netstat iostat nfsiostat nfsstat
rm -f "../${GEOFFREY_HIGH_CPU_OUTPUT_TAR}"
cp "${GEOFFREY_HIGH_CPU_OUTPUT_TAR}" ..

# GZip the tar file to create jenkinshangWithJstack.$pid.tar.gz
gzip "${GEOFFREY_HIGH_CPU_OUTPUT_TAR_GZ}"

echo $(date) "Cleanup files"
# Clean up the topOutput.txt and topdashHOutput.$pid.txt files
rm -r "${GEOFFREY_APPLICATION_TEMP_DIR}"

echo $(date) "Moving back to current dir $HERE"
cd ${HERE}

# Notify end user
echo $(date) "The temporary folder ${GEOFFREY_APPLICATION_TEMP_DIR} has been deleted"
echo $(date) "The $(basename $0) script in CUSTOM MODE is complete."
echo
echo $(date) "The Output files are contained within !>>>!   ${GEOFFREY_HIGH_CPU_OUTPUT_TAR_GZ}   !<<<!"
echo $(date) "Please upload the ${GEOFFREY_HIGH_CPU_OUTPUT_TAR_GZ} to your ticket for review."
exit 0