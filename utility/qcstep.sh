#!/bin/bash

qcstep() {
    local subj="$1"
    local PET_dir_skull="$2"

    echo "Applying ANTs transformation to Skull SUV for subject: $subj"

    local processing_dir="${PET_dir_skull}/${subj}/PET/SUVR_2mm-processing_ANTs"
 
	cd $processing_dir
       	if [ ! -f ${subj}_t1_lin-coreg2_suv.nii.gz ]; then
    	mri_vol2vol --mov PET_60-90_SUV_orientOK.nii.gz --targ T1_orientOK.nii.gz --o ${subj}_t1_lin-coreg2_suv.nii.gz --reg ${subj}_suv_lin-coreg2_T1.lta --interp nearest --inv
else 
echo "DONE!!"
fi
 
    echo "Finished ANTs transformation for Skull SUV QC"
}

