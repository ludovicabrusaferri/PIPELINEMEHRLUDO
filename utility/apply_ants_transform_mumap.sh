#!/bin/bash

apply_ants_transform_mumap() {
    local subj="$1"
    local PET_dir_skull="$2"

    echo "Applying ANTs transformation to muMAP for subject: $subj"

    local processing_dir="${PET_dir_skull}/${subj}/PET/SUVR_2mm-processing_ANTs"
    local output_file="${processing_dir}/${subj}_muMAP_Nativ_Nodil_NoBrain_BIN_nl_MNI152_NN.nii.gz"

    # Ensure processing directory exists
    [[ ! -d "$processing_dir" ]] && { echo -e "\e[31mError: Processing directory does not exist: $processing_dir\e[0m"; return 1; }

    cd "$processing_dir" || { echo "Error: Cannot access $processing_dir"; return 1; }

    # Skip transformation if the output file already exists
    if [[ -f "$output_file" ]]; then
        echo "Output file already exists: $output_file"
        echo "Skipping ANTs registration for muMAP."
        return 0
    fi

    echo "Running ANTs registration for muMAP..."
    
    # Convert LTA to ITK format only if needed
    [[ ! -f "${subj}_suv_lin-coreg2_T1.txt" ]] && lta_convert --inlta "${subj}_suv_lin-coreg2_T1.lta" --outitk "${subj}_suv_lin-coreg2_T1.txt"

    mri_vol2vol --mov PET_60-90_SUV_orientOK.nii.gz --targ T1_orientOK.nii.gz --o ${subj}_suv_lin-coreg2_T1_QCimage.nii.gz --reg ${subj}_suv_lin-coreg2_T1.lta --interp nearest
    # Apply ANTs transformation
    antsApplyTransforms -d 3 -e 0 -i gated_muMAP_th_BIN_Nodil_Nativ_NoBrain.nii.gz \
                        -r ${subj}_T1_MNI.nii.gz -o "$output_file" \
                        -t ${subj}1Warp.nii.gz -t ${subj}0GenericAffine.mat \
                        -t ${subj}_suv_lin-coreg2_T1.txt -v 1 -n NearestNeighbor

    echo "Finished ANTs transformation for muMAP: $output_file"
     
}

