function [ attenuations ] = applyAttenuators(paths, attenuators, hpbw)
%APPLYATTENUATORS Summary of this function goes here
%   Detailed explanation goes here
    if isempty(attenuators)
        attenuations = ones(size(paths,1),1);
        return
    end
    edges = objToEdges(attenuators); 
    num_edges = size(edges,1);
    edge_lengths = vecnorm(edges(:,1:2) - edges(:,3:4),2,2);
    diagonal_lengths = sqrt(edge_lengths(1:4:end).^2 + edge_lengths(2:4:end).^2);
    associated_diagonals = reshape(repmat(diagonal_lengths,4,1),[],1);
    num_paths = size(paths,1);
    num_segments = sum(~isnan(getPathReflectionObject(paths)),2) + 1;
    total_fraction = zeros(num_paths, 1);
    attenuations = zeros(num_paths, 1);
    
    for i = 1:num_paths
        % Number of segments is number of reflections + 1
        path_intersects = zeros(num_edges,2);
        path_diagonals = repmat(associated_diagonals,num_segments(i),1);
        for j = 1:num_segments(i)
            if j == 1
                segment = paths(i,1:4);
            else
                segment = [paths(i,(j-2)*5+3:(j-2)*5+4), paths(i,(j-1)*5+3:(j-1)*5+4)];
            end
            intersects = intersectEdges(segment, edges);
            path_intersects((j-1)*num_edges+1:j*num_edges, :) = intersects;
        end
        path_diagonals(any(isnan(path_intersects),2),:) = [];  
        path_diagonals = path_diagonals(1:2:end);
        path_intersects(any(isnan(path_intersects),2),:) = [];
        
        entry_points = path_intersects(1:2:end,:);
        exit_points = path_intersects(2:2:end,:);
        vectors = entry_points - exit_points;
        distances = vecnorm(vectors,2,2);
        diagonal_fractions = distances ./ path_diagonals;
        total_fraction(i) = sum(diagonal_fractions);
        
        
    end
    % Calculate attenuation using analytical expression from NYUSIM
    b = 941;
    var = 0.31;
    attenuations = total_fraction .* (10*log10(b + pi/hpbw) + randn(size(attenuations))*var);
end