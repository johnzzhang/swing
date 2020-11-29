function [tm,state] = Simulator( const )
    tspan = 0:const.dt:const.tf;
    initialConditions = [const.phi_0; const.phi_dot_0; const.L_0; const.w_0'; const.phi_best];
    %[tm, state] = ode45(@pendulum, tspan, initialConditions);
    
    tm = tspan';
    
    % use RK4
    state = zeros(length(tspan),length(initialConditions));
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
    
    function [potential, w_new] = neuron(x, w, desired)
        % adapt the weight using LMS 
        % uncomment below to override
        %w = 1*[0.2; -2.5; 0];
        v = w'*x;
        % needs hysteresis on action potential
        potential = tanh(v);
        
        error = desired - potential;
        w_new = w + const.eta*x*error;
    end

    function  stateDeriv = pendulum(t, state)
        phi = state(1);
        phi_dot = state(2);
        L = state(3);
        w = state(4:6);
        phi_best = state(7);
        
        G = const.G;
        B = const.B;
        L_dot_max = const.L_dot_max;

%         % how a human behaves
%         L_dot = 0;
%         epsilon = 0.01;
%         % controller for optimal swinging
%         % stand up if going through phi=0
%         if abs(phi) < epsilon
%            L_dot = -L_dot_max;
%         end
%         % squat if at apex phi_dot=0
%         if abs(phi_dot) < epsilon
%            L_dot = L_dot_max;
%         end

        % error is based on supervised learning from human model
        epsilon = 0.01;
        desired = 0;
        % stand up if going through phi=0
        if abs(phi) < epsilon
           desired = -1;
        end
        % squat if at apex phi_dot=0
        if abs(phi_dot) < epsilon
           desired = 1;
        end
        input = [1; phi; phi_dot];
        [potential, w_new] = neuron(input, w, desired);

        dw = (w_new-w)/const.dt;
        
        % set the extension of the leg to the neuron potential
        L_dot = L_dot_max*potential;

        % prevent the rider from exceeding the height bounds
        if L >= const.L && L_dot > 0
           L_dot = 0.0;
        elseif L <= const.L_min && L_dot < 0
           L_dot = 0.0;
        end
        
        % check if new amplitude is greater than previous best
        if abs(phi) > phi_best 
            dphi_best = (abs(phi)-phi_best)/const.dt;
        else
            dphi_best = 0;
        end
        
        momentumTerm = -2*L_dot/L*phi_dot;
        dampingTerm = -B*phi_dot; % viscous only
        gravityTerm =  - G/L*sin(phi);
        stateDeriv = [phi_dot; momentumTerm+dampingTerm+gravityTerm; L_dot; dw; dphi_best];
    end
end