function prefetchHistoricalWeatherCache(yearsBack)
% prefetchHistoricalWeatherCache Preloads Open-Meteo weather cache for a date range.
%
%   prefetchHistoricalWeatherCache()
%   prefetchHistoricalWeatherCache(yearsBack)
%
% Default yearsBack = 8.

if nargin < 1
    yearsBack = 8;
end

if ~isscalar(yearsBack) || yearsBack <= 0
    error('yearsBack must be a positive scalar')
end

endDate = dateshift(datetime('yesterday'), 'start', 'day');
startDate = endDate - calyears(yearsBack);

try
    [~,~,Tmean,SLP,~] = getHistoricalWeatherData([startDate, endDate]);
    if isempty(Tmean) || isempty(SLP)
        warning('Weather cache prefetch did not return data (cache/API unavailable)')
    end
catch ME
    warning('Weather cache prefetch failed: %s', ME.message)
end
end
