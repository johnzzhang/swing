function const = SimulationConst()
    % RK4 parameters
    const.dt = 0.01;
    const.tf = 20;

    % pendulum parameters
    const.M = 1;
    const.G = 9.8;
    const.L = 2;
    const.J = const.M*const.L^2;
    const.B = 0.0;
    
    % height parameter
    const.L_dot_max = 100; % slew rate m/s
    const.L_min = 0.8*const.L; % max standing height
    
    % initial conditions
    const.phi_0 = pi/64;
    const.phi_dot_0 = 0;
    const.L_0 = const.L; % start squatting
    
    % neuron parameters
    const.w_0 = [0 0 0]; % weights
    const.eta = 0.1; % learning parameters
    const.phi_best = 0; % biggest swing amplitude
    
    % Q learning parameters
    const.alpha = 0.01;
    const.epsilon_0 = 1.0;
    const.gamma = 0.99;
    const.tau = 20;
    
    % state space bins
    const.phiBins = 6;
    const.phiDotBins = 6;
end

