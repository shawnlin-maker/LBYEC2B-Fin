%% Layer 0 + Layer 1: figure/axes + bare animation loop
function cannon_sim
    %% plotting window/canvas
    fig = figure;
    ax = axes('Parent', fig);
    axis(ax, [0 200 0 100]);
    hold(ax, 'on');

    %% creates ball
    ballPlot = plot(ax, 0, 0, 'o', 'MarkerSize', 14, 'MarkerFaceColor', "r");

    %% create cannon and variables
    pivot = [3,4];
    cannonLen = 8;

    cannonPlot = plot(ax, [pivot(1) pivot(1) + cannonLen * cosd(45)], [pivot(2) pivot(2) + cannonLen * sind(45)], 'k', 'linewidth', 4)

    %% sliders/menu
    vSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 200, 'Value', 40, 'Position', [50 40 150 20]);

    angleSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 90, 'Value', 45, 'Position', [250 40 150 20], 'Callback', @(src,evt) cannonAngle(src, cannonPlot, cannonLen, pivot));

    uicontrol('Style', 'pushbutton', 'String', 'Fire!', 'Position', [450 40 100 30], 'Callback', @(src,evt) fireCannon(ax, ballPlot, vSlider, angleSlider));

    matMenu = uicontrol('Style', 'popupmenu', 'String', {'Steel', 'Rubber', 'Wood'}, 'Position', [600 40 100 20]);


    %% cannon barrel angle
    function cannonAngle(src, cannonPlot, cannonLen, pivot)
            angle = get(src, 'Value');
            set(cannonPlot, 'XData', [pivot(1) pivot(1) + cannonLen * cosd(angle)], 'YData', [pivot(2) pivot(2) + cannonLen * sind(angle)])
    end

        %% fire cannon
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