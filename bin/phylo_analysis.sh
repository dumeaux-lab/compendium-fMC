
function KRAKEN()
{
    local TMP_I_DIR TMP_O_DIR R_TYPE CONF_SCORE THREADS_X COMPRESS KEEP_PREV
    TMP_I_DIR=${TMP_BASE_DIR}/tmp/$1
  	TMP_O_DIR=${TMP_BASE_DIR}/tmp/$2
    CONF_SCORE=$3
    THREADS_X=$(($4>8 ? 8 : $4))
    KEEP_PREV=$5
    DEBUG ">>${SAM}: Kraken Start"
    DETECT_READ_TYPE_DIREC ${TMP_I_DIR}/${SAM}
    R_TYPE=$?
    mkdir ${TMP_O_DIR}/${SAM}
    if ! ( test -d ${TMP_O_DIR}/${SAM} ); then
        DEBUG ">>${SAM}: Kraken Fail"
        return 0
    fi
    if (( ${R_TYPE} == "1" )); then
        kraken2 --db /data/lab_vm/campervans/db/metagenomics/humgut/krakendb_gtdbhumgut/ ${TMP_I_DIR}/${SAM}/${SAM}.fastq --unclassified-out ${TMP_O_DIR}/${SAM}/unclassified_${CONF_SCORE}.fastq --confidence ${CONF_SCORE} --report ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kreport > ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kraken
		if (test -f ${TMP_O_DIR}/${SAM}/unclassified_${CONF_SCORE}.fastq && test -f ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kreport && test -f ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kraken ) ; then
		    DEBUG ">>${SAM}: Kraken Success"
        else
            DEBUG ">>${SAM}: Kraken Fail"
            return 0
        fi
	elif (( ${R_TYPE} == "2" )); then
        kraken2 --paired --db /data/lab_vm/campervans/db/metagenomics/humgut/krakendb_gtdbhumgut/ ${TMP_I_DIR}/${SAM}/${SAM}_1.fastq ${TMP_I_DIR}/${SAM}/${SAM}_2.fastq --unclassified-out ${TMP_O_DIR}/${SAM}/unclassified_${CONF_SCORE}#.fastq --confidence ${CONF_SCORE} --report ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kreport > ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kraken
		if (test -f ${TMP_O_DIR}/${SAM}/unclassified_${CONF_SCORE}_1.fastq && test -f ${TMP_O_DIR}/${SAM}/unclassified_${CONF_SCORE}_2.fastq && test -f ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kreport && test -f ${TMP_O_DIR}/${SAM}/classified_${CONF_SCORE}.kraken ) ; then
			DEBUG ">>${SAM}: Kraken Success"
        else
            DEBUG ">>${SAM}: Kraken Fail"
            return 0
        fi
    else
	    echo "Unable to determine sequence type"
        DEBUG ">>${SAM}: Bracken Fail"
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

function BRACKEN()
{
    local TMP_IO_DIR CONF_SCORE THREADS_X
    TMP_IO_DIR=${TMP_BASE_DIR}/tmp/$1
    CONF_SCORE=$2
    THREADS_X=$(($3>8 ? 8 : $3))
    DEBUG ">>${SAM}: Bracken Start"
    bracken -r 60 -l 'S' -t ${THREADS_X} -d /data/lab_vm/campervans/db/metagenomics/humgut/krakendb_gtdbhumgut/ -i ${TMP_IO_DIR}/${SAM}/classified_${CONF_SCORE}.kreport -o ${TMP_IO_DIR}/${SAM}/classified_${CONF_SCORE}.kreport.bracken
    if (test -f ${TMP_IO_DIR}/${SAM}/classified_${CONF_SCORE}.kreport.bracken && test -f ${TMP_IO_DIR}/${SAM}/classified_${CONF_SCORE}_bracken_species.kreport) ; then
		DEBUG ">>${SAM}: Bracken Success"
        return 1
    else
        DEBUG ">>${SAM}: Bracken Fail"
        return 0
    fi
}