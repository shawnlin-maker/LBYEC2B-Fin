%% Layer 0 + Layer 1: figure/axes + bare animation loop
function cannon_sim
    %% plotting window/canvas
    fig = figure;
    ax = axes('Parent', fig);
    set(ax, 'Color', [0.85 0.92 1]);
    set(fig, 'Color', [1 1 1])
    axis(ax, [0 200 0 100]);
    hold(ax, 'on');

    %% creates ball
    ballPlot = plot(ax, 0, 0, 'o', 'MarkerSize', 14, 'MarkerFaceColor', "r");

    %% create tracers
    tracerPlot = animatedline(ax, 'color', 'r', 'linewidth', 2);

    %% create cannon and variables
    pivot = [3,4];
    cannonLen = 8;

    cannonPlot = plot(ax, [pivot(1) pivot(1) + cannonLen * cosd(45)], [pivot(2) pivot(2) + cannonLen * sind(45)], 'k', 'Color', [0.2 0.2 0.2], 'LineWidth', 8);
    rectangle(ax, 'Position', [pivot(1)-2 0 4 pivot(2)], 'Curvature', 0.3, 'FaceColor', [0.3 0.3 0.3]);

    %% velocity values
    vxText = text(ax, [150], [95], "Vx: 0m/s");
    vyText = text(ax, [150], [90], "Vy: 0m/s");

    %% path arrow
    frameCount = 0;

     %% material presets -- Cd, mass, restitution (bounciness, 0=no bounce, 1=full bounce)
    materials = struct( ...
        'Steel', struct('Cd', 0.1, 'mass', 5,   'restitution', 0.2), ...
        'Rubber',struct('Cd', 0.4, 'mass', 0.5, 'restitution', 0.8), ...
        'Wood',  struct('Cd', 0.3, 'mass', 1.5, 'restitution', 0.4));
    matNames = {'Steel', 'Rubber', 'Wood'}; %% order has to match matMenu's String order below

    %% sliders/menu
    vSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 60, 'Value', 30, 'Position', [50 40 150 20]);

    angleSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 90, 'Value', 45, 'Position', [250 40 150 20], 'Callback', @(src,evt) cannonAngle(src, cannonPlot, cannonLen, pivot));

    spaceMenu = uicontrol('Style', 'popupmenu', 'String', {'Vacuum', 'Earth (realistic)'}, 'Position', [600 70 100 20]);

    uicontrol('Style', 'pushbutton', 'String', 'Fire!', 'Position', [450 40 100 30], 'Callback', @(src,evt) fireCannon(ax, ballPlot, vSlider, angleSlider, spaceMenu, matMenu, materials, matNames));

    matMenu = uicontrol('Style', 'popupmenu', 'String', {'Steel', 'Rubber', 'Wood'}, 'Position', [600 40 100 20]);

    


    %% cannon barrel angle
    function cannonAngle(src, cannonPlot, cannonLen, pivot)
            angle = get(src, 'Value');
            set(cannonPlot, 'XData', [pivot(1) pivot(1) + cannonLen * cosd(angle)], 'YData', [pivot(2) pivot(2) + cannonLen * sind(angle)])
    end


    %% live readout of values
    function live_display(vx, vy, vxText, vyText)
        set(vxText, 'String', sprintf('Vx: %0.2f m/s', vx)); %% top right corner
        set(vyText, 'String', sprintf('Vy: %0.2f m/s', vy)); %%top right corner

    end



        %% fire cannon
    function fireCannon(ax, ballPlot, velSlider, angSlider, spaceMenu, matMenu, materials, matNames)
            v0 = get(velSlider, 'Value');
            angle = get(angSlider, 'Value');
            g = 9.81;
            dt = 0.02;

            %% ball spawns at the barrel tip, not (0,0) -- same math as the barrel line
            x = pivot(1) + cannonLen*cosd(angle);
            y = pivot(2) + cannonLen*sind(angle);
            vx = v0 .* cosd(angle);
            vy = v0 .* sind(angle);

            %% read the dropdowns AT FIRE TIME, not before
            space = get(spaceMenu, 'Value');
            matChoice = get(matMenu, 'Value');
            chosenMat = materials.(matNames{matChoice});
            Cd = chosenMat.Cd;
            mass = chosenMat.mass;
            restitution = chosenMat.restitution;

            %% animation
            while true
                
                
                [x, y, vx, vy, bounced] = step_physics(x, y, vx, vy, dt, g, space, Cd, mass)

                set(ballPlot, 'XData', x, 'YData', y);
                
                addpoints(tracerPlot, x, y);

                frameCount = frameCount + 1 

                live_display(vx,vy, vxText, vyText)

                %% squash-lite feedback on bounce frames
                if bounced
                    set(ballPlot, 'MarkerSize', 7);
                    drawnow;
                    set(ballPlot, 'MarkerSize', 14);
                end

                if mod(frameCount, 50) == 0
                    quiver(ax,x,y,vx*0.5,vy*0.5, 'color',[0 0.4 1],'MaxHeadSize', 1);

                end
                    

                drawnow;

                %% stop conditions -- either flies off the right edge, or basically stopped bouncing
                if x > 195
                    break
                end
                if bounced && abs(vy) < 0.5
                    break
                end

                

            end
    end
end