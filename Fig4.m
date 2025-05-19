tic
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loading data 
load('input\subTotalEne.dat','-mat')
load('input\FuEn.dat','-mat')
load('input\FuEnwAI.dat','-mat')
load('input\NWindEne.dat','-mat');
load('input\CapWind.dat','-mat');
load('input\CapSolar.dat','-mat');
load('input\CapBiomass.dat','-mat');
load('input\NSolarEne.dat','-mat');
load('input\NBioEne.dat','-mat');
load('input\CasedataA.dat','-mat');
load('input\CasedataB.dat','-mat');
load('input\CasedataC.dat','-mat');
load('input\CasedataD.dat','-mat');
load('input\CaseA.dat','-mat');
load('input\CaseB.dat','-mat');
load('input\CaseC.dat','-mat');
load('input\CaseD.dat','-mat');
Hydrofspace = readtable('input\Hydrofspace.csv','PreserveVariableNames',true);
NBioEneCap = readtable('input\NBioEneCap.csv','PreserveVariableNames',true);
NBioEneCap = sortrows(NBioEneCap, [1, 2]);
modelname = readtable('input\modelname.xlsx','sheet','model70','PreserveVariableNames',true);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 4 a-c, Feasibility space
figure(1)
x = Hydrofspace{:,1};
y = Hydrofspace{:,2};
n = length(x);
Yinfs = (2010:2100);
idxend = find(Yinfs == 2050);
colorindex = [10,8,11,12,17,35];
% 103 (133),114,136,167,168
unTempColors = slanCM(133,size(unique(subTotalEne(:,3)),1));
%% The wind power potential (GW)
subplot(1,3,1)
NWindEne = sortrows(NWindEne, [1, 2]);
plot(x, y,'LineStyle','-','Color',[0.6350 0.0780 0.1840],'linewidth',1.5);hold on
colors = slanCM(12,n);
for i = 1:n-1
    x_fill = [x(i), x(i), x(i+1), x(i+1)];
    y_fill = [0, y(i), y(i+1), 0];
    patch(x_fill, y_fill, colors(i, :), 'EdgeColor', 'none', 'FaceAlpha',0.1);
end
% 2010: 1% total electricity supply
Windpt = 10948; WindOnRt = 8694/10948; WindOffRt = 2254/10948;
windthres = 29.58/Windpt;
yrwind = (2005:2050);
unTemp = unique(NWindEne(:,3));
CapWind(:,4:end) = CapWind(:,4:end)./Windpt;
% Utilization rate in 2025 and 2050
for sd = 1:size(unTemp,1)
    submodel = NWindEne(NWindEne(:,3) == unTemp(sd),:);
    submodel2 = CapWind(CapWind(:,3) == unTemp(sd),:);
    for sc = 1:size(submodel,1)
        subdata = submodel(sc,4:end);
        idxtk = find(subdata>=windthres);
        sNWindEne = subdata(1,idxtk);
        subNWindEne = zeros(size(sNWindEne,2),3);
        for yr = 1:size(sNWindEne,2)
            subNWindEne(yr,1) = yr -1;
            subNWindEne(yr,2) = yrwind(idxtk(yr));
            subNWindEne(yr,3) = sNWindEne(1,yr);
        end
        idxyr = find(subNWindEne(:,2)>=2025);
        plot(subNWindEne(idxyr,1), subNWindEne(idxyr,3), '--','Color',unTempColors(sd,:),'linewidth',1.0); hold on
        % Optimation
        plot(subNWindEne(idxyr,1), submodel2(sc,4:size(idxyr,1)+3), '-','Color',unTempColors(sd,:),'linewidth',1.5); hold on
    end
end
ylim([0 0.4]);
xlim([0 40]);
ax.YTick = 0:0.1:0.4;
xlabel('Years from take-off');
ylabel('Utilization rate of enegry');
title('Wind capacity');

%% The PV power potential (GW)
subplot(1,3,2)
NSolarEne = sortrows(NSolarEne, [1, 2]);
PVpt = 45604; PVCenRt = 41878/45604; PVDisRt = 3726/45604;
plot(x, y,'LineStyle','-','Color',[0.23529 0.70196 0.44314],'linewidth',1.5);hold on
colors = slanCM(24,n);
for i = 1:n-1
    x_fill = [x(i), x(i), x(i+1), x(i+1)];
    y_fill = [0, y(i), y(i+1), 0];
    patch(x_fill, y_fill, colors(i, :), 'EdgeColor', 'none', 'FaceAlpha',0.1);
