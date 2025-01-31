#!/bin/sh
function COPY_FROM_DIREC()
{
    local TMP_O_DIR R_TYPE I_DIR O_DIR SAMPLE_LIST I f
    O_DIR=$1
    TMP_O_DIR=${TMP_BASE_DIR}/tmp/${O_DIR}
    echo ${TMP_O_DIR}
    OFFDIR=$(cd ${OFFDIR} && pwd)
    echo ${OFFDIR}
    DEBUG ">>${SAM}: Copying Sample Start"   
    if test -d ${OFFDIR}/${SAM} ; then
        echo "Directory Exists"
    else
        echo "Directory does not Exists"
        DEBUG ">>${SAM}: Copying Sample Fail"
        return 0
    fi
    (cd ${OFFDIR}/${SAM}
    I=0
    for f in *; do
        if [[ "$f" =~ '.fq' ]] || [[ "$f" =~ '.fastq'  ]]; then 
            SAMPLE_LIST[ $I ]="$f"
            (( I++ ))
        fi
    done
    echo "Here"
    echo ${SAMPLE_LIST[@]}
    if (( ${#SAMPLE_LIST[@]} == 0 )); then
        INFO ">>${SAM}: No samples found. Exiting"
        DEBUG ">>${SAM}: Copying Sample Fail"
        return 0
    elif(( ${#SAMPLE_LIST[@]} == 1 )); then
        echo "Copying File ${SAMPLE_LIST[0]} as ${SAM}.fastq"
        mkdir ${TMP_O_DIR}/${SAM}
        cp ${SAMPLE_LIST[0]} ${TMP_O_DIR}/${SAM}/${SAM}.fastq
        if (test -f ${TMP_O_DIR}/${SAM}/${SAM}.fastq); then
            DEBUG ">>${SAM}: Copying Sample Success"
            return 1
        else
            DEBUG ">>${SAM}: Copying Sample Fail"
            rm -r ${TMP_O_DIR}/${SAM}
            return 0
        fi
    elif (( ${#SAMPLE_LIST[@]} == 2 )); then
        mkdir ${TMP_O_DIR}/${SAM}
        if [[ "${SAMPLE_LIST[0]}" =~ '_1.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R1.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_1.fastq'  ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R1.fastq' ]]; then
            echo "Copying File ${SAMPLE_LIST[0]} as ${SAM}_1.fastq"
            cp ${SAMPLE_LIST[0]} ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq
            if [[ "${SAMPLE_LIST[1]}" =~ '_2.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R2.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_2.fastq'  ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R2.fastq' ]]; then
                echo "Copying File ${SAMPLE_LIST[1]} as ${SAM}_2.fastq"
                cp ${SAMPLE_LIST[1]} ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq
            else
                DEBUG ">>${SAM}: Copying Sample Fail"
                rm -r ${TMP_O_DIR}/${SAM}
                echo "Unknown format for second paired-end file. Exiting"
                return 0
            fi
        elif [[ "${SAMPLE_LIST[1]}" =~ '_1.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R1.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_1.fastq'  ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R1.fastq' ]]; then
            echo "Copying File ${SAMPLE_LIST[1]} as ${SAM}_1.fastq"
            cp ${SAMPLE_LIST[1]} ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq
            if [[ "${SAMPLE_LIST[0]}" =~ '_2.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R2.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_2.fastq'  ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R2.fastq' ]]; then
                echo "Copying File ${SAMPLE_LIST[0]} as ${SAM}_2.fastq"
                cp ${SAMPLE_LIST[0]} ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq
            else
                echo "Unknown format for second paired-end file. Exiting"
                DEBUG ">>${SAM}: Copying Sample Fail"
                rm -r ${TMP_O_DIR}/${SAM}
                return 0
            fi
        else
            echo "Unknown format for first paired-end file. Exiting"
            DEBUG ">>${SAM}: Copying Sample Fail"
            rm -r ${TMP_O_DIR}/${SAM}
            return 0
        fi
        
        if ( test -f ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq && test -f ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq); then
            DEBUG ">>${SAM}: Copying Sample Success"
            return 1
        else
            DEBUG ">>${SAM}: Copying Sample Fail"
            rm -r ${TMP_O_DIR}/${SAM}
            return 0
        fi
    elif(( ${#SAMPLE_LIST[@]} > 2 )); then
        echo "More than 2 samples found in a folder. Exiting"
        DEBUG ">>${SAM}: Copying Sample Fail"
        return 0
    fi
    )
}

function COPY_FROM_REPO()
{
    local TMP_O_DIR R_TYPE I_DIR O_DIR SAMPLE_LIST I FI
    O_DIR=$1
    TMP_O_DIR=${TMP_BASE_DIR}/tmp/${O_DIR}
    #echo ${TMP_O_DIR}
    OFFDIR=$(cd ${OFFDIR} && pwd)
    #echo ${OFFDIR}
    DEBUG ">>${SAM}: Copying Sample Start"   
    if test -d ${OFFDIR} ; then
        echo ${OFFDIR}": Directory Exists"
    else
        echo "Directory does not Exists"
        DEBUG ">>${SAM}: Copying Sample Fail"
        return 0
    fi
    (cd ${OFFDIR}
    I=0
    for FI in *; do
        if [[ "$FI" =~ '.fq' ]] || [[ "$FI" =~ '.fastq'  ]]; then 
            if [[ "$FI" == "${SAM}"* ]]; then
                SAMPLE_LIST[ $I ]="$FI"
                (( I++ ))
            fi
        fi
    done
    if (( ${#SAMPLE_LIST[@]} == 0 )); then
        INFO ">>${SAM}: No samples found. Exiting"
        DEBUG ">>${SAM}: Copying Sample Fail"
        return 0
    elif(( ${#SAMPLE_LIST[@]} == 1 )); then
        echo "Copying File ${SAMPLE_LIST[0]} as ${SAM}.fastq"
        mkdir ${TMP_O_DIR}/${SAM}
        cp ${SAMPLE_LIST[0]} ${TMP_O_DIR}/${SAM}/${SAM}.fastq
        if (test -f ${TMP_O_DIR}/${SAM}/${SAM}.fastq); then
            DEBUG ">>${SAM}: Copying Sample Success"
            return 1
        else
            DEBUG ">>${SAM}: Copying Sample Fail"
            rm -r ${TMP_O_DIR}/${SAM}
            return 0
        fi
    elif (( ${#SAMPLE_LIST[@]} == 2 )); then
        mkdir ${TMP_O_DIR}/${SAM}
        if [[ "${SAMPLE_LIST[0]}" =~ '_1.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R1.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_1.fastq'  ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R1.fastq' ]]; then
            echo "Copying File ${SAMPLE_LIST[0]} as ${SAM}_1.fastq"
            cp ${SAMPLE_LIST[0]} ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq
            if [[ "${SAMPLE_LIST[1]}" =~ '_2.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R2.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_2.fastq'  ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R2.fastq' ]]; then
                echo "Copying File ${SAMPLE_LIST[1]} as ${SAM}_2.fastq"
                cp ${SAMPLE_LIST[1]} ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq
            else
                DEBUG ">>${SAM}: Copying Sample Fail"
                rm -r ${TMP_O_DIR}/${SAM}
                echo "Unknown format for second paired-end file. Exiting"
                return 0
            fi
        elif [[ "${SAMPLE_LIST[1]}" =~ '_1.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R1.fq' ]] || [[ "${SAMPLE_LIST[1]}" =~ '_1.fastq'  ]] || [[ "${SAMPLE_LIST[1]}" =~ '_R1.fastq' ]]; then
            echo "Copying File ${SAMPLE_LIST[1]} as ${SAM}_1.fastq"
            cp ${SAMPLE_LIST[1]} ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq
            if [[ "${SAMPLE_LIST[0]}" =~ '_2.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R2.fq' ]] || [[ "${SAMPLE_LIST[0]}" =~ '_2.fastq'  ]] || [[ "${SAMPLE_LIST[0]}" =~ '_R2.fastq' ]]; then
                echo "Copying File ${SAMPLE_LIST[0]} as ${SAM}_2.fastq"
                cp ${SAMPLE_LIST[0]} ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq
            else
                echo "Unknown format for second paired-end file. Exiting"
                DEBUG ">>${SAM}: Copying Sample Fail"
                rm -r ${TMP_O_DIR}/${SAM}
                return 0
            fi
        else
            echo "Unknown format for first paired-end file. Exiting"
            DEBUG ">>${SAM}: Copying Sample Fail"
            rm -r ${TMP_O_DIR}/${SAM}
            return 0
        fi
        
        if ( test -f ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq && test -f ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq); then
            DEBUG ">>${SAM}: Copying Sample Success"
            return 1
        else
            DEBUG ">>${SAM}: Copying Sample Fail"
            rm -r ${TMP_O_DIR}/${SAM}
            return 0
        fi
    elif(( ${#SAMPLE_LIST[@]} > 2 )); then
        echo "More than 2 samples found in a folder. Exiting"
        DEBUG ">>${SAM}: Copying Sample Fail"
        return 0
    fi
    )
}