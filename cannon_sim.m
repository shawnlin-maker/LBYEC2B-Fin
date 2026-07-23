%% Layer 0 + Layer 1: figure/axes + bare animation loop

%% plotting window/canvas
fig = figure;
ax = axes('Parent', fig);
axis(ax, [0 200 0 100]);
hold(ax, 'on');

%% creates ball
ballPlot = plot(ax, 0, 0, 'o', 'MarkerSize', 14, 'MarkerFaceColor', "r");

%% physics setup
v0 = 40;
angle = 45;
g = 9.81;
x = 0;
y = 0;

vx = v0 .* cosd(angle);     
vy = v0 .* sind(angle);
dt = 0.01;


%% animation
while y >= 0
    vy = vy - g*dt;
    x = x + vx*dt;  %% euler approximation, not real kinematics equation
    y = y + vy*dt;  %% euler approximation, not real kinematics equation

    set(ballPlot, 'XData', x, 'YData', y);
    drawnow;

end 
    