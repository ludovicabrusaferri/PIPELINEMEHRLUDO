#!/bin/bash

# Define paths
path="/autofs/space/storm_002/users/MigPPG_2/data/PETdata/SKULL/"   # Change this to your actual input directory
path2="$path/FSL_analyses_ANTs_nativeNoBrain/MUMAP-masks/" # Change this to your actual output directory
output_file="${path2}/group_skull_MNI.nii.gz"
subjIDlist="list3.txt"
mkdir -p $path2

# Read subjects into an array
declare -a StringArray=($(cat "$subjIDlist"))

# Check if subjects were read
if [[ ${#StringArray[@]} -eq 0 ]]; then
    echo "No subjects found in $subjIDlist. Exiting."
    exit 1
fi

dodthis="True"

if [ "$dodthis" == "True" ]; then

	# Initialize the sum image
	first_subject="${StringArray[0]}"
	first_image="${path}/${first_subject}/PET/SUVR_2mm-processing_ANTs/${first_subject}_muMAP_Nativ_Nodil_NoBrain_BIN_nl_MNI152_NN.nii.gz"

	if [[ ! -f "$first_image" ]]; then
	    echo "First subject image $first_image not found. Check file paths."
	    exit 1
	fi

	# Copy the first image as the starting point
	fslmaths "$first_image" -bin "$output_file"

	# Loop through remaining subjects and add their masks
	for subj in "${StringArray[@]:1}"; do
	    img="${path}/$subj/PET/SUVR_2mm-processing_ANTs/${subj}_muMAP_Nativ_Nodil_NoBrain_BIN_nl_MNI152_NN.nii.gz"

	    if [[ -f "$img" ]]; then
		fslmaths "$output_file" -add "$img" "$output_file"
	    else
		echo "Warning: Image for subject $subj not found at $img. Skipping."
	    fi
	done
else
	echo "DONE"
fi

# Calculate the threshold as 50% of the total number of subjects
num_subjects=${#StringArray[@]}
threshold=$(echo "$num_subjects * 0.5" | bc)  # Calculate 50%
threshold=$(printf "%.0f" "$threshold")  # Round to nearest integer

# Output the total number of subjects and the threshold
echo "Total number of subjects: $num_subjects"
echo "Calculated threshold (50% of subjects): $threshold"

# Apply threshold and binarize
threshold_output="${path2}/group_skull_MNI_50perc_${threshold}.nii.gz"
fslmaths "$output_file" -thr "$threshold" -bin "$threshold_output"

echo "Processing complete. Output saved to $threshold_output"

