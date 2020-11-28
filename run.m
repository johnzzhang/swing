clear; clc; close all;

doplot = true;
doanim = true;

% load constants
simConst = SimulationConst();

% run simulator
[tm, state] = Simulator( simConst );

if doplot
    figure;

    subplot(2,1,1);
    yyaxis left;
    plot(tm, state(:,1), '.-');
    ylabel('q (rad)');

    yyaxis right;
    plot(tm, state(:,2), '.-');
    ylabel('qdot (rad/s)');
    
    subplot(2,1,2);
    plot(tm, state(:,3), '.-');
    ylabel('L (m)');
    
    xlabel('t (s)');
    improvePlot();
end

if doanim
    x_bob = @(t) interp1(tm,state(:,3),t)*sin(interp1(tm,state(:,1),t));
    y_bob = @(t) -interp1(tm,state(:,3),t)*cos(interp1(tm,state(:,1),t));
    
    x_pos = @(t) simConst.L*sin(interp1(tm,state(:,1),t));
    y_pos = @(t) -simConst.L*cos(interp1(tm,state(:,1),t));
    
    tspan = [0 simConst.tf];
    
    figure;
    fanimator(@(t) plot(x_bob(t),y_bob(t),'ko','MarkerFaceColor','k'),'AnimationRange',tspan);
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