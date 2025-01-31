source ~/.bashrc
source ~/anaconda3/etc/profile.d/conda.sh

function VALIDATE_PATHS()
{
	echo "Validating Paths: Start"
	TMP_BASE_DIR=$(cd $TMP_BASE_DIR && pwd)
	if ! [[ -d $TMP_BASE_DIR ]]; then
        echo "Validating Paths: TMP_BASE_DIR Fail"
        return 0
	else
		echo "Validating Paths: TMP_BASE_DIR Success"
    fi
	
    FINAL_BASE_DIR=$(cd $FINAL_BASE_DIR && pwd)
	if ! [[ -d $FINAL_BASE_DIR ]]; then
        echo "Validating Paths: FINAL_BASE_DIR Fail"
        return 0
	else
		echo "Validating Paths: FINAL_BASE_DIR Success"
    fi

	if ! [[ -f ${SAMPLE_LIST} ]]; then
		echo -e "Unable to locate sample list\t"${SAMPLE_LIST} >&2
        echo "Validating Files: SAMPLE_LIST Fail"
        return 0
	else
		echo "Validating Files: SAMPLE_LIST Success"
    fi
	echo "Validating Paths: Finish"	
	return 1
}

function SOURCE_SCRIPTS()
{
	local F SFILES
    BASE_DIR=$1
	INFO "Sourcing scripts: Start"
	SFILES=(bin/get_online.sh bin/get_offline.sh bin/lane_merge.sh bin/lane_merge_offline.sh bin/preprocessing.sh bin/phylo_analysis.sh bin/get_matrix.sh bin/enrich_analysis.sh misc/common_utils.sh misc/setup_direc.sh)
	for F in ${SFILES[@]}; do echo $F; source ${BASE_DIR}/$F; done
	INFO "Sourcing scripts Finish"
	return 1
}

function MICROBIOME()
{
    local TMP_BASE_DIR BASE_DIR SAMPLE_LIST SEQ_MODE THREADS FINAL_BASE_DIR INFO SAM BIO_INFO iSAM CONFID_SCORE OFFDIR FASTP_LEN FAST_QUAL
    BASE_DIR=$(pwd)
	TMP_BASE_DIR=$1
	SAMPLE_LIST=$2
	SEQ_MODE=$3
	THREADS=$4
    FINAL_BASE_DIR=${TMP_BASE_DIR}
	echo ${FINAL_BASE_DIR}
	FASTP_LEN=40
	FAST_QUAL=25
    OFFDIR=$6
    (
        VALIDATE_PATHS
        if (( $? == "0" )); then
            return 0
        fi
        source ${BASE_DIR}/bin/logger.sh ${TMP_BASE_DIR}/metastatus.log
        echo "Setting up log file: Finish"
        SCRIPTENTRY
        SOURCE_SCRIPTS ${BASE_DIR}
        SETUP_DIREC False
        if (( $? == "0" )); then
            SCRIPTEXIT
            return 0
        fi
		SETUP_OUT_DIREC
        CONFID_SCORE=0.15
        while read INFO; do
            iSAM=$(awk -F'[:\t]' '{for (i = 1; i <= ((NF-1)); i++) print $i}' <<< ${INFO} )
            SAM=()
            for i in ${iSAM}; do SAM+=($i); done
            BIO_INFO=$(awk '{print $2}' <<< ${INFO} )
			echo ${BIO_INFO}
            if (( ${#SAM[@]} == 1 )); then
                echo -e "${SAM[0]}\t${BIO_INFO} >> Standard Processing"
                if [[ ${SEQ_MODE} == "online" ]]; then
                    echo -e "Online Processing"
                    (conda activate micro && SRA_FETCH_CONVERT srafetch)
                elif [[ ${SEQ_MODE} == "offline" ]]; then
                    echo -e "Offline Processing"
                    COPY_FROM_REPO srafetch
                fi
                if (( $? == "0" )); then
                    continue
                fi
            elif (( ${#SAM[@]} > 1 )); then
                echo "${SAM[@]} >> Processing with merging"
                if [[ ${SEQ_MODE} == "online" ]]; then
                    echo -e "Online Processing"
                    FETCH_MERGE srafetch
                elif [[ ${SEQ_MODE} == "offline" ]]; then
                    echo -e "Offline Processing"
                    FETCH_MERGE_OFFLINE srafetch
                fi
                if (( $? == "0" )); then
                    continue
                fi
            fi
			(conda activate micro && TRIM_FILTER srafetch trim ${FASTP_LEN} ${FAST_QUAL} ${THREADS} True False)
            if (( $? == "0" )); then
                continue
            fi
            CLEAN_DIREC srafetch
            (conda activate micro && KRAKEN trim phylo ${CONFID_SCORE} ${THREADS} True)
            if (( $? == "0" )); then
                continue
            fi
            (conda activate ncbinfo && BRACKEN phylo ${CONFID_SCORE} ${THREADS})
            if (( $? == "0" )); then
                continue
            fi
            GETMATRIX phylo matrix
            if (( $? == "0" )); then
                continue
            fi
            (conda activate mpa && GETENRICH phylo trim enrich ${CONFID_SCORE} ${THREADS})
            if (( $? == "0" )); then
                continue
            fi
			CLEAN_DIREC trim
			CLEAN_DIREC phylo
			CLEAN_DIREC matrix
            MOVE_DATA enrich ${SAM}_pathabundance.tsv ${BIO_INFO}/
            CLEAN_DIREC enrich
        done<${SAMPLE_LIST}
        SCRIPTEXIT
    )
}