end
% 2016:1% total electricity supply
solarthres = 42.18/PVpt;
yrsolar = (2010:2050);
unTemp = unique(NSolarEne(:,3));
CapSolar(:,4:end) = CapSolar(:,4:end)./PVpt;
for sd = 1:size(unTemp,1)
    submodel = NSolarEne(NSolarEne(:,3) == unTemp(sd),:);
    submodel2 = CapSolar(CapSolar(:,3) == unTemp(sd),:);
    for sc = 1:size(submodel,1)
        subdata = submodel(sc,4:end);
        idxtk = find(subdata>=solarthres);
        sNSolarEne = subdata(1,idxtk);
        subNSolarEne = zeros(size(sNSolarEne,2),3);
        for yr = 1:size(sNSolarEne,2)
            subNSolarEne(yr,1) = yr -1;
            subNSolarEne(yr,2) = yrsolar(idxtk(yr));
            subNSolarEne(yr,3) = sNSolarEne(1,yr);
        end
        % After 2050
        idxyr = find(subNSolarEne(:,2)>=2025);
        plot(subNSolarEne(idxyr,1), subNSolarEne(idxyr,3), '--','Color',unTempColors(sd,:),'linewidth',1.0); hold on
        % Optimation
        plot(subNSolarEne(idxyr,1), submodel2(sc,4:size(idxyr,1)+3), '-','Color',unTempColors(sd,:),'linewidth',1.5); hold on
    end
end
ylim([0 0.4]);
xlim([0 40]);
ax.YTick = 0:0.1:0.4;
xlabel('Years from take-off');
ylabel('Utilization rate of enegry');
title('Solar capacity');

%% Biomass enegry
subplot(1,3,3)
NBioEne = sortrows(NBioEne, [1, 2]);
plot(x, y,'LineStyle','-','Color',[0.39216 0.58431 0.92941],'linewidth',1.5);hold on
colors = slanCM(9,n);
for i = 1:n-1
    x_fill = [x(i), x(i), x(i+1), x(i+1)];
    y_fill = [0, y(i), y(i+1), 0];
    patch(x_fill, y_fill, colors(i, :), 'EdgeColor', 'none', 'FaceAlpha',0.1);
end
% 2016:1% total electricity supply
biomassthres = 12.16/(222 + 222*0.45/0.25 + 7.12);
CapBiomass(:,4:end) = CapBiomass(:,4:end)./NBioEneCap{:,19:end};
for sd = 1:size(unTemp,1)
    submodel = NBioEne(NBioEne(:,3) == unTemp(sd),:);
    submodel2 = CapBiomass(CapBiomass(:,3) == unTemp(sd),:);
    for sc = 1:size(submodel,1)
        subdata = submodel(sc,4:end);
        idxtk = find(subdata>=biomassthres);
        sNBioEne = subdata(1,idxtk);
        subNBioEne = zeros(size(sNBioEne,2),3);
        for yr = 1:size(sNBioEne,2)
            subNBioEne(yr,1) = yr -1;
            subNBioEne(yr,2) = yrsolar(idxtk(yr));
            subNBioEne(yr,3) = sNBioEne(1,yr);
        end
        % After 2050
        idxyr = find(subNBioEne(:,2)>=2025);
        plot(subNBioEne(idxyr,1), subNBioEne(idxyr,3), '--','Color',unTempColors(sd,:),'linewidth',1.0); hold on
        % Optimation
        plot(subNBioEne(idxyr,1), submodel2(sc,4:size(idxyr,1)+3), '-','Color',unTempColors(sd,:),'linewidth',1.5); hold on
    end
