#!/bin/sh

function ONLINE_LANE_MERGE()
{
	local I_DIR O_DIR NCOLS HEAD CMD READSTR CMD_R1 CMD_R2 H R
	I_DIR=$1
	I_DIR=$(cd $I_DIR && pwd)
	O_DIR=$2
	O_DIR=$(cd $O_DIR && pwd)
	NCOLS=$(cd ${I_DIR} && ls -1 *.fastq | head -n1 | awk -F_ '{print NF}')
    if ! (( ${NCOLS} == "1" || ${NCOLS} == "2" )); then
        echo "Unexpected File Name Format. Exiting"
        return 0
    fi
	TOTAL_SAMPLES=$(cd ${I_DIR} && ls -1 *.fastq | wc -l)
	UNIQ_SAMPLES=$(cd ${I_DIR} && ls -1 *.fastq | sed 's\.fastq\\g' | awk -F_ '{print$1}' | sort | uniq | wc -l)
	RESULT=$(awk "BEGIN {printf \"%.1f\",${TOTAL_SAMPLES}/${UNIQ_SAMPLES}}")
	if [[ "${RESULT}" == "1.0" ]]; then 
		echo "All samples are Single-end"; 
	elif [[ "${RESULT}" == "2.0" ]]; then 
		echo "All samples are Paired-end" ;
	else 
		echo "Multiple Reads types or fastq conversion failed. Aborting";
		return 0
	fi
	HEAD=$(cd ${I_DIR} && ls -1 *.fastq | awk -F_ '{print $1}'| sort | uniq )
	READSTR=$(cd ${I_DIR} && ls -1 *.fastq | awk -F_ '{print $2}'| sort | uniq)
	if (( "${NCOLS}" == "1" )); then     # Single-End reads
		CMD="cat"
		for H in $HEAD; do
			CMD=$CMD" "${I_DIR}/${H}
		done
		CMD=$CMD" > "${O_DIR}/${SAM}.fastq
        echo "${CMD}"
		eval "${CMD}"
		return 1
	elif (( "${NCOLS}" == "2" )); then  # Pair-End reads
		CMD_R1="cat"
    	CMD_R2="cat"
		for H in $HEAD; do
			for R in $READSTR; do
				echo -e $H"\t"$R
				if [[ $R =~ "1" ]]; then 
					CMD_R1=$CMD_R1" "${I_DIR}/${H}"_"$R
				elif [[ $R =~ "2" ]]; then
					CMD_R2=$CMD_R2" "${I_DIR}/${H}"_"$R
				fi
			done
		done
		CMD_R1=${CMD_R1}" > "${O_DIR}/${SAM}_1.fastq
		CMD_R2=${CMD_R2}" > "${O_DIR}/${SAM}_2.fastq
        echo "${CMD_R1}"
        echo "${CMD_R2}"
		eval "${CMD_R1}"
		eval "${CMD_R2}"
		if ( test -f ${O_DIR}/${SAM}_1.fastq ) && ( test -f ${O_DIR}/${SAM}_2.fastq ); then
			return 1
		else
			return 0
		fi
	fi
}


function FETCH_MERGE()
{
    local TMP_I_DIR R_TYPE I_DIR XSAM I FIRST_SAM
    I_DIR=$1
  	TMP_I_DIR=${TMP_BASE_DIR}/tmp/${I_DIR}
    XSAM=()
    for I in ${SAM[@]}; do XSAM+=($I); done
    FIRST_SAM=${XSAM[0]}
    for SAM in ${XSAM[@]}; do
        (conda activate micro && SRA_FETCH_CONVERT srafetch)
        if (( $? == "0" )); then
            return 0
        fi
        if [[ "$SAM" == "${FIRST_SAM}" ]]; then
            mkdir ${TMP_I_DIR}/${FIRST_SAM}/LANES
            mv ${TMP_I_DIR}/${FIRST_SAM}/*.fastq ${TMP_I_DIR}/${FIRST_SAM}/LANES/
        elif [[ "$SAM" != "${FIRST_SAM}" ]]; then
            mv ${TMP_I_DIR}/${SAM}/*.fastq ${TMP_I_DIR}/${FIRST_SAM}/LANES/
            rmdir ${TMP_I_DIR}/${SAM}
        fi
    done
    SAM=()
    SAM=${FIRST_SAM}
    DEBUG ">>${SAM}: Merging Start"
    if [[ "${SEQ_MODE}" == "online" ]]; then
	    ONLINE_LANE_MERGE ${TMP_I_DIR}/${FIRST_SAM}/LANES ${TMP_I_DIR}/${FIRST_SAM}
    elif [[ "${SEQ_MODE}" == "offline" ]]; then
	    OFFLINE_LANE_MERGE ${TMP_I_DIR}/${FIRST_SAM}/LANES ${TMP_I_DIR}/${FIRST_SAM}
    fi
	rm -r ${TMP_I_DIR}/${FIRST_SAM}/LANES
    DETECT_READ_TYPE_DIREC ${TMP_I_DIR}/${SAM}
    R_TYPE=$?
	if (( ${R_TYPE} == "0" )); then
        INFO ">>${FIRST_SAM}: Unable to determine sample Type"
        DEBUG ">>${FIRST_SAM}: Merging Fail"
        rm -r ${TMP_I_DIR}/${FIRST_SAM}
        return 0
    elif (( ${R_TYPE} == "1" )); then
        if (test -f ${TMP_I_DIR}/${FIRST_SAM}/${FIRST_SAM}.fastq); then
            DEBUG ">>${FIRST_SAM}: Merging Success"
            return 1
        else
            DEBUG ">>${FIRST_SAM}: Merging Fail"
            rm -r ${TMP_I_DIR}/${FIRST_SAM}
            return 0
        fi
    elif (( ${R_TYPE} == "2" )); then
        if ( test -f  ${TMP_I_DIR}/${FIRST_SAM}/${FIRST_SAM}_1.fastq && test -f  ${TMP_I_DIR}/${FIRST_SAM}/${FIRST_SAM}_2.fastq ); then
            DEBUG ">>${FIRST_SAM}: Merging Success"
            return 1
        else
            DEBUG ">>${FIRST_SAM}: Merging Fail"
            rm -r ${TMP_I_DIR}/${FIRST_SAM}
            return 0
        fi
    fi
}