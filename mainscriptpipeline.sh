#!/bin/bash

# Define main paths
PET_dir_origin="/autofs/space/storm_002/users/MigPPG_2/data/PETdata/"
subjlistpath="$PWD"
PET_dir_skull="/autofs/space/storm_002/users/MigPPG_2/data/PETdata/SKULL/"
convert_dir="/path/to/convert_dir"  # Update this path accordingly

# Change to PET directory
cd "$PET_dir_skull" || { echo -e "\e[31mError: Cannot access $PET_dir_skull\e[0m"; exit 1; }
echo "Current Directory: $PWD"

# Ensure all utility scripts exist before sourcing
UTIL_DIR="$subjlistpath/utility"
for script in checkpaths.sh checkfiles.sh cp_pet.sh suv_convert.sh copy_suv_for_bay6.sh copy_mu_map_for_bayX.sh process_files.sh process_nativ_mu.sh register_T1_to_MNI.sh apply_ants_transform_mumap.sh apply_ants_transform_suv.sh makecope_suv_mni_5mm.sh ; do
    [[ -f "$UTIL_DIR/$script" ]] || { echo -e "\e[31mError: $script not found in utility directory\e[0m"; exit 1; }
    source "$UTIL_DIR/$script"
done

# Read subject list and process each subject
while IFS= read -r subj; do
    echo "Processing Subject: $subj"

    # Run check_paths.sh and capture variables
    eval "$(bash "$UTIL_DIR/checkpaths.sh" "$subj")"
    [[ $? -ne 0 ]] && { echo -e "\e[31mSkipping $subj due to missing PET data.\e[0m"; continue; }

    echo "Datapath for $subj: $datapath"

    # Check PET files before copying
    check_files "$subj" "$datapath" "$bay7"
    [[ $? -ne 0 || -z "$filename" ]] && { echo -e "\e[31mError: PET file missing or filename not set. Skipping subject $subj.\e[0m"; continue; }

    # STEP 1 bay7 ============  this is temporary because i am not sure of e7 organiz
    [[ "$bay7" == "True" ]] && cp_pet "$subj" "$PET_dir_skull" "$PET_dir_origin" "$convert_dir" "$bay7"
    [[ "$bay7" == "True" ]] && suv_convert "$subj" "$PET_dir_skull" "$e7_dir" "$dose_weight"
    # STEP 1 bay6 ============  IMPORTANT: for bay6 we also perfom right-left flipping to both PET and mu-map 
    [[ "$bay7" == "False" ]] && copy_suv_for_bay6 "$subj" "$PET_dir_skull" "$filename"
    
    # STEP 2 ============ i only tested this for bay6
    copy_mu_map_for_bayX "$subj" "$PET_dir_skull" "$convert_dir" "$convert_dir2" "$datapath" "False"

    # FROM NOW ON EVERYTHING IS THE SAME IN BOTH BAYS 

    # STEP 3 ============ .. making fun stuff
    mkdir -p "$PET_dir_skull/$subj/PET/SUVR_2mm-processing_ANTs/" && process_files "$subj" "$fs_dir" "$PET_dir_skull" "$bay7" "$PETinputfile"
    
    # STEP 4 ============ .. making more fun stuff
    process_nativ_mu "$subj" "$PET_dir_skull"
    # STEP 5 =========== ANTS
    register_T1_to_MNI "$subj" "$PET_dir_skull"
    # STEP 6 ===========  Apply ANTs transformation to muMAP
    apply_ants_transform_mumap "$subj" "$PET_dir_skull"
    # STEP 7 ===========  Apply ANTs transformation to Skull SUV
    apply_ants_transform_suv "$subj" "$PET_dir_skull"
    # STEP 8 ====== Apply 5mm Gaussian smoothing and process Skull SUV in MNI space
    makecope_suv_mni_5mm "$subj" "$PET_dir_skull"



    echo "---------------------------------"
done < "${subjlistpath}/list.txt"

echo -e "\e[32mProcessing completed for all subjects in list.txt.\e[0m"

