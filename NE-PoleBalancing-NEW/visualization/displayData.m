%% Display run data

if ~headless
    display(gen);
    if gen == p.startPlot
        initPlots;
        pause(0.5)
    end
    
    if gen > p.startPlot
        updatePlots;
    end
else
    if ~mod(gen,10)
        display([int2str(gen) ' generations completed.']);
    end
end