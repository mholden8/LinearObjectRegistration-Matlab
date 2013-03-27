% This function will perform spherical registration with unknown point
% correspondence by the iterative closest point algorithm. With an initial
% guess required. Assume no translation required.
% We want to find R such that P,L,A = R * RecordLogPoints

%Parameter P: A cell array of points
%Parameter L: A cell array of lines
%Parameter A: A cell array of planes
%Parameter P_RLP: A matrix of collected points corresponding to points
%Parameter L_RLP: A matrix of collected points corresponding to lines
%Parameter A_RLP: A matrix of collected points corresponding to planes
%Parameter init: An initial guess at the spherical registration

function [ R error ] = LinearObjectICP( P, L, A, P_RLP, L_RLP, A_RLP, init )

THRESHOLD = 1e-6;
error = zeros( 0, 1 );
R = init;

% Iterative until the error measure converges
while ( size(error,1) < 2 || abs( error(end) - error(end-1) ) > THRESHOLD )
    
    RecordLogPoints = cell( 0, 1 );
    GeometryPoints_Closest = cell( 0, 1 );
    % Find the closest model point to each transformed empirical point
    for i = 1:numel(P_RLP)
        for j = 1:size(P_RLP{i},1)
            RecordLogPoints = cat( 1, RecordLogPoints, { Point( P_RLP{i}(j,:)' ) } );
            GeometryPoints_Closest = cat( 1, GeometryPoints_Closest, { Point( P{i}.point ) } );
        end %for
    end %for
    for i = 1:numel(L_RLP)
        for j = 1:size(L_RLP{i},1)
            RecordLogPoints = cat( 1, RecordLogPoints, { Point( L_RLP{i}(j,:)' ) } );
            GeometryPoints_Closest = cat( 1, GeometryPoints_Closest, { Point( L{i}.ProjectPoint( R * L_RLP{i}(j,:)' ) ) } );
        end %for
    end %for
    for i = 1:numel(A_RLP)
        for j = 1:size(A_RLP{i},1)
            RecordLogPoints = cat( 1, RecordLogPoints, { Point( A_RLP{i}(j,:)' ) } );
            GeometryPoints_Closest = cat( 1, GeometryPoints_Closest, { Point( A{i}.ProjectPoint( R * A_RLP{i}(j,:)' ) ) } );
        end %for
    end %for
    
    % Calculate the registration    
    R = SphericalRegistration( GeometryPoints_Closest, RecordLogPoints );
    
    % Calculate the error
    currError = 0;
    for i = 1:numel(RecordLogPoints)
        currError = currError + sum ( ( GeometryPoints_Closest{i}.point - R * RecordLogPoints{i}.point ) .^ 2 );
    end %for
    error = cat( 1, error, currError );
    
end %for