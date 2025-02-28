#!/bin/bash

makecope_suv_mni_5mm() {
    local subj="$1"
    local PET_dir_skull="$2"

    echo "Applying 5mm Gaussian smoothing to Skull SUV in MNI space for subject: $subj"

    local processing_dir="${PET_dir_skull}/${subj}/PET/SUVR_2mm-processing_ANTs"
    local stats_dir="${PET_dir_skull}/FSL_analyses_ANTs_nativeNoBrain/stats"
    local smoothed_output="${processing_dir}/${subj}_SUV_nl_MNI152_Linterp-WHmaskNativ_Nodil_Bone_NoBrain_sm5mm.nii.gz"
 
    mkdir -p $stats_dir

    # Ensure processing directory exists
    [[ ! -d "$processing_dir" ]] && { echo -e "\e[31mError: Processing directory does not exist: $processing_dir\e[0m"; return 1; }

    cd "$processing_dir" || { echo "Error: Cannot access $processing_dir"; return 1; }

    # Check if the input SUV file exists before smoothing
    if [[ ! -f "${subj}_SUV_nl_MNI152_Linterp-WHmaskNativ_Nodil_Bone_NoBrain.nii.gz" ]]; then
        echo -e "\e[31mError: Input Skull SUV file not found. Cannot proceed with smoothing.\e[0m"
        return 1
    fi

    # Apply Gaussian smoothing (5mm FWHM)
    echo "Smoothing SUV Skull image with 5mm FWHM Gaussian kernel..."
    fslmaths "${subj}_SUV_nl_MNI152_Linterp-WHmaskNativ_Nodil_Bone_NoBrain.nii.gz" \
             -kernel gauss 2.12 -fmean "$smoothed_output" -odt float

    echo "Finished smoothing: $smoothed_output"


    # Copy the smoothed file to the MNI directory
    cp "$smoothed_output" "$processing_dir/${subj}_SUV_nl_MNI152_Linterp-WHmaskNativ_Nodil_Bone_NoBrain_sm5mm.nii.gz"

    # Copy to stats directory as cope1 file
    cp "$smoothed_output" "$stats_dir/cope1_${subj}_SUV_nl_MNI152_Linterp-WHmaskNativ_Nodil_Bone_NoBrain_sm5mm.nii.gz"

    # Create varcope1 file (binary mask)
    echo "Creating varcope1 binary mask..."
    fslmaths "$smoothed_output" -bin "$stats_dir/varcope1_${subj}_SUV_nl_MNI152_Linterp-WHmaskNativ_Nodil_Bone_NoBrain_sm5mm.nii.gz"

    echo "Completed processing for subject: $subj"
}

