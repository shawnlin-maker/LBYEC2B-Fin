

function [x, y, vx, vy, bounced] = step_physics(x, y, vx, vy, dt, g, space, Cd, mass, restitution)
    speed = sqrt(vx^2 + vy^2);

    if space == 1
        %% vacuum no drag
        ax = 0;
        ay = -g;
    
    elseif space == 2
        %% realistic with drag
        rho = 1.225;
        A = 0.05;

        decel = 0.5*rho * Cd * A * speed / mass;

        ax = -decel * vx;
        ay = -decel * vy -g;

    end


    vx = vx + ax*dt
    vy = vy + ay*dt;
    x = x + vx*dt; %% euler approximation, not real kinematics equation
    y = y + vy*dt; %% euler approximation, not real kinematics equation

    %% ground bounce -- flip and shrink vertical velocity based on material bounciness
    if y <= 0
        y = 0;
        vy = -vy * restitution;
        bounced = true;
    end
end