

function GETENRICH()
{
    local TMP_I_DIR TMP_O_DIR totF CONF_SCORE THREADS_X
    TMP_I_DIR=${TMP_BASE_DIR}/tmp/$1
    TMP_FQ_DIR=${TMP_BASE_DIR}/tmp/$2
  	TMP_O_DIR=${TMP_BASE_DIR}/tmp/$3
    CONF_SCORE=$4
    THREADS_X=$5
    DEBUG ">>${SAM}: Enrichment Analysis Start"
    mkdir ${TMP_O_DIR}/${SAM}
    if ! ( test -d ${TMP_O_DIR}/${SAM} ); then
        DEBUG ">>${SAM}: Enrichment Analysis Fail"
        return 0
    fi
    DEBUG ">>${SAM}: Converting bracken to MPA Start"
    kreport2mpa.py -r ${TMP_I_DIR}/${SAM}/classified_${CONF_SCORE}_bracken_species.kreport -o ${TMP_I_DIR}/${SAM}/classified.mpa  --percentages
    (conda activate renv && Rscript --no-save --vanilla /home/UWO/dsing243/microbiome/bin/new_enrich_file_format.R --input ${TMP_I_DIR}/${SAM}/classified.mpa --output ${TMP_I_DIR}/${SAM}/reformat_classified.mpa)
    if ( test -f ${TMP_I_DIR}/${SAM}/reformat_classified.mpa ); then
        DEBUG ">>${SAM}: Converting bracken to MPA Success"
    else
        DEBUG ">>${SAM}: Converting bracken to MPA Fail"
        return 0
    fi
    DETECT_READ_TYPE_DIREC ${TMP_I_DIR}/${SAM}
    R_TYPE=$?
    if (( ${R_TYPE} == "1" )); then
        (humann -i ${TMP_FQ_DIR}/${SAM}/${SAM}.fastq --taxonomic-profile ${TMP_I_DIR}/${SAM}/reformat_classified.mpa --output ${TMP_O_DIR}/${SAM}/ --threads ${THREADS_X} --remove-temp-output)
    elif (( ${R_TYPE} == "2" )); then
        cat ${TMP_FQ_DIR}/${SAM}/${SAM}_1.fastq ${TMP_FQ_DIR}/${SAM}/${SAM}_2.fastq > ${TMP_FQ_DIR}/${SAM}/${SAM}.fastq
        (humann -i ${TMP_FQ_DIR}/${SAM}/${SAM}.fastq --taxonomic-profile ${TMP_I_DIR}/${SAM}/reformat_classified.mpa --output ${TMP_O_DIR}/${SAM}/ --threads ${THREADS_X} --remove-temp-output)
        rm ${TMP_FQ_DIR}/${SAM}/${SAM}.fastq
    fi
	totF=$(ls -1 ${TMP_O_DIR}/${SAM}/*.tsv | wc -l)
	if (( ${totF} == 3  )) ; then
        DEBUG ">>${SAM}: Enrichment Analysis Success"
        return 1
    else
        DEBUG ">>${SAM}: Enrichment Analysis Fail"
        return 0
    fi
}