function [suggestedParams] = assess_image_quality(image)
    
    % Assess contrast
    contrast = std2(image) / mean2(image);
    
    % Assess intensity distribution
    intensity_stats.mean = mean(image(:));
    intensity_stats.std = std(image(:));
    
    % Determine suggested parameters based on assessed metrics
    if (contrast < 0.1 && intensity_stats.mean > 0.4)
        suggestedParams.Method = 'adaptive';
        suggestedParams.Sensitivity = 0.52;
    elseif (contrast >= 0.1 && contrast < 0.2)
        suggestedParams.Method = 'adaptive';
        suggestedParams.Sensitivity = 0.35;
    elseif (contrast >= 0.1 && contrast < 0.2 && intensity_stats.mean > 0.4)
        suggestedParams.Method = 'adaptive';
        suggestedParams.Sensitivity = 0.45;
    else
        suggestedParams.Method = 'adaptive';
        suggestedParams.Sensitivity = 0.001;
    end
end
