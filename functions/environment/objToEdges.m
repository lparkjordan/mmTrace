function [ edges ] = objToEdges( object )
%OBJTOEDGES Transform object to edge representation
%
% 	Project: 		mmTrace
% 	Author: 		Daniel Steinmetzer
% 	Affiliation:	SEEMOO, TU Darmstadt
% 	Date: 			January 2016

	if isempty(object)
		edges = [];
	else

		c0 = object(:,1:2);
		
		v = object(:,3:4)./2;
		al = object(:,5);
		
		c1 = [  cos(al) .* v(:,1) * 1		- sin(al) .* v(:,2) * 1, ...
			sin(al) .* v(:,1) * 1		+ cos(al) .* v(:,2) * 1];
		c2 = [  cos(al) .* v(:,1) * 1		- sin(al) .* v(:,2) * (-1), ...
			sin(al) .* v(:,1) * 1		+ cos(al) .* v(:,2) * (-1)];
		c3 = [  cos(al) .* v(:,1) * (-1)	- sin(al) .* v(:,2) * (-1), ...
			sin(al) .* v(:,1) * (-1)	+ cos(al) .* v(:,2) * (-1)];
		c4 = [  cos(al) .* v(:,1) * (-1)	- sin(al) .* v(:,2) * 1, ...
			sin(al) .* v(:,1) * (-1)	+ cos(al) .* v(:,2) * 1];
        
		edges = zeros(size(object,1)*4, 4);
        edges(1:4:end) = [c0+c1, c0+c2];
        edges(2:4:end) = [c0+c2, c0+c3];
        edges(3:4:end) = [c0+c3, c0+c4];
        edges(4:4:end) = [c0+c4, c0+c1];
	end

end

