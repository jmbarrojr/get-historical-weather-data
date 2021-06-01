% Simple MATLAB test script
% Julio Barros - 2021

clc,clear

startDate = datetime('2020-05-30');
endDate = datetime('2021-05-30');

[Tmin,Tmax,Tmean,seaLevelPressure,stationPressure] = ...
                    getHistoricalWeatherData(startDate);