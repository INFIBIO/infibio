% Define the paths for data
imgpath = 'C:\Users\uib\Desktop\zymo_exp_subset\';
datapath = [imgpath, 'data/'];
load(fullfile(datapath, 'tracks.mat'));  % Load the 'tracks.mat' data

% Extract relevant columns from the data file
kappa = tracks(:, 4:203);                % Curvature columns (kappa)
theta = tracks(:, 204:403);              % Curvature columns (theta)
fourierDescriptors = tracks(:, 404:553); % Fourier descriptors columns
frames = real(tracks(:, 554));           % Column 405: Frame
cell_ids = real(tracks(:, 556));         % Column 407: Cell ID

% Get the unique list of cell IDs
unique_cell_ids = unique(cell_ids);

% Number of Fourier coefficients to use for reconstruction
num_coeff = 30; % You can adjust this as needed

% Create a figure for each cell
for i = 1:3
    % Filter data for the current cell
    current_cell_id = unique_cell_ids(i);
    idx = cell_ids == current_cell_id;  % Indices corresponding to the current cell
    
    % Extract the curvature values and corresponding frames
    kappa_current_cell = kappa(idx, :);
    theta_current_cell = theta(idx, :);
    fourierDescriptors_current_cell = fourierDescriptors(idx, :);
    frames_current_cell = frames(idx);
    
    % Determine the reference curve (the first curve for kappa and theta)
    ref_curve_kappa = kappa_current_cell(1, :);
    ref_curve_theta = theta_current_cell(1, :);
    
    % Initialize matrices to store the aligned curves
    kappa_aligned = zeros(size(kappa_current_cell));
    theta_aligned = zeros(size(theta_current_cell));

    % Initialize matrices to store the differences
    diff_with_initial_kappa = zeros(1, length(frames_current_cell));
    diff_with_previous_kappa = zeros(1, length(frames_current_cell));
    diff_with_initial_theta = zeros(1, length(frames_current_cell));
    diff_with_previous_theta = zeros(1, length(frames_current_cell));
    
    % Align each curve with the reference curve using circular rotation
    for j = 1:length(frames_current_cell)
        % Current curves for kappa and theta
        current_curve_kappa = kappa_current_cell(j, :);
        current_curve_theta = theta_current_cell(j, :);
        
        % Calculate the cross-correlation and determine the optimal shift
        [cross_corr_kappa, lags_kappa] = xcorr(current_curve_kappa, ref_curve_kappa);
        [cross_corr_theta, lags_theta] = xcorr(current_curve_theta, ref_curve_theta);

        % Get the shift indices that maximize the correlation
        [~, max_idx_kappa] = max(cross_corr_kappa);
        shift_kappa = lags_kappa(max_idx_kappa);
        [~, max_idx_theta] = max(cross_corr_theta);
        shift_theta = lags_theta(max_idx_theta);
        
        % Adjust the current curves using circular rotation
        current_curve_aligned_kappa = circshift(current_curve_kappa, -shift_kappa);
        current_curve_aligned_theta = circshift(current_curve_theta, -shift_theta);
        
        % Save the aligned curves
        kappa_aligned(j, :) = current_curve_aligned_kappa;
        theta_aligned(j, :) = current_curve_aligned_theta;
        
        % Calculate the difference with the initial curve (reference)
        diff_with_initial_kappa(j) = sum(abs(current_curve_aligned_kappa - ref_curve_kappa));
        diff_with_initial_theta(j) = sum(abs(current_curve_aligned_theta - ref_curve_theta));
        
        % Calculate the difference with the previous curve if not the first frame
        if j > 1
            diff_with_previous_kappa(j) = sum(abs(current_curve_aligned_kappa - kappa_aligned(j-1, :)));
            diff_with_previous_theta(j) = sum(abs(current_curve_aligned_theta - theta_aligned(j-1, :)));
        else
            diff_with_previous_kappa(j) = NaN; % No previous curve for the first frame
            diff_with_previous_theta(j) = NaN; % No previous curve for the first frame
        end
    end
    
    % Reconstruct cell shape from Fourier descriptors
    figure;

    hold on; % Hold on to overlay plots


