function const = SimulationConst()
    const.dt = 0.1;
    const.tf = 5;

    const.M = 1;
    const.G = 9.8;
    const.L = 2;
    const.J = const.M*const.L^2;
    const.B = 0.0;

    const.q_0 = pi/2;
    const.q_dot_0 = 0;
end

