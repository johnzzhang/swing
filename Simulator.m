function [tm,state] = Simulator( const )
    tspan = 0:const.dt:const.tf;
    initialConditions = [const.q_0; const.q_dot_0; const.L_0];
    %[tm, state] = ode45(@pendulum, tspan, initialConditions);
    
    tm = tspan';
    
    % use RK4
    state = zeros(length(tspan),3);
    state(1,:) = initialConditions;
    for i = 1:length(tspan)-1
        currentState = state(i,:);
        newState = RK4_step(currentState',tspan(i));
        state(i+1,:) = newState';
    end
    
    function newState = RK4_step(state, t)
        dt = const.dt;
        k1 = pendulum(t, state);
        k2 = pendulum(t+0.5*dt, state+0.5*k1*dt);
        k3 = pendulum(t+0.5*dt, state+0.5*k2*dt);
        k4 = pendulum(t+dt, state+k3*dt);

        RK4Slope = (k1+2*k2+2*k3+k4)/6;
        newState = state + dt*RK4Slope;
        % limit the length
        L = newState(3);
        newState(3) = min(const.L, max(const.L_min, L));
    end
    
    function  stateDeriv = pendulum(t, state)
        phi = state(1);
        phi_dot = state(2);
        L = state(3);

        G = const.G;
        L_dot_max = const.L_dot_max;

        L_dot = 0;

        epsilon = 0.01;
        % controller for optimal swinging
        % stand up if going through phi=0
%         if abs(phi) < epsilon
%            L_dot = -L_dot_max;
%         end
%         % squat if at apex phi_dot=0
%         if abs(phi_dot) < epsilon
%            L_dot = L_dot_max;
%         end

%         % prevent the rider from exceeding the height bounds
%         if L >= const.L && L_dot > 0
%            L_dot = 0.0;
%         elseif L <= const.L_min && L_dot < 0
%            L_dot = 0.0;
%         end

        stateDeriv = [phi_dot; -2*L_dot/L*phi_dot - G/L*sin(phi); L_dot];
    end
end