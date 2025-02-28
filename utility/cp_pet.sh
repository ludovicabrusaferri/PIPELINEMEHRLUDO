#!/bin/bash

cp_pet() {
    local subj="$1"
    local PET_dir_skull="$2"
    local PET_dir_origin="$3"
    local convert_dir="$4"
    local bay7="$5"
    local pet_filename="PET_60-90.nii.gz"
    echo "Copying PET data for subject: $subj"

 
        mkdir -p "${PET_dir_skull}/${subj}/PET"
 
     file_path=`ls ${convert_dir}/*${subj}*/gated_PET_stage_3/summed_aligned_30001Head_PetAcquisition_Raw_Data-LM-00-OP_000.v.nii.gz`
     
        echo "Found PET file: $file_path"
     cp $file_path ${PET_dir_skull}/${subj}/PET/$pet_filename
    #PETinputfile=${PET_dir_skull}/${subj}/PET/$pet_filename
    #export PETinputfile
 
    
}

