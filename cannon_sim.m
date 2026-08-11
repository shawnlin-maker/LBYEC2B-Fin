function cannon_sim
    %% plotting canvas
    fig = figure;
    ax = axes('Parent', fig);
    set(ax, 'Color', [0.85 0.92 1]);
    set(fig, 'Color', [1 1 1])
    axis(ax, [0 200 0 100]);
    hold(ax, 'on');

    %% creates ball
    ballPlot = plot(ax, 0, 0, 'o', 'MarkerSize', 14, 'MarkerFaceColor', "r");

    %% create cannon and variables
    pivot = [3,4];
    cannonLen = 8;

    cannonPlot = plot(ax, [pivot(1) pivot(1) + cannonLen * cosd(45)], [pivot(2) pivot(2) + cannonLen * sind(45)], 'k', 'Color', [0.2 0.2 0.2], 'LineWidth', 8);
    rectangle(ax, 'Position', [pivot(1)-2 0 4 pivot(2)], 'Curvature', 0.3, 'FaceColor', [0.3 0.3 0.3]);

    %% velocity readout box during flight
    statsText = text(ax, 140, 95, sprintf('Vx: 0.00 m/s\nVy: 0.00 m/s'), 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.3], 'BackgroundColor', [1 1 1], 'EdgeColor', [0.2 0.2 0.2], 'Margin', 6);

    %% live slider readout box; speed/angle, updates as sliders move
    sliderText = text(ax, 5, 95, sprintf('Speed: 20.0 m/s\nAngle: 45.0 deg'), 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.3], 'BackgroundColor', [1 1 1], 'EdgeColor', [0.2 0.2 0.2], 'Margin', 6);

    %% path arrow
    frameCount = 0;

    %% material presets; Cd, mass, restitution (bounciness), and color
    steel.Cd = 0.1; steel.mass = 5; steel.restitution = 0.2; steel.color = [0.5 0.5 0.5];
    rubber.Cd = 0.4; rubber.mass = 0.5; rubber.restitution = 0.8; rubber.color = [0.8 0.1 0.1];
    wood.Cd = 0.3; wood.mass = 1.5; wood.restitution = 0.4; wood.color = [0.55 0.27 0.07];
    materials.Steel = steel;
    materials.Rubber = rubber;
    materials.Wood = wood;
    matNames = {'Steel', 'Rubber', 'Wood'}; %% order has to match matMenu's string order below

    %% sliders/menu
    vSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 40, 'Value', 20, 'Position', [50 40 150 20]);

    angleSlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 90, 'Value', 45, 'Position', [250 40 150 20]);

    %% slider labels
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Initial Velocity (m/s)', 'Position', [50 15 150 20], 'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', [1 1 1], 'ForegroundColor', [0.1 0.1 0.3]);

    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Launch Angle (degrees)', 'Position', [250 15 150 20], 'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', [1 1 1], 'ForegroundColor', [0.1 0.1 0.3]);
    
    set(vSlider, 'Callback', @(src,evt) sliderReadout(sliderText, vSlider, angleSlider));

    set(angleSlider, 'Callback', @(src,evt) angleChanged(angleSlider, cannonPlot, cannonLen, pivot, sliderText, vSlider, angleSlider));

    spaceMenu = uicontrol('Style', 'popupmenu', 'String', {'Vacuum', 'Earth (realistic)'}, 'Position', [600 70 100 20]);

    matMenu = uicontrol('Style', 'popupmenu', 'String', {'Steel', 'Rubber', 'Wood'}, 'Position', [600 40 100 20]);

    uicontrol('Style', 'pushbutton', 'String', 'Fire!', 'Position', [450 40 100 30], 'Callback', @(src,evt) fireCannon(ax, ballPlot, vSlider, angleSlider, spaceMenu, matMenu, materials, matNames, statsText));


    %% cannon barrel angle 
    function angleChanged(src, cannonPlot, cannonLen, pivot, sliderText, vSlider, angleSlider)
        angle = get(src, 'Value');
        set(cannonPlot, 'XData', [pivot(1) pivot(1) + cannonLen * cosd(angle)], 'YData', [pivot(2) pivot(2) + cannonLen * sind(angle)])
        sliderReadout(sliderText, vSlider, angleSlider)
    end

    %% updates the speed/angle box which slider gets touched
    function sliderReadout(sliderText, vSlider, angleSlider)
        v = get(vSlider, 'Value');
        a = get(angleSlider, 'Value');
        set(sliderText, 'String', sprintf('Speed: %0.1f m/s\nAngle: %0.1f deg', v, a));
    end

    %% live readout of Vx/Vy during flight
    function live_display(vx, vy, statsText)
        set(statsText, 'String', sprintf('Vx: %0.2f m/s\nVy: %0.2f m/s', vx, vy));
    end


    %% fire cannon
    function fireCannon(ax, ballPlot, velSlider, angSlider, spaceMenu, matMenu, materials, matNames, statsText)
        v0 = get(velSlider, 'Value');
        angle = get(angSlider, 'Value');
        g = 9.81;
        dt = 0.02;

        x = pivot(1) + cannonLen*cosd(angle);
        y = pivot(2) + cannonLen*sind(angle);
        vx = v0 .* cosd(angle);
        vy = v0 .* sind(angle);

        %% read dropdowns at fire time
        space = get(spaceMenu, 'Value');
        matChoice = get(matMenu, 'Value');
        chosenMat = materials.(matNames{matChoice});
        Cd = chosenMat.Cd;
        mass = chosenMat.mass;
        restitution = chosenMat.restitution;
        matColor = chosenMat.color;

        %% trail every shot
        tracerPlot = animatedline(ax, 'Color', matColor, 'LineWidth', 2);
        set(ballPlot, 'MarkerFaceColor', matColor);

        %% animation
        while true

            [x, y, vx, vy, bounced] = step_physics(x, y, vx, vy, dt, g, space, Cd, mass, restitution);

            set(ballPlot, 'XData', x, 'YData', y);

            addpoints(tracerPlot, x, y);

            frameCount = frameCount + 1;

            live_display(vx, vy, statsText)

            %% squash feedback on bounce frames
            if bounced
                set(ballPlot, 'MarkerSize', 7);
                drawnow;
                set(ballPlot, 'MarkerSize', 14);
            end

            if mod(frameCount, 50) == 0
                quiver(ax,x,y,vx*0.5,vy*0.5, 'Color', matColor, 'MaxHeadSize', 1);
            end

            drawnow;

            %% stop conditions; either flies off the right edge, or stops bouncing
            if x > 195
                break
            end
            if bounced && abs(vy) < 0.5
                break
            end

        end
    end
end