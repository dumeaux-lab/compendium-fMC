
function SRA_FETCH_CONVERT()
{	
	local TMP_I_DIR R_TYPE I_DIR
    I_DIR=$1
  	TMP_I_DIR=${TMP_BASE_DIR}/tmp/${I_DIR}
    DEBUG ">>${SAM}: SRA File Download Start"
	prefetch --verify yes --max-size 100G ${SAM} --output-directory ${TMP_I_DIR}
	if test -f ${TMP_I_DIR}/${SAM}/${SAM}.sra ; then
        DEBUG ">>${SAM}: SRA File Download Success"
    else
        DEBUG ">>${SAM}: SRA File Download Fail"
		rm -r ${TMP_I_DIR}/${SAM}
        return 0
    fi
	DEBUG ">>${SAM}: Fastq Conversion Start"
	cd ${TMP_I_DIR}
    fasterq-dump ${TMP_I_DIR}/${SAM} --outdir ${TMP_I_DIR}/${SAM}
	DEBUG ">>${SAM}: Checking sample Type Start"
    DETECT_READ_TYPE_DIREC ${TMP_I_DIR}/${SAM}
    R_TYPE=$?
    DEBUG ">>${SAM}: Checking sample Type Success"
    if (( ${R_TYPE} == "0" )); then
        INFO ">>${SAM}: Unable to determine sample Type"
		DEBUG ">>${SAM}: Fastq Conversion Fail"
        rm -r ${TMP_I_DIR}/${SAM}
        return 0
    elif (( ${R_TYPE} == "1" )); then
		if (test -f ${TMP_I_DIR}/${SAM}/${SAM}.fastq); then
            DEBUG ">>${SAM}: Fastq Conversion Success"
        else
            DEBUG ">>${SAM}: Fastq Conversion Fail"
            rm -r ${TMP_I_DIR}/${SAM}
            return 0
        fi
	elif (( ${R_TYPE} == "2" )); then
		if ( test -f ${TMP_I_DIR}/${SAM}/${SAM}_1.fastq && test -f ${TMP_I_DIR}/${SAM}/${SAM}_2.fastq); then
            DEBUG ">>${SAM}: Fastq Conversion Success"
        else
            DEBUG ">>${SAM}: Fastq Conversion Fail"
			rm -r ${TMP_I_DIR}/${SAM}
            return 0
        fi
	fi
    rm -r ${TMP_I_DIR}/${SAM}/*.sra
    return 1
}