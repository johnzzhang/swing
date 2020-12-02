function [tm,state,score,energy_best_list, Qnew] = Simulator( const, Q )
    tspan = 0:const.dt:const.tf;
    initialConditions = [const.phi_0; const.phi_dot_0; const.L_0;];
    
    tm = tspan';
    
    % use RK4
    state = zeros(length(tspan),length(initialConditions));
    state(1,:) = initialConditions;
    
    % discretized state space
    discPhi = linspace(-pi,pi,const.phiBins+1);
    discPhiDot = linspace(-10,10,const.phiDotBins+1);
    
    % discretized action space
    actionSpace = [-1 0 1];
    
    % action
    action = 0;
    
    % initial discretized state space indices
    phi_index = NaN;
    phi_dot_index = NaN;
    
    % keeping score
    score = zeros(length(tspan),1);
    totalScore = 0;
    score(1) = totalScore;
    
    % keep track of highest angle
    phi_best = 0;
    phi_best_list = zeros(length(tspan),1);
    phi_best(1) = abs(const.phi_0);
    % highest energy
    energy_best = 0;
    energy_best_list = zeros(length(tspan),1);
    energy_best_list(1) = const.M*const.G*(1-cos(const.phi_0));
    
    for i = 1:length(tspan)-1
        currentState = state(i,:);
        newState = RK4_step(currentState',tspan(i));
        state(i+1,:) = newState';
        
        % calculate reward and score
        reward = 0;
        
        % highest angle
        if abs(newState(1)) > 1.01*phi_best
            phi_best = abs(newState(1));
            %reward = 1;
        end
        phi_best_list(i+1) = phi_best;
        
        % highest energy
        newEnergy = const.M*const.G*(1-cos(newState(1)))+0.5*const.M*(newState(3)*newState(2))^2;
        if newEnergy > energy_best
            energy_best = newEnergy;
            reward = 1;
        end
        energy_best_list(i+1) = energy_best;
        
        totalScore = totalScore + reward;
        score(i+1) = totalScore;
        
        [~,x] = histc(mod(currentState(1)+pi,2*pi)-pi,discPhi);
        [~,y] = histc(currentState(2),discPhiDot);
        [Qmax, ~] = maxAction(Q, newState);
        % update action-value function Q
        if action == -1
            Q.stand(x,y) = Q.stand(x,y) + const.alpha*(reward + const.gamma*Qmax - Q.stand(x,y));
        elseif action == 0
            Q.stay(x,y) = Q.stay(x,y) + const.alpha*(reward + const.gamma*Qmax - Q.stay(x,y));
        elseif action == 1
            Q.squat(x,y) = Q.squat(x,y) + const.alpha*(reward + const.gamma*Qmax - Q.squat(x,y));
        end
    end
    
    Qnew = Q;
    
    function [value, action_idx] = maxAction(Q, state)
        [~,phi_idx] = histc(mod(state(1)+pi,2*pi)-pi,discPhi);
        [~,phi_dot_idx] = histc(state(2),discPhiDot);
        
        % calculates the action that maximizes Q for the given state        
        [value, action_idx] = max([Q.stand(phi_idx,phi_dot_idx) ...
                                    Q.stay(phi_idx,phi_dot_idx) ...
                                    Q.squat(phi_idx,phi_dot_idx)]);
    end
    
    function newState = RK4_step(state, t)
        dt = const.dt;
        k1 = pendulum(t, state);
        k2 = pendulum(t+0.5*dt, state+0.5*k1*dt);
        k3 = pendulum(t+0.5*dt, state+0.5*k2*dt);
        k4 = pendulum(t+dt, state+k3*dt);

        
        [~,phi_index] = histc(state(1),discPhi);
        [~,phi_dot_index] = histc(state(2),discPhiDot);
        
        RK4Slope = (k1+2*k2+2*k3+k4)/6;
        newState = state + dt*RK4Slope;
        % limit the length
        L = newState(3);
        newState(3) = min(const.L, max(const.L_min, L));
    end
    
    function [potential, w_new] = neuron(x, w, desired)
         
        v = w'*x;
        potential = tanh(v);
        
        % adapt the weight using LMS
        error = desired - potential;
        w_new = w + const.eta*x*error;
    end

    function  stateDeriv = pendulum(t, state)
        phi = state(1);
        phi_dot = state(2);
        L = state(3);
        
        G = const.G;
        B = const.B;
        L_dot_max = const.L_dot_max;

        action = 0;
        % choose action based on epsilon-greedy approach
        if rand() < const.epsilon_0*exp(-t/const.tau);
            % explore
            action = randsample(actionSpace,1);
        else
            % exploit
            [~, action_index] = maxAction(Q, state);
            action = actionSpace(action_index);
        end

        % set the extension of the leg to the neuron potential
        L_dot = L_dot_max*action;

        % prevent the rider from exceeding the height bounds
        if L >= const.L && L_dot > 0
           L_dot = 0.0;
        elseif L <= const.L_min && L_dot < 0
           L_dot = 0.0;
        end
        
        momentumTerm = -2*L_dot/L*phi_dot; % john debug: sometimes causes artificial damping
        dampingTerm = -B*phi_dot; % viscous only
        gravityTerm =  -G/L*sin(phi);
        stateDeriv = [phi_dot; momentumTerm+dampingTerm+gravityTerm; L_dot];
    end
end