function const = SimulationConst()
    const.dt = 0.001;
    const.tf = 10;

    const.M = 1;
    const.G = 9.8;
    const.L = 2;
    const.J = const.M*const.L^2;
    const.B = 0.0;
    
    % height parameter
    const.L_dot_max = 5; % slew rate m/s
    const.L_min = 0.9*const.L; % max standing height
    
    % initial conditions
    const.q_0 = pi/8;
    const.q_dot_0 = 0;
    const.L_0 = const.L; % start squatting
end

