
%% plotNet - Plots the topology and connection weights of an FFANN (individual as input)

function plotNet(ind)
hold off;
layMat = getLayers(ind);
numLayers = size(layMat,2);

height = 500;
width = 1000;

spacing = -10 + width/numLayers;

% Plot input layer
y1 = midLinspace(-height+50,height-50,sum(layMat(:,1)));

x1 = spacing*ones(1,length(y1));
plot(x1,y1,'o',...
    'LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[.49 1 .63],...
    'MarkerSize',15);
hold on;
location = [];
location = [location, [x1;y1]];
%% Plot nodes
for layer=2:numLayers
    
    y2 = midLinspace(-height,height,sum(layMat(:,layer))+2);
    y2 = y2(1:end-2);
    %     y2 = midLinspace(-height,height,sum(layMat(:,layer)));
    x2 = layer*spacing*ones(1,length(y2));
    
    location = [location, [x2;y2]];
    
    plot(x2,y2,'o',...
        'LineWidth',1,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63],...
        'MarkerSize',15)
    
    
    % Move on to next layer
    y1 = y2;
    x1 = x2;
end

%% Plot connections
[order, wMat] = getNodeOrder(ind);
for from=1:length(wMat)
    for to=1:length(wMat)
        weight = wMat(from,to)/2;
        if weight ~=0
            if weight > 0
                plot([location(1,from),location(1,to)],[location(2,from),location(2,to)],'b--.', 'LineWidth',weight)
            else
                plot([location(1,from),location(1,to)],[location(2,from),location(2,to)],'r--.', 'LineWidth',abs(weight))
            end
        end
    end
end

set(gca,'XTick',[])
set(gca,'YTick',[])

end