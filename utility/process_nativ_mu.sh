#!/bin/bash

process_nativ_mu() {
    local subj="$1"
    local PET_dir_skull="$2"
    local orig_dir="${PET_dir_skull}/${subj}/PET"
    local processing_dir="${orig_dir}/SUVR_2mm-processing_ANTs"

    echo "Processing nativ_mu_Nodil_NoBrain for subject: $subj"

    # Ensure processing directory exists
    if [[ ! -d "$processing_dir" ]]; then
        echo -e "\e[31mError: Processing directory does not exist: $processing_dir\e[0m"
        return 1
    fi

    cd "$processing_dir" || { echo "Error: Cannot access $processing_dir"; return 1; }
    echo "***** Processing in: $processing_dir *****"

    # Step 1: Perform mri_coreg to create registration files if missing
    if [[ ! -f "${subj}_suv_lin-coreg2_T1.lta" || ! -f "${subj}_suv_lin-coreg2_T1.dat" ]]; then
        echo "Running mri_coreg to generate registration files..."
        mri_coreg --s "${subj}" --mov "PET_60-90_SUV_orientOK.nii.gz" \
                  --reg "${subj}_suv_lin-coreg2_T1.lta" --regdat "${subj}_suv_lin-coreg2_T1.dat" \
                  --no-ref-mask --ref T1_orientOK.nii.gz
    else
        echo "Registration files already exist. Skipping mri_coreg."
    fi

    # Step 2: Register aparc+aseg to PET if missing
    if [[ ! -f "aparc+aseg_lin_suv_Nodil_BIN.nii.gz" ]]; then
        if [[ ! -f "aparc+aseg_lin_suv.nii.gz" ]]; then
            echo "Registering aparc+aseg to PET..."
            mri_vol2vol --mov "$processing_dir/PET_60-90_SUV_orientOK.nii.gz" --targ "$processing_dir/aparc+aseg_orientOK.nii.gz" \
                        --o "$processing_dir/aparc+aseg_lin_suv.nii.gz" --reg "$processing_dir/${subj}_suv_lin-coreg2_T1.lta" \
                        --interp nearest --inv
        else
            echo "aparc+aseg_lin_suv.nii.gz already exists. Skipping registration."
        fi

        echo "Binarizing aparc+aseg for No Brain processing..."
        mri_binarize --i "$processing_dir/aparc+aseg_lin_suv.nii.gz" --min 0.5 --o "$processing_dir/aparc+aseg_lin_suv_Nodil_BIN.nii.gz"
    else
        echo "aparc+aseg_lin_suv_Nodil_BIN.nii.gz already exists. Skipping binarization."
    fi

    # Step 3: Process gated muMAP
    if [[ ! -f "$processing_dir/gated_muMAP_th_BIN_Nodil_Nativ_NoBrain.nii.gz" ]]; then
        echo "Processing muMAP for No Brain..."

        if [[ ! -f "$processing_dir/gated_muMAP_thr_BIN.nii.gz" ]]; then
            fslmaths "$orig_dir/gated_muMAP_thr_BIN.nii.gz" -fillh "$processing_dir/gated_muMAP_thr_BIN.nii.gz"
        else
            echo "gated_muMAP_thr_BIN.nii.gz already exists. Skipping fillh operation."
        fi

        fslmaths "$processing_dir/gated_muMAP_thr_BIN.nii.gz" -mas "$processing_dir/aparc+aseg_lin_suv_Nodil_BIN.nii.gz" "$processing_dir/gated_muMAP_th_BIN_Nodil_temp.nii.gz"
        fslmaths "$processing_dir/gated_muMAP_thr_BIN.nii.gz" -sub "$processing_dir/gated_muMAP_th_BIN_Nodil_temp.nii.gz" "$processing_dir/gated_muMAP_th_BIN_Nodil_Nativ_NoBrain.nii.gz"
        rm "$processing_dir/gated_muMAP_th_BIN_Nodil_temp.nii.gz"
    else
        echo "gated_muMAP_th_BIN_Nodil_Nativ_NoBrain.nii.gz already exists. Skipping muMAP processing."
    fi

    # Step 4: Mask PET with muMAP where the brain is removed (without dilation)
    if [[ ! -f "$processing_dir/PET_60-90_SUV_orientOK_masked_Nodil_NoBrain.nii.gz" ]]; then
        echo "Masking PET_60-90 SUV with muMAP..."
        fslmaths "$processing_dir/PET_60-90_SUV_orientOK.nii.gz" -mas "$processing_dir/gated_muMAP_th_BIN_Nodil_Nativ_NoBrain.nii.gz" \
                  "$processing_dir/PET_60-90_SUV_orientOK_masked_Nodil_NoBrain.nii.gz"
    else
        echo "PET_60-90_SUV_orientOK_masked_Nodil_NoBrain.nii.gz already exists. Skipping masking step."
    fi

    echo -e "\e[32mProcessing completed successfully for subject $subj.\e[0m"
}

