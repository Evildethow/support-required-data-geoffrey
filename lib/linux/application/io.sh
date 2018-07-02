#!/usr/bin/env bash -e

# Log

readonly LOG_STDOUT_FILE="${GEOFFREY_LOGS}/${GEOFFREY_APPLICATION_PREFIX}.stdout.log"
readonly LOG_STDERR_FILE="${GEOFFREY_LOGS}/${GEOFFREY_APPLICATION_PREFIX}.stderr.log"

exec > >(tee ${LOG_STDOUT_FILE}) 2> >(tee ${LOG_STDERR_FILE} >&2)

# Execution


export SESSION_ID="TEST_$(date +%s)"
export TIMEFORMAT='%S'

IO_TEST_LOG_FILE="${IO_TEST_LOG_FILE:-$(pwd)/io-test.log}"

if [ -f "$(which bc)" ]; then
  export IS_BC="true"
fi

if [ -f "$(which awk)" ]; then
  export IS_AWK="true"
fi

echo "usage : $0 [FOLDER] [TIMES] [PERIOD]"

if [ -z "$SESSION_ID" ]; then
    echo "Script can not create SESSION_ID"
    exit -1
fi

if [ $# -gt 0 ] && [ -d "$1" ]; then
  DIR="$1"
else
  echo "Enter a folder to check:"
  read DIR
fi

if [ ! -d "${DIR}" ]; then
    echo "The folder can not be empty"
    exit -1
fi

IOTEST_RUNS=${2:-"1"}
PERIOD=${3:-"30"}

SIZE_1K=1024
SIZE_10K=$((${SIZE_1K} * 10))
SIZE_100K=$((${SIZE_1K} * 100))
SIZE_1M=$((${SIZE_1K} * 1024))
SIZE_10M=$((${SIZE_1M} * 10))
SIZE_50M=$((${SIZE_1M} * 50))
SIZE_100M=$((${SIZE_1M} * 100))

function runWrite(){
    local times=$1
    local size=$2
    local file=$3
    local N=0
    while [ $N -lt ${times} ];
    do
      dd if=/dev/zero ${ddWriteOPs} of=${file} bs=${size} count=1 > /dev/null 2>&1
      N=$(($N+1))
    done
}

function runRead(){
    local times=$1
    local size=$2
    local file=$3
    local N=0
    while [ $N -lt ${times} ];
    do
      dd of=/dev/null ${ddReadOPs} if=${file} bs=${size} count=1 > /dev/null 2>&1
      N=$(($N+1))
    done
}

function runWriteRead(){
  runWrite $1 $2 $3
  runRead $1 $2 $3
}

function separator(){
    log "---------------------"
}

function log(){
    echo "$*"
    echo "$*" >> "${IO_TEST_LOG_FILE}"
}

function scaleSize(){
  local size=${1:-0}
  if [ ${size} -lt ${SIZE_1M} ]; then
    echo "$((${size}/1024))K";
  else
    echo "$((${size}/1024/1024))M"
  fi
}

function runWriteTest(){
  local num=${#tests[*]}
  local n=0
  local file=${DIR}/${SESSION_ID}
  separator
  log "Write test"

  while [ $n -lt $num ];
  do
    local item="${tests[n]}"
    local fields=(${item//:/ })
    local times=${fields[0]}
    local size=${fields[1]}
    local totalSize=$((${size} * ${times}))
    local time="$(time (runWrite ${times} ${size} ${file}) 2>&1 1>/dev/null )"

    if [ -f "${file}" ]; then
      rm "${file}"
      log "$(scaleSize ${size}) ${times} times in ${time} seconds, average $(statistics ${time} ${totalSize})"
    else
      log "No files written"
    fi

    n=$(($n+1))
  done
}

function statistics(){
  local time=$1
  local size=$2
  if [ "${IS_BC}" == "true" ]; then
    local av=$(echo "${size} / ${time}" | bc)
    echo "$(scaleSize $av)/s"
  elif [ "${IS_AWK}" == "true" ]; then
    local av=$(echo "${size} ${time}"|awk '{printf "%i",$1/$2}')
    echo "$(scaleSize $av)/s"
  else
    echo "$(scaleSize ${size})/${time}s"
  fi
}

function runWriteReadTest(){
  local num=${#tests[*]}
  local n=0
  local file=${DIR}/${SESSION_ID}
  separator
  log "Write/Read test"

  while [ $n -lt $num ];
  do
    local item="${tests[n]}"
    local fields=(${item//:/ })
    local times=${fields[0]}
    local size=${fields[1]}
    local totalSize=$((${size} * ${times}))
    local time="$(time (runWriteRead ${times} ${size} ${file}) 2>&1 1>/dev/null )"
    if [ -f "${file}" ]; then
      rm "${file}"
      log "$(scaleSize ${size}) ${times} times in ${time} seconds, average $(statistics ${time} ${totalSize})"
    else
      log "No files written/read"
    fi
    n=$(($n+1))
  done
}

function testDirectIO(){
  local file=${DIR}/${SESSION_ID}
  log "Test Direct IO flags"

  local unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)
        export ddReadOPs="iflag=sync"
        export ddWriteOPs="oflag=sync"
      ;;
      Darwin*)
        if [[ -f "/usr/local/opt/coreutils/libexec/gnubin/dd" ]]; then
          export PATH="/usr/local/opt/coreutils/libexec/gnubin":$PATH
          export ddReadOPs="iflag=sync"
          export ddWriteOPs="oflag=sync"
        else
          export ddReadOPs=""
          export ddWriteOPs=""
        fi
      ;;
      *)
        export ddReadOPs=""
        export ddWriteOPs=""
      ;;
  esac

  runWriteRead 1 ${SIZE_1K} ${file}
  if [ -f "${file}" ]; then
    rm "${file}"
  else
    log "Unset Direct IO flags"
    export ddReadOPs=""
    export ddWriteOPs=""
  fi

  if [ -z "${ddReadOPs}" ]; then
    log "Direct IO flags: false"
  else
    log "Direct IO flags: true"
  fi
}

#test[N]="times size"
tests[0]="1 ${SIZE_1M}"
tests[1]="10 ${SIZE_1M}"
tests[2]="100 ${SIZE_1M}"

tests[3]="1 ${SIZE_10M}"
tests[4]="10 ${SIZE_10M}"
tests[5]="100 ${SIZE_10M}"

tests[6]="1 ${SIZE_50M}"
tests[7]="10 ${SIZE_50M}"

tests[8]="1 ${SIZE_100M}"
tests[9]="10 ${SIZE_100M}"

tests[10]="1000 ${SIZE_1K}"
tests[11]="10000 ${SIZE_1K}"
tests[12]="100 ${SIZE_10K}"
tests[13]="1000 ${SIZE_10K}"
tests[14]="100 ${SIZE_100K}"
tests[15]="1000 ${SIZE_100K}"

log "${SESSION_ID}"
log "Test running in folder : ${DIR}"

testDirectIO

M=0
while [ ${M} -lt ${IOTEST_RUNS} ];
do
  log "Run #${M}"
  runWriteTest
  runWriteReadTest
  M=$(($M+1))
  if [ ${M} -lt ${IOTEST_RUNS} ]; then
    sleep ${PERIOD}s
  fi
done
