% loadCamasWeather
% HPM 5/31/2026 - adapted from script in CamasWeather repo
% This loads all data from miniMet sites and SNOTEL

%% now load the SNOdar data
%Sname={'IDWR_BASE*','IDWR_1km*','IDWR_2km*','IDWR_8km*','IDWR_10km*','IDWR_Kilgore*'};
Sname={'IDWR_BASE*','IDWR_1km*','IDWR_MMR1km_*','IDWR_MMR1km20deg*','IDWR_2km*','IDWR_8km*','IDWR_10km*'};
for n=1:length(Sname)
    fname=['SNODAR/RAW/' Sname{n}]
    SNODAR(n) = readSNOdarStation(fname);
    % filter depths for the few outliers
    SNODAR(n).SNODAR_SEASONAL_SNOW_DEPTH=medfilt1(SNODAR(n).SNODAR_SEASONAL_SNOW_DEPTH,7)*100; % filter
    if n==1
        SNODAR(n).SNODAR_SEASONAL_SNOW_DEPTH(SNODAR(n).SNODAR_SEASONAL_SNOW_DEPTH>1)=NaN;
    end
end
for n=1:length(Sname)
    SNODAR(n).name=Sname{n}(1:end-1);
end


%  save data as CSV files for non-MATLAB users
SNODAR2=rmfield(SNODAR,'name'); % make copy and remove name field
for n=1:length(SNODAR)
    myTable = struct2table(SNODAR2(n));
    writetable(myTable, ['SNODAR/CSV/' SNODAR(n).name '.csv']);
end

%% load miniMet data
Sname={'site0km*','site1km*','site2km*','site8km*','site10km*'};
for n=1:length(Sname)
    fname=['miniMET/RAW/' Sname{n}]
    miniMet(n) = readOnsetStation(fname);
    % filter data for QA/QC
    Ix=miniMet(n).Temp>50 | miniMet(n).Temp<-40;
    miniMet(n).Temp(Ix)=NaN;
    Ix=miniMet(n).WindDirection>359 | miniMet(n).WindDirection<0;
    miniMet(n).WindDirection(Ix)=NaN;
end
for n=1:length(Sname)
    miniMet(n).name=Sname{n}(1:end-1);
end

%%  save data as CSV files for non-MATLAB users
miniMet2=rmfield(miniMet,'name'); % make copy and remove name field
for n=1:length(miniMet)
    myTable = struct2table(miniMet2(n));
    writetable(myTable, ['miniMET/CSV/' miniMet(n).name '.csv']);
end

%% now load the SNOTEL data
load SNOTEL/snotel_camas_creek_WY1992_2026.mat
SNOTEL.DateTime=dates;
SNOTEL.TempAvg=5/9*(TAVG-32);
SNOTEL.TempMin=5/9*(TMIN-32);
SNOTEL.TempMax=5/9*(TMAX-32);
SNOTEL.SnowDepth=SNWD*2.54;
SNOTEL.SWE=WTEQ*2.54;
SNOTEL.Precip=PRCP*2.54;
SNOTEL.name='Camas Creek Divide';
SNOTEL.units.temp='deg C';
SNOTEL.units.SnowDepth='cm';
SNOTEL.units.SWE='cm';
SNOTEL.units.Precip='cm';

% save all structure arrays as a MATLAB data file
save Camas2023-26miniMet miniMet SNODAR SNOTEL




