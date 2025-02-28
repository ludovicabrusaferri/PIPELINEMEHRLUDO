#!/bin/bash

process_files() {
    local subj="$1"
    local FSdir="$2"
    local PET_dir_skull="$3"
    local bay7="$4"
    local PETinputfile="$5"

    # Define SUV directory within PET directory
    local SUVdir="${PET_dir_skull}/${subj}/PET/SUVR_2mm-processing_ANTs"

    echo "Processing SUV files for subject: $subj"

    # Ensure SUV directory exists
    mkdir -p "$SUVdir"

    # Check and process T1
    if [ ! -f "$SUVdir/T1_orientOK.nii.gz" ]; then
        echo "Converting T1.mgz to T1.nii.gz and reorienting..."
        mri_convert "${FSdir}/${subj}/mri/T1.mgz" "$SUVdir/T1.nii.gz"
        fslswapdim "$SUVdir/T1.nii.gz" RL PA IS "$SUVdir/T1_orientOK.nii.gz"
    fi

    # Check and process brain mask
    if [ ! -f "$SUVdir/brainmask_orientOK.nii.gz" ]; then
        echo "Converting brainmask.mgz to brainmask.nii.gz and reorienting..."
        mri_convert "${FSdir}/${subj}/mri/brainmask.mgz" "$SUVdir/brainmask.nii.gz"
        fslswapdim "$SUVdir/brainmask.nii.gz" RL PA IS "$SUVdir/brainmask_orientOK.nii.gz"
    fi

    # Check and process aparc+aseg
    if [ ! -f "$SUVdir/aparc+aseg_orientOK.nii.gz" ]; then
        echo "Converting aparc+aseg.mgz to aparc+aseg.nii.gz and reorienting..."
        mri_convert "${FSdir}/${subj}/mri/aparc+aseg.mgz" "$SUVdir/aparc+aseg.nii.gz"
        fslswapdim "$SUVdir/aparc+aseg.nii.gz" RL PA IS "$SUVdir/aparc+aseg_orientOK.nii.gz"
    fi

    # Check and process PET file
    if [ ! -f "$SUVdir/PET_60-90_SUV_orientOK.nii.gz" ]; then
	
        if [ "$bay7" == "True" ]; then
            echo "Reorienting PET file for bay7 subject..."
            fslswapdim "$PETinputfile" RL PA IS "$SUVdir/PET_60-90_SUV_orientOK.nii.gz"
        elif [ "$bay7" == "False" ]; then
            echo "Copying PET file for bay6 subject..."
            cp "$PETinputfile" "$SUVdir/PET_60-90_SUV_orientOK.nii.gz"
        fi
    fi

    # Check and process aparc+aseg binary file
    if [ ! -f "$SUVdir/aparc+aseg_orientOK_BIN.nii.gz" ]; then
        echo "Binarizing aparc+aseg..."
        mri_binarize --i "$SUVdir/aparc+aseg_orientOK.nii.gz" --min 0.5 --dilate 1 --o "$SUVdir/aparc+aseg_orientOK_BIN.nii.gz"
       
        fslmaths "$SUVdir/T1_orientOK.nii.gz" -mas "$SUVdir/aparc+aseg_orientOK_BIN.nii.gz" "$SUVdir/T1_skullstripped_orientOK.nii.gz"
    fi
}


