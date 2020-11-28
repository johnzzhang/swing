function const = SimulationConst()
    % RK4 parameters
    const.dt = 0.01;
    const.tf = 50;

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
    const.phi_0 = pi/32;
    const.phi_dot_0 = 0;
    const.L_0 = const.L; % start squatting
    
    % neuron parameters
    const.w_0 = [0 0 0]; % weights
    const.eta = 2; % learning parameters
    const.phi_best = 0; % biggest swing amplitude
end

