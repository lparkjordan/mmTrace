function [ attenuations ] = applyAttenuators(paths, attenuators, hpbw)
%APPLYATTENUATORS Summary of this function goes here
%   Detailed explanation goes here
    if isempty(attenuators)
        attenuations = ones(size(paths,1),1);
        return
    end
    num_paths = size(paths,1);
    attenuations = zeros(num_paths, 1);
    thickness = attenuators(5);
    permittivity = attenuators(6);
    if(thickness == 0)
        edges = objToEdges(attenuators); 
        num_edges = size(edges,1);
        edge_lengths = vecnorm(edges(:,1:2) - edges(:,3:4),2,2);
        diagonal_lengths = sqrt(edge_lengths(1:4:end).^2 + edge_lengths(2:4:end).^2);
        associated_diagonals = reshape(repmat(diagonal_lengths,4,1),[],1);
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
    else
        
        %% Initialization of thickness parameters for a dry wall and a glass obstacle
        % The values of attenuation is taken from the paper:
        % https://telecominfraproject.com/wp-content/uploads/TIP_mmWave-Networks_Analysis-of-28GHz-and-60GHz-Channel-Measurements-in-an-Indoor-Environment_August-2019.pdf

%         dry_wall = [0.012 , -1.5; 0.024, -2; 0.036, -3.1; 0.048, -5.2];
%         glass = (0:180)';
%         glass = [glass , [(ones(1,30)') * (-3.5); (ones(1,30)') * (-6.8); (ones(1,30)') * (-10.8);...
%                             (ones(1,30)') * (-10.8); (ones(1,30)') * (-6.8); (ones(1,31)') * (-3.5)]];
        for k = 1: num_paths
            for j = 1: size(paths,2)/2 - 1
                if(~((isnan(paths(k,2*j-1)) || isnan(paths(k,2*j)) || isnan(paths(k, 2*j+1)) || isnan(paths(k, 2*j+2)))))
                    edge = [paths(k,j), paths(k,j+1), paths(k,j+2), paths(k,j+3)];
                    point = intersectEdges(attenuators(1:4), edge);
                    if(~(isinf(point(1)) || isinf(point(2)) || isnan(point(1)) || isnan(point(2))))
                        disp('The point has intersected');
                        disp(k);
                        angle_intersection = atan2(edge(2) - edge(4), edge(1) - edge(3));
                        angle_intersection = normalizeAngle(angle_intersection,0);
                        angle_intersection = abs(pi/2 - abs(angle_intersection));
                        [r_s2, r_p2, t_s2, t_p2] = fresnel(angle_intersection , 1, permittivity);
                        [r_s1, r_p1, t_s1, t_p1] = fresnel(asin(sin(angle_intersection) * 1/permittivity), permittivity, 1);
                        
%                         t_s1 = abs(t_s1);
%                         t_s2 = abs(t_s2);
%                         t_p1 = abs(t_p1);
%                         t_p2 = abs(t_p2);
%                      

%                         disp('angle_intersection')
%                         disp(angle_intersection);
% 
                        disp('t_s1, t_s2, t_p2, t_p1');
                        disp(t_s2);
                        disp(r_s2);
                        disp(r_p2);
                        disp(t_p2);
                        
                        disp('r_s2, t_s2, t_p2, r_p2');
                        disp(t_s1);
                        disp(r_s1);
                        disp(t_p1);
                        disp(r_p1);
                        
%                         
                        attenuations(k) = (attenuations(k) - mag2db(abs(t_s1/(t_s1-r_s1))) - mag2db(abs(t_s2))...
                                                            + fspl(thickness, 0.005/sqrt(permittivity)) - fspl(thickness, 0.005));
                        break;
                                                        
%                         disp('Transmission coefficient loss');
%                         disp(mag2db(sqrt(t_s1^2 +t_p1^2)) + mag2db(1/sqrt(t_s2^2 +t_p2^2)));
%                         disp('Attenuation loss')
%                         disp(fspl(thickness, 0.005/permittivity) - fspl(thickness, 0.005));
%                                                        
%                         if(material == 'd')
%                             switch(thickness)
%                                 case(0.012)
%                                     attenuations(k) = attenuations(k) - dry_wall(1,2);
%                                 case(0.024)
%                                     attenuations(k) = attenuations(k) - dry_wall(2,2);
%                                 case(0.036)
%                                     attenuations(k) = attenuations(k) - dry_wall(3,2);
%                                 case(0.048)
%                                     attenuations(k) = attenuations(k) - dry_wall(4,2);
%                             end
%                         else if(material == 'g')
%                                 attenuations(k) = attenuations(k) - glass(angle_intersection,2);
%                             end
%                         end   
                     end
                 end
            end
             
%           attenuations = -attenuations;
            
         end
     end
end