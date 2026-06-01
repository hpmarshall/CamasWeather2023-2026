function D = readOnset(filename)
% hpm  05/29/2024
% function to read data from Onset HOBO weather stations
% INPUT: filename = data file
% OUTPUT: D = structure array of weather obs

T=readtable(filename);

vNames={'DateTime','Temp','RH','Pressure','WindSpeed','GustSpeed','WindDirection'};
for n=1:length(vNames)
    vNames{n}
    Ix=find(contains(T.Properties.VariableNames,vNames{n})); % get the variable with "Date" in the name, since it changed
    if length(Ix)>0
        D.(vNames{n})=T.(T.Properties.VariableNames{Ix}); % now this works for any DateTime variable!
    else
        D.(vNames{n})=ones(height(T),1)*NaN; % add NaN if not measured
    end
end
D.DateTime=datetime(datevec(D.DateTime)+ones(length(D.DateTime),1)*[2000 0 0 0 0 0]); % add 2000 yrs!


% 
% 
% D.DateTime=datetime(datevec(D.DateTime)+ones(length(D.DateTime),1)*[2000 0 0 0 0 0]); % add 2000 yrs!
% D.Temp=T.Temp__C_LGRS_N_21623142_SENS_N_21549907_LBL_T_;
% D.RH=T.RH___LGRS_N_21623142_SENS_N_21549907_LBL_Rh_;
% D.Pressure=T.Pressure_Mbar_LGRS_N_21623142_SENS_N_21318866_LBL_BarometricPre;
% D.WindSpeed=T.WindSpeed_M_s_LGRS_N_21623142_SENS_N_21534754_LBL_Ws_;
% D.GustSpeed=T.GustSpeed_M_s_LGRS_N_21623142_SENS_N_21534754_LBL_Gst_;
% D.WindDirection=T.WindDirection___LGRS_N_21623142_SENS_N_21534754_LBL_Wd_;