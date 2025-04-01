#!/bin/bash

check_paths() {
    local subj="$1"
    local e7_dir="" dose_weight="" convert_dir="" convert_dir2=""
    local fs_dir="" datapath="" bay7="False"

    if [[ "$subj" == *"IGN"* ]]; then
        e7_dir="/autofs/space/sully_001/VM/scratch/mm1381/IGNITE"
        dose_weight="IGNITE_ID_dose_weight.txt"
        convert_dir="/autofs/space/sully_001/VM/scratch/mm1381/IGNITE/COLLECT"
        convert_dir2="/autofs/space/sully_002/users/Mehrbod/E7_ConvertedTemp/IGN"
        fs_dir="/autofs/space/nemo_002/users/PBR28_IGNITE/data/fs"
        bay7="True"

    elif [[ "$subj" =~ ppg_mig([0-9]+) ]]; then
        num="${BASH_REMATCH[1]}"  
        fs_dir="/autofs/space/storm_002/users/MigPPG_2/data/fs"
        if (( num > 116 )); then
            datapath="/autofs/space/storm_002/users/MigPPG_2/data/PETdata"
	    fs_dir="/autofs/space/storm_002/users/MigPPG_2/data/fs"
        else
            datapath="/autofs/space/storm_001/users/migPPG/data/PETdata"
	    fs_dir="/autofs/space/storm_001/users/migPPG/data/fs"
        fi
        bay7="False"

     elif [[ "$subj" == *"ppg"*"hv"* ]]; then
         datapath="/autofs/space/storm_002/users/MigPPG_2/data/PETdata"
	 fs_dir="/autofs/space/storm_002/users/MigPPG_2/data/fs"
        bay7="False"

    else
        echo "No PET data available for $subj" >&2
        return 1
    fi

    # Validate directories
    for path in "$e7_dir" "$convert_dir" "$convert_dir2" "$fs_dir" "$datapath"; do
        [[ -n "$path" && ! -d "$path" ]] && echo "Warning: Directory $path does not exist!" >&2
    done

    # Export variables for the main script
    echo "e7_dir='$e7_dir'"
    echo "dose_weight='$dose_weight'"
    echo "convert_dir='$convert_dir'"
    echo "convert_dir2='$convert_dir2'"
    echo "fs_dir='$fs_dir'"
    echo "datapath='$datapath'"
    echo "bay7='$bay7'"
}

# Call function with the first argument
check_paths "$1"

