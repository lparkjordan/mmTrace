function [ attenuations ] = applyAttenuators(paths, attenuators, hpbw)
%APPLYATTENUATORS Summary of this function goes here
%   Detailed explanation goes here

    edges = objToEdges(attenuators); 

    num_paths = size(paths,1);
    num_segments = sum(~isnan(getPathReflectionObject(paths)),2) + 1;
    intersect_counts = zeros(num_paths, 1);
    attenuations = zeros(num_paths, 1);
    for i = 1:num_paths
        % Number of segments is number of reflections + 1
        path_intersects = [];
        for j = 1:num_segments(i)
            if j == 1
                segment = paths(i,1:4);
            else
                segment = [paths(i,(j-2)*5+3:(j-2)*5+4), paths(i,(j-1)*5+3:(j-1)*5+4)];
            end
            intersects = intersectEdges(segment, edges);
            path_intersects = [path_intersects; intersects];
        end
        path_intersects(any(isnan(path_intersects),2),:) = [];
        
        % Calculate attenuation using analytical expression from NYUSIM
        intersect_counts(i) = size(path_intersects,1)/2;
        b = 9.8;
        var = 0.31;
        attenuations = intersect_counts .* (10*log10(b + pi/hpbw) + randn(size(attenuations))*var);
        
    end

end