end
ylim([0 0.4]);
xlim([0 40]);
xlabel('Years from take-off');
ylabel('Utilization rate of enegry');
title('Biomass capacity');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 4 d, Cumulative cost
figure(2)
mdid = unique(modelname{:,2});
%modelsys = ["o","+","x","square","diamond","^","v",">","<"];
modelsys = ["square","diamond","^","v",">","<"];
modelclr = [[162, 20, 47];[217, 83, 25];[170, 201, 126];[152, 95, 168];[239, 187, 60];[0, 114, 189]]./255;
% 'Capital cost','OM cost','TD cost','CO2 cost'
dataName = {'CO2 cost','TD cost','OM cost','Capital cost'};
classNum = size(dataName,2);
locindx = (1:classNum);
% 1917 & 1886 & 1884 & 1946 & 204 & 198 & 533
colornum = 204;
cum = 3;
% Axis
ax = gca;
ax.XLim = [1/2,classNum+2/3];
ax.XTick = 1:classNum;
% Histogram
% Baseline, CasedataA, CasedataB, CasedataC, CasedataD, CasedataE, CasedataF, CasedataG
hisdata = [CasedataA, CasedataB, CasedataC, CasedataD];
boxplot(hisdata,locindx,'Colors',slanCL(colornum,(1:classNum)+cum),...
    'symbol','', 'Whisker',1.5, 'Notch','on', 'OutlierSize',6, 'Widths',0.3);hold on
ax.XTickLabels = dataName;
for c = 1:classNum
    if c == 1
        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = CaseA(CaseA(:,1) == mln(j),4);
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end

    elseif c == 2
        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = CaseB(CaseB(:,1) == mln(j),4);
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end

    elseif c == 3
        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = CaseC(CaseC(:,1) == mln(j),4);
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end
    elseif c == 4
        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = CaseD(CaseD(:,1) == mln(j),4);
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end
    end
end

