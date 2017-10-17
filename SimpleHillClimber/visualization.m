solutions=zeros(1,100);
ysolutions=zeros(1,100);
plotX=zeros(100,100);
plotY=zeros(100,100);
fit = @(x) (x>1).*(2.*x-2) + (x<=0.5).*8.*x + ((x>0.5).*(x<=1)).*(-8.*x + 8);
for i=1:100
    [solutions(i),plotX(i,:),plotY(i,:)] = fitClimber();
end

figure(1);
h1=histogram(solutions,40);
xlabel('X Werte');
ylabel('absolute Häufigkeit');

figure(2);
xSolutions=plotX(:,100)';
boxplot(solutions);
ax=gca;
ax.XTickLabel = {'100 HillClimb Ergebnisse','XWerte'};
ylabel('X Werte');

handles.figure = figure('Position',[100 100 500 420],'Units','Pixels');
handles.axes1 = axes('Units','Pixels','Position',[60,100,400,300]);
handles.Slider1 = uicontrol('Style','slider','Position',[60 20 400 50],'Min',1,'Max',100, 'Value', 1, 'SliderStep', [1/100 .1], 'Callback',{@SliderCallback, plotX, plotY, solutions fit});
SliderCallback(handles.Slider1,0, plotX, plotY, solutions, fit) %trigger callback to plot when opening

%// This is the slider callback, executed when you release the it or press the arrows at each extremity.
function SliderCallback(hObject,~, plotX, plotY, solutions, fit)
    sliderValue = round(hObject.Value);
    set(hObject, 'Value', sliderValue)
    figure(3);
    fplot(fit, [-0.5, 12],'c', 'lineWidth', 2)
    hold on
    plot(plotX(sliderValue,:), plotY(sliderValue,:),'--r', 'LineWidth',2)
    plot(solutions(sliderValue), fit(solutions(sliderValue)), 'bo', 'LineWidth',1)
    hold off
end