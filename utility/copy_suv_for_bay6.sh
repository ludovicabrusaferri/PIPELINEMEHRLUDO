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

    # Debugging: Print paths
    echo "Source file: $filename"
    echo "Original target file: $target_file_orig"
    echo "Final target file: $target_file"

    # Ensure the subject directory exists
    if [[ ! -d "$subject_dir" ]]; then
        mkdir -p "$subject_dir"
        echo "Created subject directory: $subject_dir"
    fi

    # Ensure the PET directory exists
    if [[ ! -d "$pet_dir" ]]; then
        mkdir -p "$pet_dir"
        echo "Created PET directory: $pet_dir"
    fi

    # Ensure the source PET file exists
    if [[ ! -f "$filename" ]]; then
        echo "Error: PET file not found for subject $subj at $filename"
        return 1
    fi

    # If the final compressed target file already exists, skip copying
    if [[ -f "$target_file" ]]; then
        echo "File already exists for $subj. Skipping copy."
        PETinputfile="$target_file"
        export PETinputfile
        return 0
    fi

    # Copy the source file to the original target location
    cp "$filename" "$target_file_orig"

    # Perform left-right flipping using mri_convert
    mri_convert --left-right-reverse-pix "$target_file_orig" "$target_file"

    # Compress the final file
    gzip -f "$target_file"

    # Set PETinputfile to the final output file
    PETinputfile="${target_file}.gz"
    export PETinputfile

    echo "PET file copied, converted, and compressed for bay6 subject: $subj"
}


