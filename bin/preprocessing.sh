#!/bin/sh
###########################
# Created: 21-June-2023   #
# Modified: 29-July-2023  #
# Author: Dalwinder Singh #
###########################


function TRIM_FILTER()
{
    local TMP_I_DIR TMP_O_DIR R_TYPE FASTP_LEN MIN_QUAL THREADS_X KEEP_PREV
    TMP_I_DIR=${TMP_BASE_DIR}/tmp/$1
  	TMP_O_DIR=${TMP_BASE_DIR}/tmp/$2
    MIN_FASTP_LEN=$3
    MIN_QUAL=$4
    THREADS_X=$(($5>8 ? 8 : $5))
    KEEP_PREV=$6
    DEBUG ">>${SAM}: Trimming and Filtering Start"
    DETECT_READ_TYPE_DIREC ${TMP_I_DIR}/${SAM}
    R_TYPE=$?
    mkdir ${TMP_O_DIR}/${SAM}
    if ! ( test -d ${TMP_O_DIR}/${SAM} ); then
        DEBUG ">>${SAM}: Trimming and Filtering Fail"
        return 0
    fi
    if (( ${R_TYPE} == "1" )); then
        fastp --trim_poly_x --trim_poly_g -p --length_required ${MIN_FASTP_LEN} --thread ${THREADS_X} --cut_front --cut_tail --cut_mean_quality ${MIN_QUAL} -i ${TMP_I_DIR}/${SAM}/${SAM}.fastq -o ${TMP_O_DIR}/${SAM}/${SAM}.fastq -j ${TMP_O_DIR}/${SAM}/${SAM}.json -h ${TMP_O_DIR}/${SAM}/${SAM}.html
        rm ${TMP_O_DIR}/${SAM}/${SAM}.json
        rm ${TMP_O_DIR}/${SAM}/${SAM}.html
        if test -f ${TMP_O_DIR}/${SAM}/${SAM}.fastq ; then
            DEBUG ">>${SAM}: Trimming and Filtering Success"
        else
            DEBUG ">>${SAM}: Trimming and Filtering Fail"
            return 0
        fi
	elif (( ${R_TYPE} == "2" )); then
        fastp --trim_poly_x --trim_poly_g -p --length_required ${MIN_FASTP_LEN} --thread ${THREADS_X} --cut_front --cut_tail --cut_mean_quality ${MIN_QUAL} -i ${TMP_I_DIR}/${SAM}/${SAM}_1.fastq -I ${TMP_I_DIR}/${SAM}/${SAM}_2.fastq -o ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq -O ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq -j ${TMP_O_DIR}/${SAM}/${SAM}.json -h ${TMP_O_DIR}/${SAM}/${SAM}.html
        rm ${TMP_O_DIR}/${SAM}/${SAM}.json
        rm ${TMP_O_DIR}/${SAM}/${SAM}.html
        if (test -f ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq && test -f ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq); then
            DEBUG ">>${SAM}: Trimming and Filtering Success"
        else
            DEBUG ">>${SAM}: Trimming and Filtering Fail"
            return 0
        fi
    else
	    echo "Unable to determine sequence type"
        DEBUG ">>${SAM}: Trimming and Filtering Fail"
        return 0
    fi
    if [[ $KEEP_PREV == "False" ]]; then
        INFO ">>${TMP_I_DIR}/${SAM}: Removing Directory Start"
        rm -r ${TMP_I_DIR}/${SAM}
        if ( test -d ${TMP_I_DIR}/${SAM}); then
            INFO ">>${TMP_I_DIR}/${SAM}: Removing Directory Fail"
            return 0
        else
            INFO ">>${TMP_I_DIR}/${SAM}: Removing Directory Success"
            return 1
        fi
    elif [[ $KEEP_PREV == "True" ]]; then
        return 1
    fi
}