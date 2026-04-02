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

[dateStart, dateEnd, requestedDates] = normalizeDateInput(Date);
cacheFile = getWeatherCacheFilePath();

cache = loadWeatherCache(cacheFile);
[hasAllDates, Tmin, Tmax, Tmean, seaLevelPressure, stationPressure] = ...
    getFromCache(cache, requestedDates);

if hasAllDates
    return
end

WeatherData = getWeatherDataFromService([dateStart, dateEnd]);
if isempty(WeatherData)
    Tmin = []; Tmax = []; Tmean = [];
    seaLevelPressure = []; stationPressure = [];
    return
end

[apiDates, Tmin_all, Tmax_all, Tmean_all, SLP_all, STP_all] = parseWeatherData(WeatherData);
cache = mergeWeatherCache(cache, apiDates, Tmin_all, Tmax_all, Tmean_all, SLP_all, STP_all);
saveWeatherCache(cacheFile, cache);

[hasAllDates, Tmin, Tmax, Tmean, seaLevelPressure, stationPressure] = ...
    getFromCache(cache, requestedDates);

if ~hasAllDates
    Tmin = []; Tmax = []; Tmean = [];
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

url_achive = "https://archive-api.open-meteo.com/v1/archive";
params = "?latitude=" + 26.3358 + ...
	     "&longitude=" + 127.8014 + ...
         "&start_date=" + startDate + ...
         "&end_date=" + endDate +...
	     "&daily=temperature_2m_mean,temperature_2m_max,temperature_2m_min," + ...
         "pressure_msl_mean,surface_pressure_mean" + ...
	     "&timezone=auto";
url = url_achive + params;
try
    opts = weboptions('Timeout', 12);
    out = webread(url, opts);
    WeatherData.DATE = string(out.daily.time);
    WeatherData.TEMP = out.daily.temperature_2m_mean;
    WeatherData.MIN = out.daily.temperature_2m_min;
    WeatherData.MAX = out.daily.temperature_2m_max;
    WeatherData.SLP = out.daily.pressure_msl_mean;
    WeatherData.STP = out.daily.surface_pressure_mean;
catch ME
    warning('Failed to fetch weather data from service: %s', ME.message);
    WeatherData = [];
end
end

function [dateStart, dateEnd, requestedDates] = normalizeDateInput(Date)
if ~isa(Date, 'datetime')
    error('Date input must be datetime')
end

if numel(Date) > 2
    error('Date input can only have one or two datetime values')
end

dateStart = dateshift(Date(1), 'start', 'day');
dateEnd = dateStart;
if numel(Date) == 2
    dateEnd = dateshift(Date(2), 'start', 'day');
end

if dateEnd < dateStart
    tempDate = dateStart;
    dateStart = dateEnd;
    dateEnd = tempDate;
end

requestedDates = (dateStart:caldays(1):dateEnd)';
end

function cacheFile = getWeatherCacheFilePath()
cacheDir = fileparts(mfilename('fullpath'));
cacheFile = fullfile(cacheDir, 'NOAA_GSOD_weather_cache.mat');
end

function cache = loadWeatherCache(cacheFile)
cache = struct('Date', datetime.empty(0,1), ...
               'Tmin', double.empty(0,1), 'Tmax', double.empty(0,1), 'Tmean', double.empty(0,1), ...
               'SeaLevelPressure', double.empty(0,1), 'StationPressure', double.empty(0,1));

if ~exist(cacheFile, 'file')
    return
end

S = load(cacheFile);
if ~isfield(S, 'cache')
    return
end

requiredFields = {'Date','Tmin','Tmax','Tmean','SeaLevelPressure','StationPressure'};
for i = 1:numel(requiredFields)
    if ~isfield(S.cache, requiredFields{i})
        return
    end
end

cache = S.cache;
if ~isa(cache.Date, 'datetime')
    cache.Date = datetime(cache.Date, 'ConvertFrom', 'datenum');
end
cache.Date = dateshift(cache.Date, 'start', 'day');
end

function [isComplete, Tmin, Tmax, Tmean, seaLevelPressure, stationPressure] = getFromCache(cache, requestedDates)
Tmin = [];
Tmax = [];
Tmean = [];
seaLevelPressure = [];
stationPressure = [];

if isempty(cache.Date)
    isComplete = false;
    return
end

[isMember, idx] = ismember(requestedDates, cache.Date);
isComplete = all(isMember);
if ~isComplete
    return
end

Tmin = cache.Tmin(idx);
Tmax = cache.Tmax(idx);
Tmean = cache.Tmean(idx);
seaLevelPressure = cache.SeaLevelPressure(idx);
stationPressure = cache.StationPressure(idx);
end

function [apiDates, Tmin, Tmax, Tmean, seaLevelPressure, stationPressure] = parseWeatherData(WeatherData)
if isempty(WeatherData)
    apiDates = datetime.empty(0,1);
    Tmin = []; Tmax = []; Tmean = [];
    seaLevelPressure = []; stationPressure = [];
    return
end

% Convert struct array fields to cell arrays to handle varying string lengths
dateStrings = [WeatherData.DATE]; % Assuming DATE is a string array or cell array of strings
apiDates = datetime(dateStrings, 'InputFormat', 'yyyy-MM-dd');

Tmean = [WeatherData.TEMP];
Tmin = [WeatherData.MIN];
Tmax = [WeatherData.MAX];
seaLevelPressure = [WeatherData.SLP];
stationPressure = [WeatherData.STP];

seaLevelPressure = seaLevelPressure * 100; %[Pa]
stationPressure = stationPressure * 100; %[Pa]
end

function cache = mergeWeatherCache(cache, apiDates, Tmin, Tmax, Tmean, seaLevelPressure, stationPressure)
if isempty(apiDates)
    return
end

newRows = table(apiDates(:), Tmin(:), Tmax(:), Tmean(:), seaLevelPressure(:), stationPressure(:), ...
    'VariableNames', {'Date','Tmin','Tmax','Tmean','SeaLevelPressure','StationPressure'});

oldRows = table(cache.Date(:), cache.Tmin(:), cache.Tmax(:), cache.Tmean(:), ...
    cache.SeaLevelPressure(:), cache.StationPressure(:), ...
    'VariableNames', {'Date','Tmin','Tmax','Tmean','SeaLevelPressure','StationPressure'});

allRows = [oldRows; newRows];
[~, uniqueIdx] = unique(allRows.Date, 'last');
allRows = allRows(sort(uniqueIdx), :);
allRows = sortrows(allRows, 'Date');

cache.Date = allRows.Date;
cache.Tmin = allRows.Tmin;
cache.Tmax = allRows.Tmax;
cache.Tmean = allRows.Tmean;
cache.SeaLevelPressure = allRows.SeaLevelPressure;
cache.StationPressure = allRows.StationPressure;
end

function saveWeatherCache(cacheFile, cache)
try
    save(cacheFile, 'cache');
catch ME
    warning('Failed to save weather cache: %s', ME.message);
end
end