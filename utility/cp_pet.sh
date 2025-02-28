#!/bin/bash

copy_pet() {
    local subj="$1"
    local PET_dir_skull="$2"
    local PET_dir_origin="$3"
    local convert_dir="$4"
    local bay7="$5"

    echo "Copying PET data for subject: $subj"

    # Ensure subject folder exists
    if [[ ! -d "${PET_dir_skull}/${subj}" ]]; then
        if [[ -d "${PET_dir_origin}/${subj}/PET" ]]; then
            mkdir -p "${PET_dir_skull}/${subj}"
            echo -e "\e[32mSubject folder created: ${subj}\e[0m"
        elif [[ -d ${convert_dir}/*${subj}* ]]; then
            mkdir -p "${PET_dir_skull}/${subj}"
            echo -e "\e[32mSubject folder created from convert_dir: ${subj}\e[0m"
        else
            echo -e "\e[31mSubject folder exists under PET\e[0m"
        fi
    fi

    # Ensure PET directory exists inside subject folder
    if [[ ! -d "${PET_dir_skull}/${subj}/PET" ]]; then
        mkdir -p "${PET_dir_skull}/${subj}/PET"
        echo -e "\e[32mPET folder created for ${subj}\e[0m"
    else
        echo -e "\e[33mPET folder already exists for ${subj}\e[0m"
    fi

    # Determine PET filename
    local pet_filename="PET_60-90.nii.gz"
    if [[ "$bay7" == "False" ]]; then
        pet_filename=$(ls "$PET_dir_origin/${subj}/PET/"*"$subj"*suv*nii* 2>/dev/null)
    fi

    # Copy PET files
    if [[ ! -f "${PET_dir_skull}/${subj}/PET/$pet_filename" && -f "$PET_dir_origin/${subj}/PET/$pet_filename" ]]; then
        cp "$PET_dir_origin/${subj}/PET/$pet_filename" "${PET_dir_skull}/${subj}/PET/$pet_filename"
        

        echo -e "\e[32mPET file copied: ${pet_filename}\e[0m"

        cp "$PET_dir_origin/${subj}/PET/PET_60-90_SUV.nii.gz" "${PET_dir_skull}/${subj}/PET/PET_60-90_SUV.nii.gz"
        echo -e "\e[32mSUV PET file copied for ${subj}\e[0m"

    elif [[ ! -f "${PET_dir_skull}/${subj}/PET/$pet_filename" && -d ${convert_dir}/*${subj}*/gated_PET_stage_3/ ]]; then
        cp "${convert_dir}/*${subj}*/gated_PET_stage_3/summed_aligned_30001Head_PetAcquisition_Raw_Data-LM-00-OP_000.v.nii.gz" \
           "${PET_dir_skull}/${subj}/PET/$pet_filename"
        
        echo -e "\e[32mAlternative PET file copied for ${subj}\e[0m"

    else
        echo -e "\e[31mNO PET found for subject: ${subj}\e[0m"
        return 1
    fi
}

