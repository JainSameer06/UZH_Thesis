#!/bin/bash

# If used for segmentation
# Usage: ./Main_sam.sh NORMSEG LANGUAGE SEED SEG_DATA_SPLIT NMT_ENSEMBLES BEAM TRAINTEST 

# If used for normalization
# Usage: ./Main_sam.sh NORMSEG SEED NMT_ENSEMBLES BEAM TRAINTEST

export NORMSEG=$1
if [ ${NORMSEG} == "norm" ]
then
	export LANG=$2
	export SEED=$3
	export SPLIT_NUM=$4
	export NMT_ENSEMBLES=$5
	export BEAM=$6
	export TRAINTEST=$7

	export DATA_DIRECTORY=/home/sameer/Projects/Thesis_UZH/Segmentation/uzh-corpuslab-gen-norm/data
	export DATA_SUBDIRECTORY=canonical-segmentation
	
	export TRAIN_DATA=${DATA_DIRECTORY}/${DATA_SUBDIRECTORY}/${LANG}/train$4
	export DEV_DATA=${DATA_DIRECTORY}/${DATA_SUBDIRECTORY}/${LANG}/dev$4
	export TEST_DATA=${DATA_DIRECTORY}/${DATA_SUBDIRECTORY}/${LANG}/test$4

	export RESULTS_DIRECTORY=/home/sameer/Projects/Thesis_UZH/Segmentation/uzh-corpuslab-gen-norm/results

	export MODEL_TYPE=vanillaED
	export MODEL_PARENTFOLDER=${RESULTS_DIRECTORY}/${MODEL_TYPE}/${LANG}/${SPLIT_NUM}
	

else
	export SEED=$2
	export NMT_ENSEMBLES=$3
	export BEAM=$4
	export TRAINTEST=$5

	export DATA_DIRECTORY=/home/sameer/Projects/Thesis_UZH/Segmentation/uzh-corpuslab-gen-norm/data
	export DATA_SUBDIRECTORY=Archimob

	export TRAIN_DATA=${DATA_DIRECTORY}/${DATA_SUBDIRECTORY}/train_archi.tsv
	export DEV_DATA=${DATA_DIRECTORY}/${DATA_SUBDIRECTORY}/dev_archi.tsv
	export TEST_DATA=${DATA_DIRECTORY}/${DATA_SUBDIRECTORY}/test_archi.tsv

	export RESULTS_DIRECTORY=/home/sameer/Projects/Thesis_UZH/Segmentation/uzh-corpuslab-gen-norm/results_archi


	export MODEL_TYPE=vanillaED
	export MODEL_PARENTFOLDER=${RESULTS_DIRECTORY}/${MODEL_TYPE}

fi



if [ ${TRAINTEST} == "ensemble_test" ]
then
	nmt_predictors="nmt"
	ED_MODEL_FOLDERS=${MODEL_PARENTFOLDER}/1
	if [ $NMT_ENSEMBLES -gt 1 ]
	then
		while read num; do nmt_predictors+=",nmt"; done < <(seq $(($NMT_ENSEMBLES-1)))
		while read num; do ED_MODEL_FOLDERS+=",${MODEL_PARENTFOLDER}/$num"; done < <(seq 2 $NMT_ENSEMBLES)
	fi
	
	export MODEL_FOLDER=${MODEL_PARENTFOLDER}/s_0

elif [ $[TRAINTEST] == "test" ]
then
	export MODEL_FOLDER=${MODEL_PARENTFOLDER}/${SEED}

else	# TRAINTEST == "train"
	export MODEL_FOLDER=${MODEL_PARENTFOLDER}/${SEED}
fi

export cmd_train="python norm_soft.py train ${MODEL_FOLDER} --dynet-seed=${SEED} --train_path=${TRAIN_DATA} --dev_path=${DEV_DATA}"
export cmd_test="python norm_soft.py test --beam=${BEAM} ${MODEL_FOLDER} --test_path=${TEST_DATA}"
export cmd_enstest="python norm_soft.py ensemble_test --beam=${BEAM} ${ED_MODEL_FOLDERS} ${MODEL_FOLDER} --test_path=${TEST_DATA}"

if [ ${TRAINTEST} == 'train' ]
then
	echo "$cmd_train"
	#eval "$cmd_train"

elif [ ${TRAINTEST} == 'test' ]
then
	echo "$cmd_test"
	#eval "$cmd_test"

else
	echo "$cmd_enstest"
	eval "$cmd_enstest"
fi