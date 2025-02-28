#!/bin/bash

register_T1_to_MNI() {
    local subj="$1"
    local PET_dir_skull="$2"
    local path_mni=/autofs/cluster/pubsw/2/pubsw/Linux2-2.3-x86_64/packages/fsl.64bit/6.0.5.1/data/standard

    echo "Running ANTs T1 to MNI for subject: $subj"

    # Set number of threads for ANTs
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=40

    # Define fixed MNI reference
    local fixed_MNI="${path_mni}/MNI152_T1_1mm.nii.gz"

    # Define subject processing directory
    local processing_dir="${PET_dir_skull}/${subj}/PET/SUVR_2mm-processing_ANTs"
    [[ ! -d "$processing_dir" ]] && { echo -e "\e[31mError: Processing directory does not exist: $processing_dir\e[0m"; return 1; }

    cd "$processing_dir" || { echo "Error: Cannot access $processing_dir"; return 1; }
    
    # Define ANTs registration parameters
    local AffineParameters=" -m mattes[ ${fixed_MNI}, T1_orientOK.nii.gz, 1, 32, Regular, 0.05 ] -u 1 -t Affine[1] -f 6x4x2x1 -s 4x2x1x0 --winsorize-image-intensities [0.005, 0.995] -c [10000x10000x1500x20, 1.e-8, 20] -l 1 "
    local DeformParameters=" -m CC[ ${fixed_MNI}, T1_orientOK.nii.gz, 1, 4 ] -t SyN[0.2,3,0] -f 6x4x2x1 -s 3x2x1x0 --winsorize-image-intensities [0.005, 0.995] -c [200x200x200x200, 1e-8, 8] -u 1 -l 1 "

    echo "Registering T1 to MNI using ANTs for subject ${subj}"

    # Run ANTs registration if output file doesn't exist
    if [[ ! -f "${subj}_T1_MNI.nii.gz" ]]; then
        echo "ANTs is running for $subj..."
        antsRegistration -d 3 -v 1 -o [${subj}, ${subj}_T1_MNI.nii.gz, ${subj}_MNI_T1.nii.gz] \
                         -r [${fixed_MNI}, T1_orientOK.nii.gz, 0] \
                         ${AffineParameters} ${DeformParameters}
    else
        echo "ANTs has already been run for $subj."
    fi
}

