

function GETMATRIX()
{
    local TMP_I_DIR TMP_O_DIR totF
    TMP_I_DIR=${TMP_BASE_DIR}/tmp/$1
  	TMP_O_DIR=${TMP_BASE_DIR}/tmp/$2
    DEBUG ">>${SAM}: Matrix Estimation Start"
    mkdir ${TMP_O_DIR}/${SAM}
    if ! ( test -d ${TMP_O_DIR}/${SAM} ); then
        DEBUG ">>${SAM}: Matrix Estimation Fail"
        return 0
    fi
    (conda activate renv && Rscript --no-save --vanilla /home/UWO/dsing243/microbiome/bin/get_matrix.R --input ${TMP_I_DIR}/${SAM}/ --output ${TMP_O_DIR}/${SAM}/)
	totF=$(ls -1 ${TMP_O_DIR}/${SAM}/ | wc -l)
	if (( ${totF} == 5  )) ; then
        DEBUG ">>${SAM}: Matrix Estimation Success"
        return 1
    else
        DEBUG ">>${SAM}: Matrix Estimation Fail"
        return 0
    fi
}