% plotCamasWeather
% loads the database file created by loadCamasWeather.m
% creates summary plots from WY2023-2026

%loadCamasWeather
%addpath('/Users/hpmarshall/D_DRIVE/MATLAB/windrose/')

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

%% plot miniMet data from Camas
figure(2);clf
c='rgbmkcy';
for n=1:5
    subplot(5,1,n)
    plot(miniMet(n).DateTime,miniMet(n).Temp,[c(n) '-']); hold on
    xlim([datetime(2022,12,15) datetime(2026,5,31)]); ylim([-25 35])
    title(miniMet(n).name)
    set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
    if n==3
        ylabel('air temperature [^oC]')
    end
end
%% temperature and wind to compare sites
D=[]; G=[];
sites={'site0km ','site1km ','site2km ','site8km ','site10km'};
years={'2023','2024','2025','2026'};

%% temp and wind plots
figure(3);clf; figure(5); clf
for n=1:length(miniMet)
    Ix2023=miniMet(n).DateTime<datetime(2023,4,1); % 2023 winter
    Ix2024=miniMet(n).DateTime>datetime(2023,11,1) & miniMet(n).DateTime<datetime(2024,4,1); % 2024 winter
    Ix2025=miniMet(n).DateTime>datetime(2024,11,1) & miniMet(n).DateTime<datetime(2025,4,1); % 2025 winter
    Ix2026=miniMet(n).DateTime>datetime(2025,11,1) & miniMet(n).DateTime<datetime(2026,4,1); % 2026 winter
    Ix1=Ix2023 | Ix2024 | Ix2025 | Ix2026;
    D=[D;miniMet(n).Temp(Ix1)]; % make a long array of all temperature data
    Dwind=[D;miniMet(n).WindDirection(Ix1)]; % make a long array of all temperature data
    G=[G;repmat(sites{n},length(miniMet(n).Temp(Ix1)),1)];
    % now do year by year comparison
    figure(3);
    subplot(1,5,n)
    fill([0.5 4.5 4.5 0.5 0.5],[0 0 -20 -20 0],[198, 252, 255]/255); hold on
    D2=miniMet(n).Temp(Ix1);
    D2wind=miniMet(n).WindDirection(Ix1);
    D2speed=miniMet(n).WindSpeed(Ix1);
    G2=Ix2023*2023+Ix2024*2024+Ix2025*2025+Ix2026*2026;
    G2=G2(G2>0);
    hb=boxplot(D2,G2,'notch','on'); 
    set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
    set(hb,'linewidth',2); %ylim([-12 14.5]); xlim([0.5 4.5])
    ylabel('winter air temperature [^oC]')
    xlim([0.5 4.5]); ylim([-20 20])
    title(miniMet(n).name)
    % plot wind roses
    IxR=[0 5 10 15]+n
    figure(5);
    for q=1:4
        subplot(4,5,IxR(q))
        %set(gcf, 'units', 'normalized', 'position', [0 0 1 1]);
        Ix=G2==2022+q; % find the year
        Options = {'anglenorth', 0, 'angleeast', 90, 'labels', {'N (0°)', 'E (90°)', 'S (180°)', 'W (270°)'}, 'freqlabelangle', 45, ...
            'legendtype', 1,'axes', gca,'ScaleFactor',1,'vWinds', [0 2.5 5 7.5 10]};
        [figure_handle, count, speeds, directions, Table] = WindRose(miniMet(n).WindDirection(Ix), miniMet(n).WindSpeed(Ix), Options);
        if n==1
            ylabel(num2str(2022+q))
        end
        if q==1
            title(miniMet(n).name)
        else
            title(' ')
        end
    end
end
%%
figure(4);clf
hb=boxplot(D,G,'notch','on'); 
set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
set(hb,'linewidth',2); ylim([-20 15]); xlim([0.5 5.5])
ylabel('winter air temperature [^oC]')
%% plot wind direction during winter
figure(6);clf
for n=1:5
    subplot(5,1,n)
    Ix=miniMet(n).WindSpeed>5;
    plot(miniMet(n).DateTime(Ix),miniMet(n).WindDirection(Ix),[c(n) '.']); hold on
    xlim([datetime(2022,12,15) datetime(2026,5,31)]); %ylim([-25 35])
    title(miniMet(n).name)
    set(gca,'FontSize',14,'FontWeight','bold','LineWidth',2)
    if n==3
        ylabel('wind direction [degrees from North] for speed > 5 [m/s] ')
    end
    ylim([0 360])
    hold on
    plot([datetime(2022,12,15) datetime(2026,5,31)],[90 90],'k')
    plot([datetime(2022,12,15) datetime(2026,5,31)],[270 270],'k')
end
%% print some figures
figure(2); exportgraphics(gcf,'FIGURES/CamasTemp.png')
figure(3); exportgraphics(gcf,'FIGURES/CamasTemp2.png')
figure(4); exportgraphics(gcf,'FIGURES/CamasTemp3.png')
figure(5); exportgraphics(gcf,'FIGURES/CamasWindRose.png')
figure(6); exportgraphics(gcf,'FIGURES/CamasWind.png')
%% and now export data to CSV

