ylim([log10(0.0001) log10(20)])
%ax.YTick = 0:5:15;
xlabel('The economic costs of expanding energy capacity');
ylabel('Cumulative cost (2025-2050) (trillion, constant 2010 US$)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 4 e
figure(3)
% (1 EJ = 0.27777777777778 PWh)
TrsF = 0.27777777777778;
% Model name
CaseA = readtable('input\CaseA.csv','PreserveVariableNames',true);
CaseB = readtable('input\CaseB.csv','PreserveVariableNames',true);
CaseC = readtable('input\CaseC.csv','PreserveVariableNames',true);
CasedataA = CaseA{:,6}.*TrsF;
CasedataB = CaseB{:,6}.*TrsF;
CasedataC = CaseC{:,6}.*TrsF;
Yinfplot = (2020:2050);
mdid = unique(modelname{:,2});
modelsys = ["square","diamond","^","v",">","<"];
%modelclr = ["o","+","x","square","diamond","^","v",">","<"];
modelclr = [[162, 20, 47];[217, 83, 25];[170, 201, 126];[152, 95, 168];[239, 187, 60];[0, 114, 189]]./255;
% 'Baseline','CaseA','CaseB','CaseC','CaseD','CaseE','CaseF','CaseG';
dataName = {'Baseline','Wind','Wind & Solar','Wind & Solar & Biomass'};
classNum = size(dataName,2);
locindx = (1:classNum);
rate = 1.4;
FaceAlpha = 0.1;
FaceAlphap = 0.7;
Baseline = subTotalEne(:,size(Yinfplot,2)+3);
% 1917 & 1886 & 1884 & 1946 & 204 & 198 & 533
colornum = 204;
cum = 3;
% Axis
ax = gca;
ax.XLim = [1/2,classNum+2/3];
ax.XTick = 1:classNum;
% Histogram
% Baseline, CasedataA, CasedataB, CasedataC, CasedataD, CasedataE, CasedataF, CasedataG
hisdata = [Baseline, CasedataA, CasedataB, CasedataC];
boxplot(hisdata,locindx,'Colors',slanCL(colornum,(1:classNum)+cum),...
    'symbol','', 'Whisker',1.5, 'Notch','on', 'OutlierSize',6, 'Widths',0.3);hold on
ax.XTickLabels = dataName;
% W/o AI
MedianEne = median(subTotalEne(:,4:size(Yinfplot,2)+3),1);
x_range = xlim;
x_fill = [x_range(1) x_range(2) x_range(2) x_range(1)];
% Impact (2050)
lowAI = sum(FuEn(:,end,1),1)/10^3;
upAI = sum(FuEn(:,end,3),1)/10^3;
mdAI = sum(FuEn(:,end,2),1)/10^3;
y_fill = [lowAI lowAI upAI upAI];
fill(x_fill, y_fill,[1 0.8 1],'EdgeColor','none','FaceAlpha', FaceAlpha);hold on
plot(x_range, [mdAI mdAI],'LineStyle','--','Color','r','linewidth',1.5);hold on
% Without impacts (2050)
lowwAI = sum(FuEnwAI(:,end,1),1)/10^3;
upwAI = sum(FuEnwAI(:,end,3),1)/10^3;
mdwAI = sum(FuEnwAI(:,end,2),1)/10^3;
y_fill = [lowwAI lowwAI upwAI upwAI];
fill(x_fill, y_fill,[0 0.4470 0.7410],'EdgeColor','none','FaceAlpha',FaceAlpha);hold on
plot(x_range, [mdwAI mdwAI],'LineStyle','--','Color','b','linewidth',1.5);hold on

for c = 1:classNum
    if c == 1
        % Baseline
        [F,Xi] = ksdensity(subTotalEne(:,size(Yinfplot,2)+3));
        maxv = max(subTotalEne(:,size(Yinfplot,2)+3));
        minv = min(subTotalEne(:,size(Yinfplot,2)+3));
        idx = find(Xi>maxv+0.1 | Xi<minv-0.1);
        F(idx) = [];
        Xi(idx) = [];
        fill(0.2+[0,F,0].*rate +(c).*ones(1,length(F)+2),[Xi(1),Xi,Xi(end)],slanCL(colornum,c+cum),...
            'EdgeColor',slanCL(colornum,c+cum),'FaceAlpha',FaceAlphap,'LineWidth',0.5); hold on

        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = subTotalEne(subTotalEne(:,1) == mln(j),size(Yinfplot,2)+3);
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end

    elseif c == 2
        % CaseA
        [F,Xi] = ksdensity(CasedataA);
        maxv = max(CasedataA);
        minv = min(CasedataA);
        idx = find(Xi>maxv+0.1 | Xi<minv-0.1);
        F(idx) = [];
        Xi(idx) = [];
        fill(0.2+[0,F,0].*rate +(c).*ones(1,length(F)+2),[Xi(1),Xi,Xi(end)],slanCL(colornum,c+cum),...
            'EdgeColor',slanCL(colornum,c+cum),'FaceAlpha',FaceAlphap,'LineWidth',0.5); hold on

        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = CaseA{CaseA{:,1} == mln(j),6}.*TrsF;
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end

    elseif c == 3
        % CaseB
        [F,Xi] = ksdensity(CasedataB);
        maxv = max(CasedataB);
        minv = min(CasedataB);
        idx = find(Xi>maxv+0.1 | Xi<minv-0.1);
        F(idx) = [];
        Xi(idx) = [];
        fill(0.2+[0,F,0].*rate +(c).*ones(1,length(F)+2),[Xi(1),Xi,Xi(end)],slanCL(colornum,c+cum),...
            'EdgeColor',slanCL(colornum,c+cum),'FaceAlpha',FaceAlphap,'LineWidth',0.5); hold on

        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = CaseB{CaseB{:,1} == mln(j),6}.*TrsF;
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end

    elseif c == 4
        % CaseC
        [F,Xi] = ksdensity(CasedataC);
        maxv = max(CasedataC);
        minv = min(CasedataC);
        idx = find(Xi>maxv+0.1 | Xi<minv-0.1);
        F(idx) = [];
        Xi(idx) = [];
        fill(0.2+[0,F,0].*rate +(c).*ones(1,length(F)+2),[Xi(1),Xi,Xi(end)],slanCL(colornum,c+cum),...
            'EdgeColor',slanCL(colornum,c+cum),'FaceAlpha',FaceAlphap,'LineWidth',0.5); hold on

        for m = 1:size(mdid,1)
            mln = modelname{modelname{:,2} == m,1};
            for j = 1:size(mln,2)
                dataplot = CaseC{CaseC{:,1} == mln(j),6}.*TrsF;
                for i = 1:size(dataplot,2)
                    scatter(ones(size(dataplot, 1),1)*c,dataplot,25,modelsys(m),'jitter','on','jitterAmount',0.15,...
                        'MarkerEdgeColor',modelclr(m,:)); hold on
                end
            end
        end

    end

end

ylim([15 30])
ax.YTick = 15:5:30;
xlabel('Expanding energy capacity improves national electricity production');
ylabel('Total electricity generation in 2050 (PWh)');




toc
