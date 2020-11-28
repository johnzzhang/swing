clear; clc; close all;

doplot = true;
doanim = true;

% load constants
simConst = SimulationConst();

% run simulator
[tm, state] = Simulator( simConst );

if doplot
    % generalized coordinates
    figure;

    subplot(2,1,1);
    yyaxis left;
    plot(tm, state(:,1), '.-');
    ylabel('$\phi$ [rad]','interpreter','latex');

    yyaxis right;
    plot(tm, state(:,2), '.-');
    ylabel('$\dot{\phi}$ [rad/s]','interpreter','latex');
    
    subplot(2,1,2);
    plot(tm, state(:,3), '.-');
    ylabel('$L$ [m]','interpreter','latex');
    
    xlabel('$t$ [s]','interpreter','latex');
    improvePlot();
    
    % phase plane
    figure;
    plot(state(:,1),state(:,2));
    xlabel('$\phi$ [rad]','interpreter','latex');
    ylabel('$\dot{\phi}$ [rad/s]','interpreter','latex');
    improvePlot();
end

if doanim
    x_bob = @(t) interp1(tm,state(:,3),t)*sin(interp1(tm,state(:,1),t));
    y_bob = @(t) -interp1(tm,state(:,3),t)*cos(interp1(tm,state(:,1),t));
    
    x_pos = @(t) simConst.L*sin(interp1(tm,state(:,1),t));
    y_pos = @(t) -simConst.L*cos(interp1(tm,state(:,1),t));
    
    phi = @(t) interp1(tm,state(:,1),t);
    phi_dot = @(t) interp1(tm,state(:,2),t);
    
    tspan = [0 simConst.tf];
    
    figure;
    ax1 = subplot(1,2,1);
    
    fanimator(ax1, @(t) plot(x_bob(t),y_bob(t),'ko','MarkerFaceColor','k'),'AnimationRange',tspan);
    hold on;
    fanimator(ax1, @(t) plot([0 x_pos(t)],[0 y_pos(t)],'k-'),'AnimationRange',tspan);
    fanimator(ax1, @(t) text(-0.3,1.5,"Timer: "+num2str(t,2)+" s", 'FontSize', 18),'AnimationRange',tspan);
    hold off;
    
    axis equal;
    plotScale = 1.2;
    xlim([-plotScale*simConst.L plotScale*simConst.L]);
    ylim([-plotScale*simConst.L plotScale*simConst.L]);
    
    ax2 = subplot(1,2,2);
    hold on;
    fanimator(ax2,@(t) plot(phi(t),phi_dot(t),'r*'),'AnimationRange',tspan);
    fanimator(ax2,@fplot,phi,phi_dot,tspan,'b-');
    xlabel('$\phi$ [rad]','interpreter','latex');
    ylabel('$\dot{\phi}$ [rad/s]','interpreter','latex');
    improvePlot();
    
    
    %playAnimation
    
    % write animation
    %vidObj = VideoWriter('pendulum','MPEG-4');
    %open(vidObj)
    %writeAnimation(vidObj, 'FrameRate',30)
    writeAnimation('pendulum.gif', 'FrameRate',30,'LoopCount',1)
    %close(vidObj)
end