for j = 1:length(frames_current_cell)
    num_coeff = 15;

    % Extract the Fourier descriptors for the current frame
    Z = fourierDescriptors_current_cell(j, :)';

    % Reconstruct the shape using the specified number of coefficients
    Z_reconstructed = zeros(size(Z));

    % Encuentra el primer índice donde el valor es igual a 0
    first_zero_idx = find(Z == 0, 1);

    % Determina el índice final basado en num_coeff o el primer 0 encontrado
    if isempty(first_zero_idx)
        end_idx = num_coeff;
    else
        end_idx = min(num_coeff, first_zero_idx - 1);
    end

    % Asignar coeficientes hasta el índice final calculado
    Z_reconstructed(1:end_idx) = Z(1:end_idx);
    Z_reconstructed(end-end_idx+1:end) = Z(end-end_idx+1:end);

    % Reconstruct the shape using the specified coefficients
    z_reconstructed = ifft(Z_reconstructed);

    % Extract the real and imaginary parts
    z_real = real(z_reconstructed);
    z_imag = imag(z_reconstructed);

    % Calculate centroid (mean of the real and imaginary parts)
    centroid_x = mean(z_real);
    centroid_y = mean(z_imag);

    % Center the shape at the origin by subtracting the centroid
    z_real = z_real - centroid_x;
    z_imag = z_imag - centroid_y;

    % Plot the reconstructed shape, overlaying each frame
    plot(z_real, z_imag, 'LineWidth', 1.5); % Use a consistent color or differentiate by color
    
end

% Set axis properties and labels

xlabel('X');
ylabel('Y');
legend(arrayfun(@(x) sprintf('Frame %d', x), frames_current_cell, 'UniformOutput', false), 'Location', 'bestoutside');
axis equal;
hold off; % Release the hold after plotting all frames
sgtitle(sprintf('Shape over time of cell %d', current_cell_id));
    
    % Create and configure the figure for kappa curvature and differences
    figure;
    subplot(2, 1, 1); % Subplot for aligned kappa curves
    hold on;
    for j = 1:length(frames_current_cell)
        plot(1:size(kappa_aligned, 2), kappa_aligned(j, :));  % Plot aligned kappa
    end
    hold off;
    xlabel('Curvature Points');
    ylabel('Curvature (Kappa)');
    title(sprintf('Circularly aligned curvature of cell %d across different frames', current_cell_id));
    legend(arrayfun(@(x) sprintf('Frame %d', x), frames_current_cell, 'UniformOutput', false), 'Location', 'bestoutside');
    
    subplot(2, 1, 2); % Subplot for kappa differences
    bar([diff_with_initial_kappa; diff_with_previous_kappa]', 'grouped');
    xlabel('Frame');
    ylabel('SAD Curvature');
    title('Kappa differences with initial and previous curves');
    legend('With initial', 'With previous', 'Location', 'bestoutside');
    
    % Create and configure the figure for theta curvature and differences
    figure;
    subplot(2, 1, 1); % Subplot for aligned theta curves
    hold on;
    for j = 1:length(frames_current_cell)
        plot(1:size(theta_aligned, 2), theta_aligned(j, :));  % Plot aligned theta
    end
    hold off;
    xlabel('Theta Points');
    ylabel('Curvature (Theta)');
    title(sprintf('Circularly aligned theta of cell %d across different frames', current_cell_id));
    legend(arrayfun(@(x) sprintf('Frame %d', x), frames_current_cell, 'UniformOutput', false), 'Location', 'bestoutside');
    
    subplot(2, 1, 2); % Subplot for theta differences
    bar([diff_with_initial_theta; diff_with_previous_theta]', 'grouped');
    xlabel('Frame');
    ylabel('SAD Theta');
    title('Theta differences with initial and previous curves');
    legend('With initial', 'With previous', 'Location', 'bestoutside');
end
