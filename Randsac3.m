function [best_m,best_b,Pout] = Randsac3( P )
    P_inv = P'
    N = size(P,1);
    dist_thresh = 1;
    iter = ceil(log(1-.999)/log(1-.5^3));
    inlier_count = [];
    m_values = [];
    b_values = [];
    best_inliers = [];
    bestline=0;
    bestind = [];
    bestparam1 = 0;
    bestparam2 = 0;
    inlierCount = [];
    for i=1:iter
        % get 2 random values
        index = randperm(N,2);
        randpinv = P_inv(:,index);
            linedist = randpinv(:,2)-randpinv(:,1);
            linenormalize = linedist/norm(linedist);
            linevec = [-linenormalize(2),linenormalize(1)];
            dist = linevec*(P_inv- repmat(randpinv(:,1),1,N));
            %check if distance between a feature point and the line is
            %within thresh
            inlierIndex = find(abs(dist)<= dist_thresh);
            coordindex = [];
            coordindex(:,1) = P_inv(1,inlierIndex);
            coordindex(:,2) = P_inv(2,inlierIndex);
            inlierCount = size(inlierIndex,2);
            % check if best inlier count
            if (inlierCount > bestline && randpinv(1,2)~= randpinv(1,1))
                bestind = coordindex;
                bestline = inlierCount;
                a = (randpinv(2,2) - randpinv(2,1))/(randpinv(1,2)-randpinv(1,1));
                b = randpinv(2,1) - a*randpinv(1,1);
                bestparam1 = a;
                bestparam2 = b;
            end
            x=1:640;
            y = bestparam1*x + bestparam2;
%             figure(1)
%             plot(P(:,1),P(:,2),'x',x,y);
    end
    x=1:640;
    y = bestparam1*x + bestparam2;
%     figure(2)
%     plot(P(:,1),P(:,2),'o',x,y);
    % get rice of fitted line so points arn't revisited
    for i=1:size(P)
        for k=1:size(bestind,1)
            if P(i,1) == bestind(k,1)
                if P(i,2) == bestind(k,2)
                    P(i,1) = nan;
                    P(i,2) = nan;
                end
            end
        end
    end
    P(isnan(P(:,1)),:)=[];
    best_m = bestparam1;
    best_b = bestparam2;
    Pout = P;
%     figure(3)
%     plot(P(:,1),P(:,2),'x',x,y);
end

