tic
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loading data 
load('input\FuEn.dat','-mat')
load('input\FuEnwAI.dat','-mat')
load('input\elecon.dat','-mat')
load('input\sspPOP.dat','-mat')
load('input\AIADEneL.dat','-mat')
load('input\AIADEneM.dat','-mat')
load('input\AIADEneU.dat','-mat')
load('input\AIwADEneL.dat','-mat')
load('input\AIwADEneM.dat','-mat')
load('input\AIwADEneU.dat','-mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2 a, With or without impact AI on electricity demand
figure(1)
Fyr = (2020:2050);
xyr = (2021:2050);
idxyr1 = find(Fyr == xyr(1));
xyr2 = (2015:2023);
% Impact
fill([xyr fliplr(xyr)],[sum(FuEn(:,idxyr1:end,1),1),fliplr(sum(FuEn(:,idxyr1:end,3),1))],[1 0.8 1],...
    'EdgeColor','none','FaceAlpha', 0.5);hold on
plot(xyr,sum(FuEn(:,idxyr1:end,2),1),'LineStyle','-','Color','k','linewidth',1.5);hold on
% Without impacts
fill([xyr fliplr(xyr)],[sum(FuEnwAI(:,idxyr1:end,1),1),fliplr(sum(FuEnwAI(:,idxyr1:end,3),1))],[0 0.4470 0.7410],...
    'EdgeColor','none','FaceAlpha',0.5);hold on
plot(xyr,sum(FuEnwAI(:,idxyr1:end,2),1),'LineStyle','-','Color','b','linewidth',1.5);hold on
% Historical
scatter(xyr2,sum(elecon{:,23:31}./10,1),'k','fill');hold on
plot(xyr2,sum(elecon{:,23:31}./10,1),'LineStyle','-','Color','k','linewidth',1.5);hold on
xlim([2015 2050])
ylim([5000 25000])
xlabel('Year');
ylabel('Demand of eletricity in China (TWh/yr)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2 c, Per-capita additional electricity demand (kWh)
figure(2)
Cluster = readtable('input\IDC.xlsx','sheet','Cluster','PreserveVariableNames',true);
xyr = (1:365);
for c = 1:6
    subplot(2,3,c)
    idx = find(Cluster{:,4} == c);
    % Imapct 
    mdline = (sum(AIADEneM(idx,:),1) - sum(AIwADEneM(idx,:),1))/sum(sspPOP(idx,31,2)).*10^9;
    loline = (sum(AIADEneL(idx,:),1) - sum(AIwADEneL(idx,:),1))/sum(sspPOP(idx,31,2)).*10^9;
    upline = (sum(AIADEneU(idx,:),1) - sum(AIwADEneU(idx,:),1))/sum(sspPOP(idx,31,2)).*10^9;
    fill([xyr fliplr(xyr)],[loline,fliplr(upline)],[1 0.8 1],...
        'EdgeColor','none','FaceAlpha', 0.9);hold on
    plot(xyr,mdline,'LineStyle','-','Color','r','linewidth',1.0);hold on
    xlim([1 365])
    if c == 1
        ylim([0 20])
    elseif c == 2
        ylim([0 25])
    elseif c == 3
        ylim([0 20])
    elseif c == 4
        ylim([0 15])
    elseif c == 5
        ylim([0 15])
    elseif c == 6
        ylim([0 15])
    end
    xlabel('Day');
    ylabel('Additional eletricity demand (kWh/d)');
end





toc
