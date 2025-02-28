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

    if [ "$bay7" == "True" ]; then
        # For bay7: Handling the muMAP as per the provided logic
        if [ -d ${convert_dir}/*${subj}* ] && [ -f ${convert_dir}/*${subj}*/${mumap} ]; then
            cd ${convert_dir}/*${subj}*
            echo "muMAP is in ${PWD}"
            # Get the muMAP
            echo -e "\e[31mSubject has PET data reconstructed and muMAP is available\e[0m"
            # Thresholding 0.13 and binarizing the mask
            if [ -f ${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz ] ;then
                cd ${PET_dir_skull}/${subj}/PET
                fslmaths gated_muMAP.nii.gz -thr 0.13 -bin gated_muMAP_thr_BIN.nii.gz
            else 
                scp -r ${mumap} ${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz
                fslmaths ${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz -thr 0.13 -bin ${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN.nii.gz
            fi
        elif [ -d ${convert_dir2}/*${subj}* ] && [ -f ${convert_dir2}/*${subj}*/*-Converted/30001Head_PetAcquisition_Raw_Data-LM-00/${mumap} ] ; then
            cd ${convert_dir2}/*${subj}*/*-Converted/30001Head_PetAcquisition_Raw_Data-LM-00
            echo "muMAP is in ${PWD}"
            # Get the muMAP
            echo -e "\e[31mSubject has PET data reconstructed and muMAP is available\e[0m"
            # Thresholding 0.13 and binarizing the mask
            if [ -f ${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz ] ;then
                cd ${PET_dir_skull}/${subj}/PET
                fslmaths gated_muMAP.nii.gz -thr 0.13 -bin gated_muMAP_thr_BIN.nii.gz
            else 
                scp -r ${mumap} ${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz
                fslmaths ${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz -thr 0.13 -bin ${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN.nii.gz
            fi
        else
            echo -e "\e[31mSubject has PET data that is either not reconstructed or the muMAP is unavailable\e[0m"
            echo "${subj}" >> $PET_dir_skull/subject_no_muMAP.txt
        fi
    elif [ "$bay7" == "False" ]; then
        # For bay6: Copying the different file and performing the threshold and binarize
        local bay6_filepath="${datapath}/${subj}/MR_PET/${bay6_file}"
        
        echo "Copying bay6 PET map file from $bay6_filepath"
        
        if [ -f "$bay6_filepath" ]; then
            # Copy the bay6 PET file to the same name as bay7
            cp "$bay6_filepath" "${PET_dir_skull}/${subj}/PET/gated_muMAP_orig.nii"
            mri_convert --left-right-reverse-pix "${PET_dir_skull}/${subj}/PET/gated_muMAP_orig.nii" "${PET_dir_skull}/${subj}/PET/gated_muMAP.nii"
            gzip "${PET_dir_skull}/${subj}/PET/gated_muMAP.nii"
            echo -e "\e[32mBay6 PET map copied successfully for subject $subj as gated_muMAP.nii.gz.\e[0m"

            # Thresholding 0.13 and binarizing the mask
            fslmaths "${PET_dir_skull}/${subj}/PET/gated_muMAP.nii.gz" -thr 0.13 -bin "${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN_tofill.nii.gz"
             
	    mri_binarize --i "${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN_tofill.nii.gz" --min 0.5 --dilate 1 --o "${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN_dilated.nii.gz"
	    mri_binarize --i "${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN_dilated.nii.gz" --min 0.5 --erode 1 --o "${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN.nii.gz"
           rm ${PET_dir_skull}/${subj}/PET/gated_muMAP_thr_BIN_dilated.nii.gz 

        else
            echo -e "\e[31mBay6 PET map file missing for subject $subj.\e[0m"
            echo "${subj}" >> $PET_dir_skull/subject_no_bay6_file.txt
        fi
    fi
}

