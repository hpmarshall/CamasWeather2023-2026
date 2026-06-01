% plotCamasWeather
% loads the database file created by loadCamasWeather.m
% creates summary plots from WY2023-2026

loadCamasWeather

%% lets plot all of the SNOdar data from Camas
figure(1);clf
c='rgbmkcy'
for n=1:length(SNODAR)        
    plot(SNODAR(n).DATE,SNODAR(n).SNODAR_SEASONAL_SNOW_DEPTH,[c(n) '.']);
    hold on
end
xlim([datetime(2023,1,1) datetime(2026,5,31)])
set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
ylabel('snow depth [cm]'); xlim([datetime(2023,1,1) datetime(2026,6,1)])
[hL1,icons]=legend('0km','1km','MMR 1km','MMR 1km 20deg','2km','8km','10km'); 
set(hL1,'Location','NorthEast')
set(hL1,'FontSize',14,'linewidth',2)
set(hL1,'Color',[0.8 0.8 0.8],'FontSize',16); % make legend box big enough
% make icons bigger
Ix=[9 11 13 15 17 19 21];
for n=1:length(Ix)
    icons(Ix(n)).MarkerSize=25
end
% add some text 
h(1)=text(datetime(2023,2,1),115,'WY2023')
h(2)=text(datetime(2024,2,1),115,'WY2024')
h(3)=text(datetime(2025,2,1),115,'WY2025')
h(4)=text(datetime(2026,2,1),80,'WY2026')
h(5)=text(datetime(2023,7,1),20,'plant growth')
h(6)=text(datetime(2024,7,1),20,'plant growth')
h(7)=text(datetime(2025,7,1),20,'plant growth')
set(h,'FontSize',14,'FontWeight','bold')
exportgraphics(gcf,'FIGURES/CamasSNODAR2023-2026.png')
