% Camas Creek Divide historical analysis
load SNOTEL/snotel_camas_creek_WY1992_2026.mat
%%
%% now find previous peak swe for each year
WY=1993:2023;
for n=1:length(WY)
    Ix=water_year==WY(n);
    [Y,I]=max(WTEQ(Ix));
    maxSWE(n)=Y;
end
[Y,I]=max(maxSWE);
disp(['Max peak SWE in WY ' num2str(WY(I))])
maxWY=WY(I);
[Y,I]=min(maxSWE);
disp(['Min peak SWE in WY ' num2str(WY(I))])
minWY=WY(I);
Ix1=water_year==maxWY & dowy<301;
Ix2=water_year==minWY & dowy<301;
xf=datetime(2025,10,1)-1+[dowy(Ix1);flipud(dowy(Ix2));1];
yf1=WTEQ(Ix1)*2.54; yf2=WTEQ(Ix2)*2.54;
yf=[yf1;flipud(yf2);yf1(1)];
figure(1);clf;subplot(2,2,1)
hf1=fill(xf,yf,[0.7 0.7 0.7])
yf1=SNWD(Ix1)*2.54; yf2=SNWD(Ix2)*2.54;
yf=[yf1;flipud(yf2);yf1(1)];
subplot(2,2,3)
hf2=fill(xf,yf,[0.7 0.7 0.7])
%% now find median SWE on each dowy
for n=1:250
    Ix=(dowy==n & water_year<2023);
    medSWE(n)=median(WTEQ(Ix)*2.54);
    Ix2=(dowy==n & water_year<2023 & water_year>2010);
    medSD(n)=median(SNWD(Ix2)*2.54);
end
subplot(2,2,1); hold on
hm1=plot(datetime(2025,10,1)-1+[1:250],medSWE,'k-.','linewidth',1)
subplot(2,2,3); hold on
hm2=plot(datetime(2025,10,1)-1+[1:250],medSD,'k-.','linewidth',1)
xtickformat('MM-dd'); xsecondarylabel(Visible="off") % remove year

% lets first plot the 3 water years
WY=[2023 2024 2025 2026]
c='rgbm'
for n=1:length(WY)
    Ix=water_year==WY(n);
    subplot(2,2,1)
    h1(n)=plot(datetime(2025,10,1)-1+dowy(Ix),WTEQ(Ix)*2.54,c(n),'linewidth',2)
    hold on
    subplot(2,2,3)
    h2(n)=plot(datetime(2025,10,1)-1+dowy(Ix),SNWD(Ix)*2.54,c(n),'linewidth',2)
    hold on
end

subplot(2,2,1); set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
ylabel('SWE [cm]'); xlim([datetime(2025,10,1) datetime(2026,6,1)])
hL1=legend([hf1 hm1 h1],'1993-2023','30yr median','2023','2024','2025','2026'); set(hL1,'Location','NorthWest')
set(hL1,'FontSize',14,'linewidth',2)
%
subplot(2,2,3); set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
ylabel('depth [cm]'); xlim([datetime(2025,10,1) datetime(2026,6,1)])
hL2=legend([hf2 hm2 h2],'1993-2023','30yr median','2023','2024','2025','2026'); set(hL2,'Location','NorthWest')
set(hL2,'FontSize',14,'linewidth',2)
%% box plots for temperature
subplot(2,2,2); cla
Ix=water_year>2022 & water_year<2027 & dowy<182; % get all three water years before April 1
G=water_year(Ix);
fill([0.5 4.5 4.5 0.5 0.5],[0 0 -17 -17 0],[198, 252, 255]/255); hold on
hb=boxplot(5/9*(TAVG(Ix)-32),G); 
set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
set(hb,'linewidth',2); ylim([-12 14.5]); xlim([0.5 4.5])
ylabel('average daily temp [^oC], Oct 1-April 1')
%% bar plot for precip
for n=2023:2026
    Ix=water_year==n & dowy<182;
    P(n-2022)=sum(PRCP(Ix)*2.54);
end
subplot(2,2,4)
bar([2023 2024 2025 2026],P)
set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
xlabel('Year')
ylabel('Total precip [cm], Oct 1-April 1')
ylim([0 55]); xlim([2022.5 2026.5])
exportgraphics(gcf,'FIGURES/CamasSNOTEL2023-2025.png')
