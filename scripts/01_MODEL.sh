#!/usr/bin/env bash

FILE=$1
source ./00_source.inc

### ENTER FOLDER
cd $LOC_SCRIPTS/${FILE}

### SET FILE NAME IN  USER PARAMETERS
echo FILE=${FILE} > 00_user_parameters.inc

### SET TARGET STOICHIOMETRY
echo $STOICHIOMETRY > target.lst

### START SLURM SUBMISSION DEPENDING ON CURRENT PROGRESS STATUS

if [ -f $LOC_FEATURES/features.pkl ]
	then
	echo "(1) MSA OF ${FILE} FINISHED SUCCESSFULLY."
	if [ -f $LOC_OUT/model_1_*_*_*_*_*.pdb -a $LOC_OUT/model_2_*_*_*_*_*.pdb -a $LOC_OUT/model_3_*_*_*_*_*.pdb -a $LOC_OUT/model_4_*_*_*_*_*.pdb -a $LOC_OUT/model_5_*_*_*_*_*.pdb -a $LOC_OUT/model_1_*_*_*_*_*.pkl -a $LOC_OUT/model_2_*_*_*_*_*.pkl -a $LOC_OUT/model_3_*_*_*_*_*.pkl -a $LOC_OUT/model_4_*_*_*_*_*.pkl -a $LOC_OUT/model_5_*_*_*_*_*.pkl ]
		then
		echo "(2) PREDICTION OF $FILE FINISHED SUCCESSFULLY."
		if [ -f $LOC_OUT/relaxed_model_1_*_*_*_*_*.pdb -a $LOC_OUT/relaxed_model_2_*_*_*_*_*.pdb -a $LOC_OUT/relaxed_model_3_*_*_*_*_*.pdb  -a $LOC_OUT/relaxed_model_4_*_*_*_*_*.pdb -a $LOC_OUT/relaxed_model_5_*_*_*_*_*.pdb ]
			then
			echo "(3) RELAXATION OF ${FILE} FINISHED SUCCESSFULLY."
			if [ -f $LOC_PKL/${FILE}_model_1_x${N}.pkl -a $LOC_PKL/${FILE}_model_2_x${N}.pkl -a $LOC_PKL/${FILE}_model_3_x${N}.pkl -a $LOC_PKL/${FILE}_model_4_x${N}.pkl -a $LOC_PKL/${FILE}_model_5_x${N}.pkl ]
				then
				echo "(5) PIPELINE FINISHED SUCCESSFULLY. SEE $LOC_OUT"
			else
				echo "(4) PREPARING $FILE FOR ANALYSIS IN R." 
				# = integrated 02_R_PREP.sh script

				cd $LOC_SCRIPTS/$FILE/
				cat slurm* > ${LOC_OUT}/slurm.out
				mkdir -p ${LOC_SCRIPTS}/$FILE/temp/
				mv slurm* ${LOC_SCRIPTS}/$FILE/temp/

				cd $LOC_OUT
				for i in {1..5}; do
				  mv model_${i}_*_*_*_*.pdb ${FILE}_model_${i}_x${N}.pdb
				  mv model_${i}_*_*_*_*.pkl $LOC_PKL/${FILE}_model_${i}_x${N}.pkl
				  mv relaxed_model_${i}_*   ${FILE}_rlx_model_${i}_x${N}.pdb
				  mv ranking_model_${i}_*   ${FILE}_ranking_model_${i}.json
				done
				rm -r checkpoint
			fi
		else
			cd $LOC_OUT
			[-f relaxed_* ] && rm relaxed_* # remove old, incomplete relaxation
			echo " ---> STARTING RELAXATION FOR ${FILE}."
			cd $LOC_SCRIPTS/${FILE}
	                bash $LOC_SCRIPTS/${FILE}/submit_rlx.sh
		fi

	elif [ -f $LOC_OUT/relaxed_model_1_*_*_*_*_*.pdb || $LOC_OUT/relaxed_model_2_*_*_*_*_*.pdb || $LOC_OUT/relaxed_model_3_*_*_*_*_*.pdb  || $LOC_OUT/relaxed_model_4_*_*_*_*_*.pdb || $LOC_OUT/relaxed_model_5_*_*_*_*_*.pdb ]
		then
		echo " ---> INCOMPLETE PREDICTION OF $STOICHIOMETRY"
		for i in {1..5}; do
			if [ -f $LOC_OUT/model_${i}_* ]
				then 
				echo " ---> PREDICTION ${i} DONE."
			else 
				if [ -f $LOC_OUT/model_${i}_*_*_*_*_*.pkl ] 
					then 
					rm $LOC_OUT/model_${i}_*_*_*_*_*.pkl
				fi
				echo " ---> STARTING PREDICTION ${i} OF ${FILE}"
				bash $LOC_SCRIPTS/$FILE/submit_${i}.sh
			fi
		done
	else echo " ---> NO PREDICTION YET. STARTING SMALL PIPELINE FOR $FILE"
		bash $LOC_SCRIPTS/$FILE/submit_small_pipe.sh		
	fi
else
        echo " ---> NO MSA YET. STARTING BIG PIPELINE FOR $FILE"
        bash $LOC_SCRIPTS/${FILE}/submit_big_pipe.sh
fi
