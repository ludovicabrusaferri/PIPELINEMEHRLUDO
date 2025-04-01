#!/bin/bash

copy_mu_map_for_bayX() {
    local subj="$1"
    local PET_dir_skull="$2"
    local convert_dir="$3"
    local convert_dir2="$4"
    local datapath="$5"
    local bay7="$6"  # Either bay7 or bay6
    local mumap="30001Head_PetAcquisition_Raw_Data-umap_ref.nii.gz"
    local bay6_file="ratt_map_latePET.nii"
    local gated_mumap="${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz"
    
    echo "Processing muMAP for subject: $subj (Bay7: $bay7)"

    if [[ "$bay7" == "True" ]]; then
	echo $convert_dir
	echo $convert_dir2
        # For bay7: Handling the muMAP retrieval and copying
        if [[ -d ${convert_dir}/*${subj}* && -f ${convert_dir}/*${subj}*/${mumap} ]]; then
            cd ${convert_dir}/*${subj}*
            echo "muMAP is located at ${PWD}"

        elif [[ -d ${convert_dir2}/${subj} ]]; then
	echo I AM HERE
            cd ${convert_dir2}/*${subj}*/*-Converted/30001Head_PetAcquisition_Raw_Data-LM-00
            echo "muMAP is located at ${PWD}"
        else
            echo -e "\e[31mSubject has PET data that is either not reconstructed or the muMAP is unavailable\e[0m"
            echo "${subj}" >> "$PET_dir_skull/subject_no_muMAP.txt"
            return 1
        fi

        # Copy muMAP if it doesn't already exist
        if [[ ! -f "$gated_mumap" ]]; then
            echo "Copying muMAP to PET directory..."
            cp "$mumap" "$gated_mumap"
        else
            echo "muMAP already exists for $subj. Skipping copy."
        fi

    elif [[ "$bay7" == "False" ]]; then
        # For bay6: Copying the different muMAP file
        local bay6_filepath="${datapath}/${subj}/MR_PET/${bay6_file}"

        echo "Copying Bay6 PET map file from $bay6_filepath"

        if [[ -f "$bay6_filepath" ]]; then
            # Copy the bay6 PET file to the same name as bay7, avoid overwrite
            local gated_mumap_orig="${PET_dir_skull}/${subj}/PET/gated_muMAP_orig.nii"
            
            [[ ! -f "$gated_mumap_orig" ]] && cp "$bay6_filepath" "$gated_mumap_orig"

            [[ ! -f "$gated_mumap" ]] && mri_convert --left-right-reverse-pix "$gated_mumap_orig" "${PET_dir_skull}/${subj}/PET/gated_muMAP.nii" && gzip "${PET_dir_skull}/${subj}/PET/gated_muMAP.nii"
        else
            echo -e "\e[31mBay6 PET map file missing for subject $subj.\e[0m"
            echo "${subj}" >> "$PET_dir_skull/subject_no_bay6_file.txt"
            return 1
        fi
    fi

    # Perform common thresholding and binarization for both Bay7 and Bay6
    local binarized_file="${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN_tofill.nii.gz"
    local final_file="${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN.nii.gz"
    local tmp_file="${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN_dilated.nii.gz"

    if [[ ! -f "$binarized_file" ]]; then
        echo "Performing thresholding and binarization..."
        fslmaths "$gated_mumap" -thr 0.13 -bin "$binarized_file"
        
        echo "Applying dilation and erosion..."
	fslmaths $binarized_file -fillh $final_file
        mri_binarize --i "$final_file" --min 0.5 --dilate 1.5 --o "$tmp_file"
        mri_binarize --i "$tmp_file" --min 0.5 --erode 1.5 --o "$final_file"
        rm "$tmp_file"
    else
        echo "Thresholding and binarization already completed for $subj. Skipping."
    fi

    echo -e "\e[32mmuMAP processing completed successfully for subject $subj.\e[0m"
}


