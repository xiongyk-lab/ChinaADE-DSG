tic
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loading data
load('input\Biefig2.dat','-mat')
load('input\supbudget.dat','-mat')
Electricity_generation = readtable('input\PowerGeneration.xlsx','sheet','Electricity_generation','PreserveVariableNames',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 5 a
figure(1)
colors = ["#D6857C";"#D95319";"#EDB120";"#F5B1CA";"#77AC30";"#4DBEEE"];
for p = 1:31
    subplot(4,8,p)
    pief = pie(Biefig2(p,:));
    for i = 1:2:length(pief)
        pief(i).FaceColor = colors(ceil(i/2), :);
    end
    title(Electricity_generation{p,1})
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 5 b
figure(2)
color = flipud(slanCM(97,40));
discolor = color(15:38,:);
discolor(1, :) = [1, 1, 1];
heatmap(supbudget(:,4:8),'Colormap',discolor);


toc