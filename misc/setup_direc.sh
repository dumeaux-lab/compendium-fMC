
function SETUP_DIREC()
{
	local DIR_NAME USE_EXISTING TMP_BDIR
    TMP_DIR_LIST=(srafetch trim phylo matrix enrich)
	USE_EXISTING=$1
    TMP_BDIR=${TMP_BASE_DIR}/tmp
	INFO "Setting up directories: Start"
	if [[ -d $TMP_BDIR ]]; then
		if [[ ${USE_EXISTING} == "False" ]]; then
			echo "Directory already exists. Deleting tmp directory and log file"
			rm -r ${TMP_BDIR}
			rm -r ${TMP_BASE_DIR}/metastatus.log
			INFO "Setting up directories: Fail"
			#return 0
		elif [[ ${USE_EXISTING} == "True" ]]; then
			INFO "Continuing with existing directory"
		fi
	else
		mkdir ${TMP_BDIR}
	fi
	for DIR_NAME in ${TMP_DIR_LIST[@]}; do
        echo -e "Creating directory\t"${DIR_NAME}"\tat\t"${TMP_BDIR}
		mkdir -p ${TMP_BDIR}/${DIR_NAME}
	done
	INFO "Setting up directories: Finish"
	return 1
}


function SETUP_OUT_DIREC()
{
	local DIR_NAME
    TMP_DIR_LIST=(enrichment)
	INFO "Setting up output directories: Start"
	for DIR_NAME in ${TMP_DIR_LIST[@]}; do
        echo -e "Creating directory\t"${DIR_NAME}"\tat\t"${FINAL_BASE_DIR}
		mkdir -p ${FINAL_BASE_DIR}/${DIR_NAME}
	done
	INFO "Setting up output directories: Finish"
	return 1
}