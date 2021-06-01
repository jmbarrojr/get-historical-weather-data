# get-historical-weather-data

## Description

This function get historical weather data from NCEI API in MATLAB

This is a simple, proof-of-concept to easily fetch weather data in MATLAB.
The output is set to JSON, and matlab conveniently packs the weather data into a struct datatype, making it easy to handle the data.

For this code, it uses the Global Surface Summary of the Day (GSOD) dataset, and the Naha statation (47936099999) to fetch temperatures and sea level pressure data.
For more information on the dataset, visit <https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/readme.txt>

It should be easy to modify the code to suit other weather data and dataset needs. 
For more infomatio, visit NCEI API website <https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation>

## Usage
```
[Tmin,Tmax,Tmean,seaLevelPressure,stationPressure] = getHistoricalWeatherData(Date)
```
The input `Date` can be a MATLAB date datatype, as e.g.:
```
Date = datetime('today');
```
You can also add a start and end date:
```
Date = [datetime('2020-05-30') datetime('2021-05-30')];
```
