
function DETECT_READ_TYPE_DIREC()
{
	local READ_DIREC N
	READ_DIREC=$1
	N=$(ls -1 ${READ_DIREC} | grep "fastq\|fq" | wc -l)
	return $N
}

function ASSERT_CONDA_ACTIVATE()
{
    if [[ "${CONDA_DEFAULT_ENV}" != "${CONDA_ENV_NAME}" ]]; then
        echo -e "Error... Unable to activate env '${CONDA_ENV_NAME}'"
        return 0
    else
        echo -e "'${CONDA_ENV_NAME}' env activated"
        return 1
    fi
}

function ASSERT_CONDA_DEACTIVATE()
{
    if [[ "${CONDA_DEFAULT_ENV}" != "base" ]]; then
        echo -e "Error... Unable to activate env 'base'"
        return 0
    else
        echo -e "'base' env activated"
        return 1
    fi
}


function UNCOMPRESS_READS()
{
    local TMP_O_DIR R_TYPE
	TMP_O_DIR=${TMP_BASE_DIR}/tmp/$1
    DETECT_READ_TYPE_DIREC ${OFFDIR}/${SAM}
    R_TYPE=$?
	echo "Copying Sample Start"
    DEBUG ">>${SAM}: Copying Sample Start"
	if (( ${R_TYPE} == "1" )); then
		mkdir ${TMP_O_DIR}/${SAM}
		gzip -d -c ${OFFDIR}/${SAM}/${SAM}.fastq.gz > ${TMP_O_DIR}/${SAM}/${SAM}.fastq
        if test -f ${TMP_O_DIR}/${SAM}/${SAM}.fastq ; then
            DEBUG ">>${SAM}: Copying Sample Success"
			DEBUG ">>${SAM}: Trimming and Filtering Start"
			DEBUG ">>${SAM}: Trimming and Filtering Success"
            return 1
        else
            DEBUG ">>${SAM}: Copying Sample Fail"
			rmdir ${TMP_O_DIR}/${SAM}
            return 0
		fi
    elif (( ${R_TYPE} == "2" )); then
		mkdir ${TMP_O_DIR}/${SAM}
		gzip -d -c ${OFFDIR}/${SAM}/${SAM}_1.fastq.gz > ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq
		gzip -d -c ${OFFDIR}/${SAM}/${SAM}_2.fastq.gz > ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq
        if ( test -f ${TMP_O_DIR}/${SAM}/${SAM}_1.fastq && test -f ${TMP_O_DIR}/${SAM}/${SAM}_2.fastq ) ; then
            DEBUG ">>${SAM}: Copying Sample Success"
			DEBUG ">>${SAM}: Trimming and Filtering Start"
			DEBUG ">>${SAM}: Trimming and Filtering Success"
            return 1
        else
            DEBUG ">>${SAM}: Copying Sample Fail"
			rmdir ${TMP_O_DIR}/${SAM}
            return 0
        fi
    fi
}

function MOVE_DATA()
{
    local TMP_I_DIR F_NAME TMP_O_DIR
    TMP_I_DIR=${TMP_BASE_DIR}/tmp/$1/${SAM}/
    F_NAME=$2
    TMP_O_DIR=${FINAL_BASE_DIR}/enrichment/
    INFO ">>${SAM}: Moving File ${F_NAME} Start"
	(mv ${TMP_I_DIR}/${F_NAME} ${TMP_O_DIR}/)
	if (test -f ${TMP_O_DIR}/${F_NAME}*) ; then
        INFO ">>${SAM}: Moving File ${F_NAME} Success"
        return 1
    else
        INFO ">>${SAM}: Moving File ${F_NAME} Fail"
        return 0
    fi
}

function CLEAN_DIREC()
{
    local TMP_I_DIR
    TMP_I_DIR=${TMP_BASE_DIR}/tmp/$1
    INFO ">>${SAM}: Cleaning Directory Start"
    rm -r ${TMP_I_DIR}
    if ( test -d ${TMP_I_DIR}) ; then
        INFO ">>${SAM}: Cleaning Directory Fail"
        return 0
    else
        INFO ">>${SAM}: Cleaning Directory Success"
        return 1
    fi
}