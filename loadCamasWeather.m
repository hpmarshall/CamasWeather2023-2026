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








% save all structure arrays as a MATLAB data file
%save Camas2023-26miniMet miniMet SNODAR SNOTEL




