function Dall = readOnsetStation(Sname)
% hpm 05/29/2024
% read all data files from a particular station, sort and remove duplicate
% data
% INPUT: Sname = station name
% OUTPUT: complete data record


d0=dir(Sname);
filename={d0.name}'
D2=readOnset(['miniMET/RAW/' filename{1}]); % read the first one
for n=2:length(filename)
    filename{n}
    D=readOnset(['miniMET/RAW/' filename{n}]);
    Dfields=fields(D);
    for m=1:length(Dfields)
        D2.(Dfields{m})=[D2.(Dfields{m}); D.(Dfields{m})]; % concat fields
    end
end
% now sort based on DateTime
[Y,I]=sort(D2.DateTime);
% now sort all the other fields by time
Dfields=fields(D2);
for n=1:length(Dfields)
    D3.(Dfields{n})=D2.(Dfields{n})(I);
end
% now remove any duplicates
[C,Ix]=unique(D3.DateTime);
Dfields=fields(D3);
for n=1:length(Dfields)
    Dall.(Dfields{n})=D3.(Dfields{n})(Ix);
end

