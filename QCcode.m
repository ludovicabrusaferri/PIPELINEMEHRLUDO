clear all
% Set base paths
scriptsPath = '/autofs/space/storm_002/users/MigPPG_2/data/PETdata/SKULL/FSL_analyses_ANTs_nativeNoBrain/Scripts/PIPELINEMEHRLUDO/';
cd(scriptsPath);
subjectList = readlines(fullfile(pwd, 'list2.txt'));

% Generate unique PDF filename using UNIX time
timestamp = posixtime(datetime('now'));
outputPDF = fullfile(pwd, sprintf('PET_visualizations_%d.pdf', round(timestamp)));
fprintf('Output PDF will be: %s\n', outputPDF);

% Fixed file
file4 = '/autofs/space/storm_002/users/MigPPG_2/data/PETdata/SKULL/FSL_analyses_ANTs_nativeNoBrain/standard.nii.gz';
if ~isfile(file4)
    error('Fixed file4 (%s) does not exist!', file4);
else
    vol4 = niftiread(file4);
end

skippedSubjects = {};

% Loop through subjects
for i = 1:length(subjectList)
    subj = strtrim(subjectList(i));
    dataPath = sprintf('/autofs/space/storm_002/users/MigPPG_2/data/PETdata/SKULL/%s/PET/',subj);

    % Check subject folder
    if ~isfolder(dataPath)
        warning('Skipping %s: folder not found.', subj);
        skippedSubjects{end+1} = subj; %#ok<SAGROW>
        continue;
    end

    % File paths
    file1 = fullfile(dataPath, sprintf('SUVR_2mm-processing_ANTs/%s_t1_lin-coreg2_suv.nii.gz',subj));
    file2 = fullfile(dataPath, 'gated_muMAP_thr_BIN.nii.gz');
    file3 = fullfile(dataPath, 'PET_60-90_SUV.nii.gz');
    file5 = fullfile(dataPath, sprintf('SUVR_2mm-processing_ANTs/%s_muMAP_Nativ_Nodil_NoBrain_BIN_nl_MNI152_NN.nii.gz',subj));

    % Check if all required files exist
    if ~isfile(file1) || ~isfile(file2) || ~isfile(file3) || ~isfile(file5)
        warning('Skipping %s: missing one or more files.', subj);
        skippedSubjects{end+1} = subj; %#ok<SAGROW>
        continue;
    end
    
    % Load volumes
    vol1 = niftiread(file1);
    vol2 = niftiread(file2);
    vol3 = niftiread(file3);
    vol5 = niftiread(file5);

    % Define 3 slice positions
    slices = round([0.3, 0.6, 0.9] * size(vol1,3));

    % Create invisible figure
    fig = figure('Visible', 'off');
    sgtitle(sprintf('Subject: %s', subj), 'FontSize', 14);

    for j = 1:3
        slice_idx = slices(j);

        % --- subplot(3,3,1:3) ---
        subplot(3,3,3*(j-1)+1);
        imagesc(vol1(:,:,slice_idx));
        colormap(gca, 'gray');
        axis image off;
        hold on;
        redMask = vol2(:,:,slice_idx) > 0;
        h = imshow(cat(3, ones(size(redMask)), zeros(size(redMask)), zeros(size(redMask))));
        set(h, 'AlphaData', 0.5 * double(redMask));
        title(sprintf('T1 with Skull Slice %d', slice_idx));

        % --- subplot(3,3,2:3) ---
        subplot(3,3,3*(j-1)+2);
        imagesc(vol3(:,:,slice_idx), [0 2]);
        colormap(gca, 'jet');
        colorbar;
        axis image off;
        hold on;
        h = imshow(cat(3, ones(size(redMask)), zeros(size(redMask)), zeros(size(redMask))));
        set(h, 'AlphaData', 0.5 * double(redMask));
        title(sprintf('PET & Skull Mask Slice %d', slice_idx));

        % --- subplot(3,3,3:3) ---
        subplot(3,3,3*(j-1)+3);
        imagesc(vol4(:,:,slice_idx));
        colormap(gca, 'gray');
        axis image off;
        hold on;
        redMask5 = vol5(:,:,slice_idx) > 0;
        h = imshow(cat(3, ones(size(redMask5)), zeros(size(redMask5)), zeros(size(redMask5))));
        set(h, 'AlphaData', 0.5 * double(redMask5));
        title(sprintf('MNI Skull Slice %d', slice_idx));
    end

    % --- Export to PDF ---
    exportgraphics(fig, outputPDF, 'Append', true);
    close(fig); % close to free memory
    
end

fprintf('Saved PDF: %s\n', outputPDF);
disp('Skipped subjects:');
disp(skippedSubjects);
