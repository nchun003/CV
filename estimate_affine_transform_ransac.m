function A_est = estimate_affine_transform(Im1_feature_coordinates,Im2_feature_coordinates)
% the inputs are two Nx2 matrices, with the coordinates of the matching
% features in image one and two.

% number of points we have
N = size(Im1_feature_coordinates,1);
% number of iterations we need
iter = ceil(log(1-.999)/log(1-.5^3))
% threshold for inliers
threshold = 2;

% the number of inliers of the best solution (initialization)
bestcount=0;

for it = 1:iter
    
    % sample randomly
    %% We need three points correspondence to estimate affine transform.
    % Reason: Affine matrix has 6 degrees of freedom, each point
    % correspondence gives two constraints, thus at least 3 points are
    % needed to work out the affine transform (if you are using homograpy, 
    % then at least 4 points are required)
    ri = randperm(N,3); % get random indices in [1:N]
    
    I1_feat = Im1_feature_coordinates(ri,:);
    I2_feat = Im2_feature_coordinates(ri,:);
    
     A_est = estimate_affine_transform(I1_feat,I2_feat);
%     A_est = estimate_homography(I1_feat,I2_feat);
    
    %% check how many matches agree with this:
    % transform all points from Image 1 with the estimated transform
    predicted_coord = A_est*[Im1_feature_coordinates';ones(1,N)];
    % divide by the 3rd coordinate (needed for a homography, has no effect
    % for an affine transform)
    predicted_coord = [predicted_coord(1,:)./predicted_coord(3,:);
                        predicted_coord(2,:)./predicted_coord(3,:)];
    
    % count how many points are within "threshold" of their predicted
    % positions in Image 2
    count = 0;
    for i = 1:N
        if norm(predicted_coord(1:2,i) - Im2_feature_coordinates(i,:)')< threshold
            count = count+1;
        end
    end
    
    % keep this solution as the best, if it has more points agreeing to it
    if bestcount<count
        bestcount=count
        best_A = A_est;
    end
    
end

%% find the matches that agree with the best transform:
% transform all points from Image 1 with the best estimated transform
predicted_coord = best_A *[Im1_feature_coordinates';ones(1,N)];
% divide by the 3rd coordinate (needed for a homography, has no effect
% for an affine transform)
predicted_coord = [predicted_coord(1,:)./predicted_coord(3,:);
                   predicted_coord(2,:)./predicted_coord(3,:)];
    
ind = zeros(1,N);
for i = 1:N
    if norm(predicted_coord(1:2,i) - Im2_feature_coordinates(i,:)')< threshold
        ind(i)=1;
    end
end

% use all the points that agree with this solution to get a final estimate
A_est = estimate_affine_transform(Im1_feature_coordinates(ind==1,:),Im2_feature_coordinates(ind==1,:));
% A_est = estimate_homography(Im1_feature_coordinates(ind==1,:),Im2_feature_coordinates(ind==1,:));


