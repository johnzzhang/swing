function [tm,state] = Simulator( const )
    tspan = 0:const.dt:const.tf;
    initialConditions = [const.q_0; const.q_dot_0];
    [tm, state] = ode45(@pendulum, tspan, initialConditions);
    
    function  stateDeriv = pendulum(t, state)
       q = state(1);
       q_dot = state(2);
       
       B = const.B;
       M = const.J;
       G = const.G;
       L = const.L;
       J = const.J;
       
       stateDeriv = [q_dot; -B/J*q_dot*abs(q_dot) - M*G*L/J*sin(q);];
    end
end