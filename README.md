# get-historical-weather-data

Fetch historical daily weather data directly into MATLAB — no manual downloads, no spreadsheets,
no fuss. One function call returns temperature and pressure records for any date range you need.

## How it works

`getHistoricalWeatherData` queries the free [Open-Meteo Archive API](https://open-meteo.com/en/docs/historical-weather-api)
and returns daily min, max, and mean temperature, along with sea-level and station pressure.
Results are cached locally so repeated calls for the same dates are instant.

By default the function is configured for **Okinawa, Japan** (lat: 26.3358, lon: 127.8014),
but it is easy to point it at any location — just update the latitude and longitude constants
inside `getWeatherDataFromService`.

## Usage

```matlab
[Tmin, Tmax, Tmean, seaLevelPressure, stationPressure] = getHistoricalWeatherData(Date)
```

| Output | Units | Description |
|---|---|---|
| `Tmin` | °C | Daily minimum temperature |
| `Tmax` | °C | Daily maximum temperature |
| `Tmean` | °C | Daily mean temperature |
| `seaLevelPressure` | Pa | Mean sea-level pressure |
| `stationPressure` | Pa | Mean surface pressure |

### Single day

```matlab
[Tmin, Tmax, Tmean, SLP, STP] = getHistoricalWeatherData(datetime('today'));
```

### Date range

```matlab
startDate = datetime('2020-05-30');
endDate   = datetime('2021-05-30');
[Tmin, Tmax, Tmean, SLP, STP] = getHistoricalWeatherData([startDate, endDate]);
```

## Requirements

- MATLAB with `webread` available (R2014b+)
- Internet access for dates not yet in the local cache

## Author

Julio Barros — 2021
