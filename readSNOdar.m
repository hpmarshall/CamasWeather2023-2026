function D = readSNOdar(filename)
% hpm  05/29/2024
% function to read data from Onset HOBO weather stations
% INPUT: filename = data file
% OUTPUT: D = structure array of weather obs

T=readtable(filename,'Delimiter',',');
if ~isdatetime(T.DATE)
    T.DATE=datetime(T.DATE,'InputFormat','eee MMM dd HH:mm:ss yyyy');
end

vNames={'DATE','SNODAR_DISTANCE','SNODAR_SEASONAL_SNOW_DEPTH','ID','VER','POWER_CURRENT','POWER_VOLTAGE','IMU_TEMP','TMP_TEMP',...
    'SNODAR_SOC_TEMP','SNODAR_PCB_TEMP','IMU_R','IMU_P','IMU_Y','HEATER_ENABLED'};
for n=1:length(vNames)
    vNames{n};
    Ix=find(contains(T.Properties.VariableNames,vNames{n})); % get the variable with "Date" in the name, since it changed
    if length(Ix)>0
        D.(vNames{n})=T.(T.Properties.VariableNames{Ix}); % now this works for any DateTime variable!
    else
        D.(vNames{n})=ones(height(T),1)*NaN; % add NaN if not measured
    end
end


% 
% 
% D.DateTime=datetime(datevec(D.DateTime)+ones(length(D.DateTime),1)*[2000 0 0 0 0 0]); % add 2000 yrs!
% D.Temp=T.Temp__C_LGRS_N_21623142_SENS_N_21549907_LBL_T_;
% D.RH=T.RH___LGRS_N_21623142_SENS_N_21549907_LBL_Rh_;
% D.Pressure=T.Pressure_Mbar_LGRS_N_21623142_SENS_N_21318866_LBL_BarometricPre;
% D.WindSpeed=T.WindSpeed_M_s_LGRS_N_21623142_SENS_N_21534754_LBL_Ws_;
% D.GustSpeed=T.GustSpeed_M_s_LGRS_N_21623142_SENS_N_21534754_LBL_Gst_;
% D.WindDirection=T.WindDirection___LGRS_N_21623142_SENS_N_21534754_LBL_Wd_;