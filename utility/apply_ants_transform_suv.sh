#!/bin/bash

apply_ants_transform_suv() {
    local subj="$1"
    local PET_dir_skull="$2"

    echo "Applying ANTs transformation to Skull SUV for subject: $subj"

    local processing_dir="${PET_dir_skull}/${subj}/PET/SUVR_2mm-processing_ANTs"
    local output_file="${processing_dir}/${subj}_SUV_nl_MNI152_Linterp-WHmaskNativ_Nodil_Bone_NoBrain.nii.gz"

    # Ensure processing directory exists
    [[ ! -d "$processing_dir" ]] && { echo -e "\e[31mError: Processing directory does not exist: $processing_dir\e[0m"; return 1; }

    cd "$processing_dir" || { echo "Error: Cannot access $processing_dir"; return 1; }

    # Skip transformation if output file already exists
    if [[ -f "$output_file" ]]; then
        echo "Output file already exists: $output_file"
        echo "Skipping ANTs registration for Skull SUV."
        return 0
    fi

    echo "Running ANTs registration for Skull SUV..."
    
    # Convert LTA to ITK format if missing
    [[ ! -f "${subj}_suv_lin-coreg2_T1.txt" ]] && lta_convert --inlta "${subj}_suv_lin-coreg2_T1.lta" --outitk "${subj}_suv_lin-coreg2_T1.txt"

    # Apply ANTs transformation
    antsApplyTransforms -d 3 -e 0 -i PET_60-90_SUV_orientOK_masked_Nodil_NoBrain.nii.gz \
                        -r ${subj}_T1_MNI.nii.gz -o "$output_file" \
                        -t ${subj}1Warp.nii.gz -t ${subj}0GenericAffine.mat \
                        -t ${subj}_suv_lin-coreg2_T1.txt -v 1 -n Linear

    echo "Finished ANTs transformation for Skull SUV: $output_file"
}

