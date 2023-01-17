#!/usr/bin/env bash

FILE=$1
source ./00_source.inc

### ENTER FOLDER
cd ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX

### SET FILE NAME IN  USER PARAMETERS
echo FILE=${FILE}_COMPLEX > 00_user_parameters.inc

### SET TARGET STOICHIOMETRY
echo $STOICHIOMETRY 300 $OUT_NAME > target.lst

### START SLURM SUBMISSION DEPENDING ON CURRENT PROGRESS STATUS

if [ -f $LOC_FEATURES/features.pkl ]
	then
	echo "---------------------------------------------------"
	echo "(1) MSA OF ${FILE}_COMPLEX FINISHED SUCCESSFULLY."
	if [ -f $LOC_OUT/ranking_model_1_*_*_*_*.json -a $LOC_OUT/ranking_model_2_*_*_*_*.json -a $LOC_OUT/ranking_model_3_*_*_*_*.json -a $LOC_OUT/ranking_model_4_*_*_*_*.json -a $LOC_OUT/ranking_model_5_*_*_*_*.json ]
		then
		[ -f $LOC_OUT/model_1_*_*_*_*.pkl ]; rm *.pkl
		echo "(2) PREDICTION OF ${FILE}_COMPLEX FINISHED SUCCESSFULLY."
		if [ -f $LOC_OUT/relaxed_model_1_*_*_*_*.pdb -a $LOC_OUT/relaxed_model_2_*_*_*_*.pdb -a $LOC_OUT/relaxed_model_3_*_*_*_*.pdb  -a $LOC_OUT/relaxed_model_4_*_*_*_*.pdb -a $LOC_OUT/relaxed_model_5_*_*_*_*.pdb ]
			then
			echo "(3) RELAXATION OF ${FILE}_COMPLEX FINISHED SUCCESSFULLY."
			if [ -f $LOC_OUT/${FILE}_COMPLEX_rlx_model_1_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_2_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_3_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_4_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_5_x${N}.pdb ]
				then
				echo "(5) PIPELINE FINISHED SUCCESSFULLY. SEE $LOC_OUT"
			else
				echo "(4) PREPARING ${FILE}_COMPLEX FOR ANALYSIS IN R." 
				# = integrated 02_R_PREP.sh script

				cd ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX/
				cat slurm* > ${LOC_OUT}/slurm.out
				mkdir -p ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX/temp_x${N}/
				mv slurm* ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX/temp_x${N}/

				cd $LOC_OUT
				for i in {1..5}; do
				  mv model_${i}_*_*_*_*.pdb ${FILE}_COMPLEX_model_${i}_x${N}.pdb
				  [ -f model_${i}_*_*_*_*.pkl ]; rm model_${i}_*_*_*_*.pkl
				  mv relaxed_model_${i}_*   ${FILE}_COMPLEX_rlx_model_${i}_x${N}.pdb
				  mv ranking_model_${i}_*   ${FILE}_COMPLEX_ranking_model_${i}.json
				done
				[ -f checkpoint ]; rm -r checkpoint
			fi
		else
			cd $LOC_OUT
			[ -f relaxed_* ] && rm relaxed_* # remove old, incomplete relaxation
			cd ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX
	                bash ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX/submit_rlx.sh
		fi

	elif [ -f $LOC_OUT/${FILE}_COMPLEX_rlx_model_1_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_2_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_3_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_4_x${N}.pdb -a $LOC_OUT/${FILE}_COMPLEX_rlx_model_5_x${N}.pdb ]
                then
		[ -f $LOC_OUT/model_*_*_*_*_*.pkl ]; rm $LOC_OUT/model_*_*_*_*_*.pkl
		echo "(2) PREDICTION OF ${FILE}_COMPLEX FINISHED SUCCESSFULLY."
		echo "(3) RELAXATION OF ${FILE}_COMPLEX FINISHED SUCCESSFULLY."
		echo "(4) R PREPARATION OF ${FILE}_COMPLEX FINISHED SUCCESSFULLY."
                echo "(5) PIPELINE FINISHED SUCCESSFULLY. FILES:"
		ls $LOC_OUT
		echo "---------------------------------------------------"

	elif [ -f $LOC_OUT/relaxed_model_* ]
		#-o $LOC_OUT/relaxed_model_2_* -o $LOC_OUT/relaxed_model_3_*  -o $LOC_OUT/relaxed_model_4_* -o $LOC_OUT/relaxed_model_5_* ]
		then
		#echo " ---> INCOMPLETE PREDICTION OF $STOICHIOMETRY"
		for i in {1..5}; do
			if [ -f $LOC_OUT/model_${i}_* ]
				then 
				echo " ---> PREDICTION ${i} DONE."
			else 
				if [ -f $LOC_OUT/model_${i}_*_*_*_*.pkl ] 
					then 
					rm $LOC_OUT/model_${i}_*_*_*_*.pkl
				fi
				bash ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX/submit_${i}.sh
			fi
		done
	else echo " ---> NO PREDICTION YET. STARTING SMALL PIPELINE FOR ${FILE}_COMPLEX"
		bash ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX/submit_small_pipe.sh		
	fi
else
        echo " ---> NO MSA YET. STARTING BIG PIPELINE FOR ${FILE}_COMPLEX"
        bash ${LOC_SCRIPTS}/myRuns/${FILE}_COMPLEX/submit_big_pipe.sh
fi
