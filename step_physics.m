

function [x, y, vx, vy] = step_physics(x, y, vx, vy, dt, g)
vy = vy - g*dt;
x = x + vx*dt; %% euler approximation, not real kinematics equation
y = y + vy*dt; %% euler approximation, not real kinematics equation
end