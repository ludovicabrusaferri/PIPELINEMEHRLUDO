#!/bin/bash

copy_suv_for_bay6() {
    local subj="$1"
    local PET_dir_skull="$2"
    local filename="$3"

    echo "Copying PET file for bay6 subject: $subj"

    # Define subject and PET directories
    local subject_dir="${PET_dir_skull}/${subj}"
    local pet_dir="${subject_dir}/PET"
    local target_file_orig="${pet_dir}/PET_60-90_SUV_orig.nii"
    local target_file="${pet_dir}/PET_60-90_SUV.nii"
    local target_file_gz="${pet_dir}/PET_60-90_SUV.nii.gz"

    # Debugging: Print paths
    echo "Source file: $filename"
    echo "Original target file: $target_file_orig"
    echo "Final target file: $target_file_gz"

    # Ensure directories exist
    mkdir -p "$subject_dir" "$pet_dir"

    # Ensure the source PET file exists
    if [[ ! -f "$filename" ]]; then
        echo "Error: PET file not found for subject $subj at $filename"
        return 1
    fi

    # Check if the final gzipped PET file already exists
    if [[ -f "$target_file_gz" ]]; then
        echo "PET file already exists for $subj. Skipping processing."
        PETinputfile="$target_file_gz"
        export PETinputfile
        return 0
    fi

    # If the original file is missing, copy it
    if [[ ! -f "$target_file_orig" ]]; then
        echo "Copying original PET file..."
        cp "$filename" "$target_file_orig"
    else
        echo "Original PET file already exists. Skipping copy."
    fi

    # If the converted file is missing, perform left-right flipping
    if [[ ! -f "$target_file" ]]; then
        echo "Performing left-right flipping using mri_convert..."
        mri_convert --left-right-reverse-pix "$target_file_orig" "$target_file"
    else
        echo "Left-right flipped PET file already exists. Skipping conversion."
    fi

    # If the compressed file is missing, compress it
    if [[ ! -f "$target_file_gz" ]]; then
        echo "Compressing PET file..."
        gzip -f "$target_file"
    else
        echo "Compressed PET file already exists. Skipping compression."
    fi

    # Set PETinputfile to the final output file
    PETinputfile="$target_file_gz"
    export PETinputfile

    echo "Final PET file for bay6 subject $subj: $PETinputfile"
}

