clear; clc; close all;

doplot = true;
doanim = true;

% load constants
simConst = SimulationConst();

% run simulator
[tm, state] = Simulator( simConst );

if doplot
    figure;

    yyaxis left;
    plot(tm, state(:,1), '.-');
    ylabel('q (rad)');

    yyaxis right;
    plot(tm, state(:,2), '.-');
    ylabel('qdot (rad/s)');
    
    xlabel('t (s)');
    improvePlot();
end

if doanim
    x_pos = @(t) sin(interp1(tm,state(:,1),t));
    y_pos = @(t) -cos(interp1(tm,state(:,1),t));
    
    tspan = [0 simConst.tf];
    
    figure;
    fanimator(@(t) plot(x_pos(t),y_pos(t),'ko','MarkerFaceColor','k'),'AnimationRange',tspan);
    hold on;
    fanimator(@(t) plot([0 x_pos(t)],[0 y_pos(t)],'k-'),'AnimationRange',tspan);
    fanimator(@(t) text(-0.3,1.5,"Timer: "+num2str(t,2)+" s", 'FontSize', 18),'AnimationRange',tspan);
    hold off;
    
    axis equal;
    plotScale = 1.2;
    xlim([-plotScale*simConst.L plotScale*simConst.L]);
    ylim([-plotScale*simConst.L plotScale*simConst.L]);
    
    improvePlot();
    
    playAnimation
end