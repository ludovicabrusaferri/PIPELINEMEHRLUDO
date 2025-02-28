#!/bin/bash

check_files() {
    local subj="$1"
    local datapath="$2"
    local bay7="$3"

    echo "Checking PET files for subject: $subj in $datapath"

    if [[ "$bay7" == "True" ]]; then
        filename="PET_60-90.nii.gz"
        echo "Bay7 detected. Using static filename: $filename"
    else
        echo "Bay6 detected. Looking for PET file..."
        filename=$(ls "$datapath/$subj/PET/STATIC_60-90recon/"*"$subj"*suv*nii* 2>/dev/null)

        # Debug: Check if ls command found any file
        if [[ -z "$filename" ]]; then
            echo -e "\e[31mError: No valid PET file found for subject $subj in $datapath/$subj/PET/STATIC_60-90recon/\e[0m"
            ls "$datapath/$subj/PET/STATIC-60-90recon/" 2>/dev/null  # Print contents of the folder
            return 1
        fi
    fi

    echo -e "\e[32mFound PET file: $filename\e[0m"
    export filename  # Make filename available in main_script.sh
}

# Call function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_files "$@"
fi

