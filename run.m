clear; clc; close all;

doplot = true;
doanim = false;

% load constants
simConst = SimulationConst();

% action-value function
Q.stand = rand(simConst.phiBins,simConst.phiDotBins);
Q.stay  = rand(simConst.phiBins,simConst.phiDotBins);
Q.squat = rand(simConst.phiBins,simConst.phiDotBins);

% run with optimal policy
%load('run6/policies.mat');
%Q = Q_best;
Q.stand = [1 0; 0 1];
Q.stay = [0 0; 0 0];
Q.squat = [0 1; 1 0];

% run simulator for several trials
numTrials = 1;
score_list = zeros(length(numTrials),1);
highscore = 0;

for trial = 1:numTrials
    if mod(trial,100) == 0
        trial, simConst.epsilon_0
    end
    
    if simConst.epsilon_0 > 0.01
        simConst.epsilon_0 = simConst.epsilon_0 - 1/numTrials;
    else
        simConst.epsilon_0 = 0.01;
    end
        
    [tm, state_new, score_new, phi_best_list_new, Q_new] = Simulator( simConst, Q );
    
    Q = Q_new;
    finalScore = score_new(end);
    score_list(trial) = finalScore;
    
    if finalScore >= highscore
        highscore = finalScore;
        state = state_new;
        score = score_new;
        phi_best_list = phi_best_list_new;
        Q_best = Q_new;
    end
end

figure;
plot(1:numTrials,score_list);
xlabel('episodes');
ylabel('score');
improvePlot();

% plot the policy
Qmax = zeros(simConst.phiBins,simConst.phiDotBins);
for i = 1:simConst.phiBins
    for j = 1:simConst.phiDotBins
        actionColor = [-1 0 1];
        [~,idx] = max([Q_best.stand(i,j) Q_best.stay(i,j) Q_best.squat(i,j)]);
        Qmax(i,j) = actionColor(idx);
    end
end
discPhi = linspace(-pi,pi,simConst.phiBins);
discPhiDot = linspace(-15,15,simConst.phiDotBins);
[phi,phi_dot]=meshgrid(discPhi, discPhiDot);
figure;
imagesc(discPhi,discPhiDot,Qmax)
xlabel('$\phi$ [rad]','interpreter','latex');
ylabel('$\dot{\phi}$ [rad/s]','interpreter','latex');
grid on;
view(2);
colormap(jet(3));
mycb = colorbar();
set(mycb, 'YTick', [-1 0 1], 'YTickLabel', {'stand', 'stay', 'squat'});
xlim([-pi pi]);
ylim([-15, 15]);
improvePlot();

if doplot    
    % phase plane
%     figure;
%     plot(state(:,1),state(:,2));
%     xlabel('$\phi$ [rad]','interpreter','latex');
%     ylabel('$\dot{\phi}$ [rad/s]','interpreter','latex');
%     improvePlot();
    
    % generalized coordinates
    figure;

    subplot(4,1,1);
    yyaxis left;
    plot(tm, state(:,1), '.-');
    ylabel('$\phi$ [rad]','interpreter','latex');

    yyaxis right;
    plot(tm, state(:,2), '.-');
    ylabel('$\dot{\phi}$ [rad/s]','interpreter','latex');
    
    subplot(4,1,2);
    plot(tm, state(:,3), '.-');
    ylabel('$L$ [m]','interpreter','latex');
    
    subplot(4,1,3);
    plot(tm, score, '.-');
    ylabel('score','interpreter','latex');
    
    subplot(4,1,4);
    plot(tm, phi_best_list, '.-');
    ylabel('$\phi$ best','interpreter','latex');
    
    xlabel('$t$ [s]','interpreter','latex');
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
    
    % write animation to video or gif
    vidObj = VideoWriter('pendulum','MPEG-4');
    open(vidObj)
    writeAnimation(vidObj, 'FrameRate',30)
    %writeAnimation('pendulum.gif', 'FrameRate',15,'LoopCount',1)
    close(vidObj)
end