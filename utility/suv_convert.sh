#!/bin/bash

convert_to_suv() {
    local subj="$1"
    local PET_dir_skull="$2"
    local e7_dir="$3"
    local dose_weight="$4"

    echo "Converting PET to SUV for subject: $subj"

    # Ensure the dose weight file exists
    if [[ ! -f "${e7_dir}/${dose_weight}" ]]; then
        echo "Error: Dose weight file ${e7_dir}/${dose_weight} not found."
        return 1
    fi

    # Extract dose and weight for the subject
    local dose="" weight=""
    while IFS= read -r line; do
        IFS='	' read -r id dose weight <<< "$line"
        if [[ "$id" == "$subj" ]]; then
            echo "Found subject in dose file: ID=$id, Dose=$dose mCi, Weight=$weight kg"
            break
        fi
    done <"${e7_dir}/${dose_weight}"

    # Ensure valid dose and weight were found
    if [[ -z "$dose" || -z "$weight" ]]; then
        echo "Error: Missing dose or weight for subject $subj."
        return 1
    fi

    # Define the output SUV file
    local suv_file="${PET_dir_skull}/${subj}/PET/PET_60-90_SUV.nii.gz"

    # If SUV file already exists, skip conversion
    if [[ -f "$suv_file" ]]; then
        echo "SUV file already exists for $subj. Skipping conversion."
        return 0
    fi

    # Perform SUV conversion
    echo "Running SUV conversion using fslmaths..."
    fslmaths "${PET_dir_skull}/${subj}/PET/PET_60-90.nii.gz" \
        -div "$dose" -div 37000000 -mul "$weight" -mul 1000 "$suv_file"

    echo "SUV conversion completed for subject: $subj"
}

