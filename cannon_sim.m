%% Layer 0 + Layer 1: figure/axes + bare animation loop

function cannon_sim
    %% plotting window/canvas
    fig = figure;
    ax = axes('Parent', fig);
    axis(ax, [0 200 0 100]);
    hold(ax, 'on');
    
    %% creates ball
    ballPlot = plot(ax, 0, 0, 'o', 'MarkerSize', 14, 'MarkerFaceColor', "r");
    
    %% sliders
    vSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 200, 'Value', 40, 'Position', [50 40 150 20]);

    angleSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 90, 'Value', 45, 'Position', [250 40 150 20]);
    
    uicontrol('Style', 'pushbutton', 'String', 'Fire!', 'Position', [450 40 100 30], 'Callback', @(src,evt) fireCannon(ax, ballPlot, vSlider, angleSlider));
    
    %%fire cannon
    function fireCannon(ax, ballPlot, velSlider, angSlider)
        v0 = get(velSlider, 'Value');
        angle = get(angSlider, 'Value');
        g = 9.81;
        x = 0; 
        y = 0;
        vx = v0 .* cosd(angle);
        vy = v0 .* sind(angle);
        dt = 0.02;

        %% animation
        while y >= 0
            [x, y, vx, vy] = step_physics(x, y, vx, vy, dt, g)

            set(ballPlot, 'XData', x, 'YData', y);
            drawnow;

        end 

    end
    
    
    
    
    
    
end    
    

