function [Tmin,Tmax,Tmean,seaLevelPressure,stationPressure] = getHistoricalWeatherData(Date)
% This function get historical weather data from NCEI API
%
% [Tmin,Tmax,Tmean,seaLevelPressure,stationPressure] = getHistoricalWeatherData(Date)
%
% INPUT = MATLAB date datatype (eg: Date = datetime('today');
%         You can also add a start and end date
%         (eg: [startDate=datetime('2020-05-30') endDate=datetime('2021-05-30')]
%
% This is a simple, proof-of-concept to easily fetch weather data in MATLAB.
% The output is set to JSON, and matlab conveniently packs the weather data
% into a struct datatype, making it easy to handle the data.
%
% For this code, it uses the Global Surface Summary of the Day (GSOD)
% dataset, and the Naha statation (47936099999) to fetch temperatures and
% sea level pressure data. For more information on the dataset, visit
% <https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/readme.txt>
%
% It should be easy to modify the code to suit other weather data and dataset
% needs. For more infomatio, visit NCEI API website
% <https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation>
%
% Julio Barros - 2021

WeatherData = getWeatherDataFromService(Date);

if ~isempty(WeatherData)
    Tmean = str2double(cat(1,WeatherData.TEMP)); % [F]
    Tmin = str2double(cat(1,WeatherData.MIN));   % [F]
    Tmax = str2double(cat(1,WeatherData.MAX));   % [F]
    seaLevelPressure = str2double(cat(1,WeatherData.SLP)); % [mb]
    stationPressure = str2double(cat(1,WeatherData.STP));  % [mb]
    
    % Convert to SI units
    Tmean = Fahenheit2Celsius(Tmean); % [C]
    Tmin = Fahenheit2Celsius(Tmin);   % [C]
    Tmax = Fahenheit2Celsius(Tmax);   % [C]
    seaLevelPressure = seaLevelPressure * 100; %{Pa]
    stationPressure = stationPressure * 100; %{Pa]
else
    Tmean = []; Tmin = []; Tmax = [];
    seaLevelPressure = []; stationPressure = [];
end
end

function WeatherData = getWeatherDataFromService(Date)
YYYY = num2str(year(Date(1)));
MM = num2str(month(Date(1)),'%02d');
DD = num2str(day(Date(1)),'%02d');
startDate = [YYYY '-' MM '-' DD];
endDate = startDate;
if numel(Date) > 1
    YYYY = num2str(year(Date(2)));
    MM = num2str(month(Date(2)),'%02d');
    DD = num2str(day(Date(2)),'%02d');
    endDate = [YYYY '-' MM '-' DD];
elseif numel(Date) > 2
    error('Date can only be a two length cell array')
end

url = ['https://www.ncei.noaa.gov/access/services/data/v1'...
    '?dataset=global-summary-of-the-day'... % DATASET
    '&dataTypes=TEMP,MAX,MIN,SLP,STP'...    % WEATHER DATA TYPE
    '&stations=47936099999'...              % STATION
    '&startDate=' startDate...
    '&endDate=' endDate...
    '&includeAttributes=false'...
    '&includeStationName=true'...
    '&units=metric'...
    '&format=json'];
WeatherData = webread(url);
end