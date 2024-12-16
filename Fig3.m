tic
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loading data
load('input\FuEn.dat','-mat')
load('input\FuEnwAI.dat','-mat')
load('input\elecon.dat','-mat')
load('input\subTotalEne.dat','-mat')
load('input\MixEne.dat','-mat')
load('input\PerMixEne.dat','-mat')
load('input\DayEneRt.dat','-mat')
load('input\DayPro.dat','-mat')
load('input\SolarGenProRt.dat','-mat')
load('input\WindGenProRt.dat','-mat')
load('input\AIADEneL.dat','-mat')
load('input\AIADEneM.dat','-mat')
load('input\AIADEneU.dat','-mat')
load('input\sspPOP.dat','-mat')
EleIE2021 = readtable('input\EleTrans21.csv','PreserveVariableNames',true);
Cluster = readtable('input\IDC.xlsx','sheet','Cluster','PreserveVariableNames',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3a
figure(1)
years = 2020:2050;
area(years, MixEne(:,1:size(years,2))');
legend('Fossil (Coal, Gas, Oil)', 'Solar', 'Wind', 'Hydropower', 'Nuclear', 'Other');
xlabel('Year');
ylabel('The electricity generation (PWh/yr)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3c , Changes in China's electricity demand
figure(2)
Yinfplot = (2020:2050);
%subplot(1,2,2)
% Electricity demand
FuEn = FuEn./10^3; FuEnwAI = FuEnwAI./10^3;
Fyr = (2020:2100);
xyr = (2023:2050);
xyr2 = (2020:2023);
idxst = find(Fyr == xyr(1));
idxed = find(Fyr == xyr(end));
timesp = (idxst:idxed);
FaceAlpha = 0.2;
MedianEne = median(subTotalEne(:,4:size(Yinfplot,2)+3),1);
% Impact (2023-2050)
lowAI = MedianEne(1,4:end) - sum(FuEn(:,idxst:idxed,1),1);
upAI = MedianEne(1,4:end) - sum(FuEn(:,idxst:idxed,3),1);
mdAI = MedianEne(1,4:end) - sum(FuEn(:,idxst:idxed,2),1);
fill([xyr fliplr(xyr)],[lowAI,fliplr(upAI)],[1 0.8 1],'EdgeColor','none','FaceAlpha', FaceAlpha);hold on
plot(xyr,mdAI,'LineStyle','-','Color','r','linewidth',1.5);hold on
% Without impacts (2023-2050)
lowwAI = MedianEne(1,4:end) - sum(FuEnwAI(:,idxst:idxed,1),1);
upwAI = MedianEne(1,4:end) - sum(FuEnwAI(:,idxst:idxed,3),1);
mdwAI = MedianEne(1,4:end) - sum(FuEnwAI(:,idxst:idxed,2),1);
fill([xyr fliplr(xyr)],[lowwAI,fliplr(upwAI)],[0 0.4470 0.7410],'EdgeColor','none','FaceAlpha',FaceAlpha);hold on
plot(xyr,mdwAI,'LineStyle','-','Color','b','linewidth',1.5);hold on
% Historical (2020-2023)
hisene = MedianEne(1,1:4) - sum(elecon{:,28:end}./10^4,1);
scatter(xyr2,hisene,30,'k','fill');hold on
plot(xyr2,hisene,'LineStyle','-','Color','k','linewidth',1.5);hold on
plot(Yinfplot,zeros(1,size(Yinfplot,2)),'LineStyle','--','Color','k','linewidth',1.5);hold on
xlabel('Year');
ylabel('The electricity demand and supply gap (PWh/yr)');
ylim([-6 2])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3d, Per capita electricity demand and supply gap
figure(3)
%% With considering eletricity transmission
% Fossil (Coal, Gas, Oil), Solar, Wind, Hydroelectricity, Nuclear, Other sources
% 2050
yrinf = 31;
DayEneSp = zeros(31,365,6);
Biefig = zeros(31,6);
for s = 1:6
    for p = 1:31
        if s == 1
            DayEneSp(p,:,s) = DayPro(p,:).*(PerMixEne(p,yrinf,s)*MixEne(s,yrinf)).*10^3; % PWh to TWh
        elseif s == 2
            DayEneSp(p,:,s) = smooth(SolarGenProRt(p,:),7).*(PerMixEne(p,yrinf,s)*MixEne(s,yrinf)).*10^3; % PWh to TWh
        elseif s == 3
            DayEneSp(p,:,s) = smooth(WindGenProRt(p,:),7).*(PerMixEne(p,yrinf,s)*MixEne(s,yrinf)).*10^3; % PWh to TWh
        else
            DayEneSp(p,:,s) = DayEneRt(s,:).*(PerMixEne(p,yrinf,s)*MixEne(s,yrinf)).*10^3; % PWh to TWh
        end
    end
    Biefig(:,s) = sum(DayEneSp(:,:,s),2);
end
TDayEneSp = sum(DayEneSp,3).*sum(MixEne(:,31),'all')./(sum(sum(DayEneSp,3),'all')/10^3);
% Eletricity transmission
DayEneTn = TDayEneSp;
for op = 1:31
    subdata = EleIE2021{EleIE2021{:,1} == op,:};
    if size(subdata,1) > 0
        for ip = 1:size(subdata,1)
            ort = subdata(ip,8)/subdata(ip,4);
            DayEneTn(op,:) = DayEneTn(op,:) - TDayEneSp(op,:).*ort;
            DayEneTn(subdata(ip,5),:) = DayEneTn(subdata(ip,5),:) + TDayEneSp(op,:).*ort;
        end
    end
end

days = (1:365);
monthday = [31,28,31,30,31,30,31,31,30,31,30,31];
cumsumday = cumsum(monthday);
for c = 1:6
    subplot(2,3,c)
    idx = find(Cluster{:,4} == c);
    % Electricity demand
    mdline = sum(AIADEneM(idx,:),1);
    loline = sum(AIADEneL(idx,:),1);
    upline = sum(AIADEneU(idx,:),1);
    % Electricity supply
    cluEne = sum(DayEneTn(idx,:),1);
    % Gap
    Mdgap = (cluEne - mdline)./sum(sspPOP(idx,31,2)).*10^9; % kwh
    Logap = (cluEne - loline)./sum(sspPOP(idx,31,2)).*10^9;
    Upgap = (cluEne - upline)./sum(sspPOP(idx,31,2)).*10^9;
    % Plot
    fill([days fliplr(days)],[Logap,fliplr(Upgap)],'r','EdgeColor','none','FaceAlpha', 0.2);hold on
    plot(days,Mdgap,'LineStyle','-','Color','r','linewidth',1.0);hold on
    xlim([1 365])
    xlabel('Day');
    ylabel('The electricity demand and supply gap (kWh/d)');
    if c == 1
        ylim([-40 20])
    elseif c == 2
        ylim([-60 20])
    elseif c == 3
        ylim([-60 20])
    elseif c == 4
        ylim([-30 10])
    elseif c == 5
        ylim([-20 40])
    elseif c == 6
        ylim([-40 20])
    end
end

%% Without considering eletricity transmission
% Fossil (Coal, Gas, Oil), Solar, Wind, Hydroelectricity, Nuclear, Other sources
% 2050
yrinf = 31;
for c = 1:6
    subplot(2,3,c)
    idx = find(Cluster{:,4} == c);
    % Electricity demand
    mdline = sum(AIADEneM(idx,:),1);
    loline = sum(AIADEneL(idx,:),1);
    upline = sum(AIADEneU(idx,:),1);
    % Electricity supply
    cluEne = sum(TDayEneSp(idx,:),1);
    % Gap
    Mdgap = (cluEne - mdline)./sum(sspPOP(idx,31,2)).*10^9;
    Logap = (cluEne - loline)./sum(sspPOP(idx,31,2)).*10^9;
    Upgap = (cluEne - upline)./sum(sspPOP(idx,31,2)).*10^9;
    % Plot
    fill([days fliplr(days)],[Logap,fliplr(Upgap)],'b','EdgeColor','none','FaceAlpha', 0.2);hold on
    plot(days,Mdgap,'LineStyle','-','Color','b','linewidth',1.0);hold on
    xlim([1 365])
    xlabel('Day');
    ylabel('The electricity demand and supply gap (kWh/d)');
    if c == 1
        ylim([-40 20])
    elseif c == 2
        ylim([-60 20])
    elseif c == 3
        ylim([-60 20])
    elseif c == 4
        ylim([-30 10])
    elseif c == 5
        ylim([-20 40])
    elseif c == 6
        ylim([-40 20])
    end
end