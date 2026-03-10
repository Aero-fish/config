#!/usr/bin/python3
import json
import requests
from datetime import datetime
import math
# import pickle


# WWO_CODE = {
#     "113": "Sunny",
#     "116": "PartlyCloudy",
#     "119": "Cloudy",
#     "122": "VeryCloudy",
#     "143": "Fog",
#     "176": "LightShowers",
#     "179": "LightSleetShowers",
#     "182": "LightSleet",
#     "185": "LightSleet",
#     "200": "ThunderyShowers",
#     "227": "LightSnow",
#     "230": "HeavySnow",
#     "248": "Fog",
#     "260": "Fog",
#     "263": "LightShowers",
#     "266": "LightRain",
#     "281": "LightSleet",
#     "284": "LightSleet",
#     "293": "LightRain",
#     "296": "LightRain",
#     "299": "HeavyShowers",
#     "302": "HeavyRain",
#     "305": "HeavyShowers",
#     "308": "HeavyRain",
#     "311": "LightSleet",
#     "314": "LightSleet",
#     "317": "LightSleet",
#     "320": "LightSnow",
#     "323": "LightSnowShowers",
#     "326": "LightSnowShowers",
#     "329": "HeavySnow",
#     "332": "HeavySnow",
#     "335": "HeavySnowShowers",
#     "338": "HeavySnow",
#     "350": "LightSleet",
#     "353": "LightShowers",
#     "356": "HeavyShowers",
#     "359": "HeavyRain",
#     "362": "LightSleetShowers",
#     "365": "LightSleetShowers",
#     "368": "LightSnowShowers",
#     "371": "HeavySnowShowers",
#     "374": "LightSleetShowers",
#     "377": "LightSleet",
#     "386": "ThunderyShowers",
#     "389": "ThunderyHeavyRain",
#     "392": "ThunderySnowShowers",
#     "395": "HeavySnowShowers",
# }

# WEATHER_SYMBOL = {
#     "Unknown":             "✨",
#     "Cloudy":              "☁️",
#     "Fog":                 "🌫",
#     "HeavyRain":           "🌧",
#     "HeavyShowers":        "🌧",
#     "HeavySnow":           "❄️",
#     "HeavySnowShowers":    "❄️",
#     "LightRain":           "🌦",
#     "LightShowers":        "🌦",
#     "LightSleet":          "🌧",
#     "LightSleetShowers":   "🌧",
#     "LightSnow":           "🌨",
#     "LightSnowShowers":    "🌨",
#     "PartlyCloudy":        "⛅️",
#     "Sunny":               "☀️",
#     "ThunderyHeavyRain":   "🌩",
#     "ThunderyShowers":     "⛈",
#     "ThunderySnowShowers": "⛈",
#     "VeryCloudy": "☁️",
# }

# WEATHER_SYMBOL_WI_DAY = {
#     "Unknown":             "",
#     "Cloudy":              "",
#     "Fog":                 "",
#     "HeavyRain":           "",
#     "HeavyShowers":        "",
#     "HeavySnow":           "",
#     "HeavySnowShowers":    "",
#     "LightRain":           "",
#     "LightShowers":        "",
#     "LightSleet":          "",
#     "LightSleetShowers":   "",
#     "LightSnow":           "",
#     "LightSnowShowers":    "",
#     "PartlyCloudy":        "",
#     "Sunny":               "",
#     "ThunderyHeavyRain":   "",
#     "ThunderyShowers":     "",
#     "ThunderySnowShowers": "",
#     "VeryCloudy": "",
# }


# WIND_DIRECTION = [
#     "↓",
#     "↙",
#     "←",
#     "↖",
#     "↑",
#     "↗",
#     "→",
#     "↘",
# ]

# WIND_DIRECTION_WI = [
#     "", "", "", "", "", "", "", "",
# ]

# WIND_SCALE_WI = [
#     "", "", "", "", "", "", "", "", "", "", "", "", "",
# ]

# MOON_PHASES = ("🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘")

# MOON_PHASES_WI = (
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
#     "",
# )

# WEATHER_SYMBOL_WEGO = {
#     "Unknown": [
#         "    .-.      ",
#         "     __)     ",
#         "    (        ",
#         "     `-’     ",
#         "      •      "],
#     "Sunny": [
#         "\033[38;5;226m    \\   /    \033[0m",
#         "\033[38;5;226m     .-.     \033[0m",
#         "\033[38;5;226m  ― (   ) ―  \033[0m",
#         "\033[38;5;226m     `-’     \033[0m",
#         "\033[38;5;226m    /   \\    \033[0m"],
#     "PartlyCloudy": [
#         "\033[38;5;226m   \\  /\033[0m      ",
#         "\033[38;5;226m _ /\"\"\033[38;5;250m.-.    \033[0m",
#         "\033[38;5;226m   \\_\033[38;5;250m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;250m(___(__) \033[0m",
#         "             "],
#     "Cloudy": [
#         "             ",
#         "\033[38;5;250m     .--.    \033[0m",
#         "\033[38;5;250m  .-(    ).  \033[0m",
#         "\033[38;5;250m (___.__)__) \033[0m",
#         "             "],
#     "VeryCloudy": [
#         "             ",
#         "\033[38;5;240;1m     .--.    \033[0m",
#         "\033[38;5;240;1m  .-(    ).  \033[0m",
#         "\033[38;5;240;1m (___.__)__) \033[0m",
#         "             "],
#     "LightShowers": [
#         "\033[38;5;226m _`/\"\"\033[38;5;250m.-.    \033[0m",
#         "\033[38;5;226m  ,\\_\033[38;5;250m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;250m(___(__) \033[0m",
#         "\033[38;5;111m     ‘ ‘ ‘ ‘ \033[0m",
#         "\033[38;5;111m    ‘ ‘ ‘ ‘  \033[0m"],
#     "HeavyShowers": [
#         "\033[38;5;226m _`/\"\"\033[38;5;240;1m.-.    \033[0m",
#         "\033[38;5;226m  ,\\_\033[38;5;240;1m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;240;1m(___(__) \033[0m",
#         "\033[38;5;21;1m   ‚‘‚‘‚‘‚‘  \033[0m",
#         "\033[38;5;21;1m   ‚’‚’‚’‚’  \033[0m"],
#     "LightSnowShowers": [
#         "\033[38;5;226m _`/\"\"\033[38;5;250m.-.    \033[0m",
#         "\033[38;5;226m  ,\\_\033[38;5;250m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;250m(___(__) \033[0m",
#         "\033[38;5;255m     *  *  * \033[0m",
#         "\033[38;5;255m    *  *  *  \033[0m"],
#     "HeavySnowShowers": [
#         "\033[38;5;226m _`/\"\"\033[38;5;240;1m.-.    \033[0m",
#         "\033[38;5;226m  ,\\_\033[38;5;240;1m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;240;1m(___(__) \033[0m",
#         "\033[38;5;255;1m    * * * *  \033[0m",
#         "\033[38;5;255;1m   * * * *   \033[0m"],
#     "LightSleetShowers": [
#         "\033[38;5;226m _`/\"\"\033[38;5;250m.-.    \033[0m",
#         "\033[38;5;226m  ,\\_\033[38;5;250m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;250m(___(__) \033[0m",
#         "\033[38;5;111m     ‘ \033[38;5;255m*\033[38;5;111m ‘ \033[38;5;255m* \033[0m",
#         "\033[38;5;255m    *\033[38;5;111m ‘ \033[38;5;255m*\033[38;5;111m ‘  \033[0m"],
#     "ThunderyShowers": [
#         "\033[38;5;226m _`/\"\"\033[38;5;250m.-.    \033[0m",
#         "\033[38;5;226m  ,\\_\033[38;5;250m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;250m(___(__) \033[0m",
#         "\033[38;5;228;5m    ⚡\033[38;5;111;25m‘ ‘\033[38;5;228;5m⚡\033[38;5;111;25m‘ ‘ \033[0m",
#         "\033[38;5;111m    ‘ ‘ ‘ ‘  \033[0m"],
#     "ThunderyHeavyRain": [
#         "\033[38;5;240;1m     .-.     \033[0m",
#         "\033[38;5;240;1m    (   ).   \033[0m",
#         "\033[38;5;240;1m   (___(__)  \033[0m",
#         "\033[38;5;21;1m  ‚‘\033[38;5;228;5m⚡\033[38;5;21;25m‘‚\033[38;5;228;5m⚡\033[38;5;21;25m‚‘ \033[0m",
#         "\033[38;5;21;1m  ‚’‚’\033[38;5;228;5m⚡\033[38;5;21;25m’‚’  \033[0m"],
#     "ThunderySnowShowers": [
#         "\033[38;5;226m _`/\"\"\033[38;5;250m.-.    \033[0m",
#         "\033[38;5;226m  ,\\_\033[38;5;250m(   ).  \033[0m",
#         "\033[38;5;226m   /\033[38;5;250m(___(__) \033[0m",
#         "\033[38;5;255m     *\033[38;5;228;5m⚡\033[38;5;255;25m*\033[38;5;228;5m⚡\033[38;5;255;25m* \033[0m",
#         "\033[38;5;255m    *  *  *  \033[0m"],
#     "LightRain": [
#         "\033[38;5;250m     .-.     \033[0m",
#         "\033[38;5;250m    (   ).   \033[0m",
#         "\033[38;5;250m   (___(__)  \033[0m",
#         "\033[38;5;111m    ‘ ‘ ‘ ‘  \033[0m",
#         "\033[38;5;111m   ‘ ‘ ‘ ‘   \033[0m"],
#     "HeavyRain": [
#         "\033[38;5;240;1m     .-.     \033[0m",
#         "\033[38;5;240;1m    (   ).   \033[0m",
#         "\033[38;5;240;1m   (___(__)  \033[0m",
#         "\033[38;5;21;1m  ‚‘‚‘‚‘‚‘   \033[0m",
#         "\033[38;5;21;1m  ‚’‚’‚’‚’   \033[0m"],
#     "LightSnow": [
#         "\033[38;5;250m     .-.     \033[0m",
#         "\033[38;5;250m    (   ).   \033[0m",
#         "\033[38;5;250m   (___(__)  \033[0m",
#         "\033[38;5;255m    *  *  *  \033[0m",
#         "\033[38;5;255m   *  *  *   \033[0m"],
#     "HeavySnow": [
#         "\033[38;5;240;1m     .-.     \033[0m",
#         "\033[38;5;240;1m    (   ).   \033[0m",
#         "\033[38;5;240;1m   (___(__)  \033[0m",
#         "\033[38;5;255;1m   * * * *   \033[0m",
#         "\033[38;5;255;1m  * * * *    \033[0m"],
#     "LightSleet": [
#         "\033[38;5;250m     .-.     \033[0m",
#         "\033[38;5;250m    (   ).   \033[0m",
#         "\033[38;5;250m   (___(__)  \033[0m",
#         "\033[38;5;111m    ‘ \033[38;5;255m*\033[38;5;111m ‘ \033[38;5;255m*  \033[0m",
#         "\033[38;5;255m   *\033[38;5;111m ‘ \033[38;5;255m*\033[38;5;111m ‘   \033[0m"],
#     "Fog": [
#         "             ",
#         "\033[38;5;251m _ - _ - _ - \033[0m",
#         "\033[38;5;251m  _ - _ - _  \033[0m",
#         "\033[38;5;251m _ - _ - _ - \033[0m",
#         "             "],
# }

WEATHER_CODES_EMOJI = {
    "113": "☀️",
    "116": "⛅️",
    "119": "☁️",
    "122": "☁️",
    "143": "🌫",
    "176": "🌦",
    "179": "🌧",
    "182": "🌧",
    "185": "🌧",
    "200": "⛈",
    "227": "🌨",
    "230": "❄️",
    "248": "🌫",
    "260": "🌫",
    "263": "🌦",
    "266": "🌦",
    "281": "🌧",
    "284": "🌧",
    "293": "🌦",
    "296": "🌦",
    "299": "🌧",
    "302": "🌧",
    "305": "🌧",
    "308": "🌧",
    "311": "🌧",
    "314": "🌧",
    "317": "🌧",
    "320": "🌨",
    "323": "🌨",
    "326": "🌨",
    "329": "❄️",
    "332": "❄️",
    "335": "❄️",
    "338": "❄️",
    "350": "🌧",
    "353": "🌦",
    "356": "🌧",
    "359": "🌧",
    "362": "🌧",
    "365": "🌧",
    "368": "🌨",
    "371": "❄️",
    "374": "🌧",
    "377": "🌧",
    "386": "⛈",
    "389": "🌩",
    "392": "⛈",
    "395": "❄️",
}

# WEATHER_CODES_ICON_FONT = {
#     "113": "",
#     "116": "",
#     "119": "",
#     "122": "",
#     "143": "",
#     "176": "",
#     "179": "",
#     "182": "",
#     "185": "",
#     "200": "",
#     "227": "",
#     "230": "",
#     "248": "",
#     "260": "",
#     "263": "",
#     "266": "",
#     "281": "",
#     "284": "",
#     "293": "",
#     "296": "",
#     "299": "",
#     "302": "",
#     "305": "",
#     "308": "",
#     "311": "",
#     "314": "",
#     "317": "",
#     "320": "",
#     "323": "",
#     "326": "",
#     "329": "",
#     "332": "",
#     "335": "",
#     "338": "",
#     "350": "",
#     "353": "",
#     "356": "",
#     "359": "",
#     "362": "",
#     "365": "",
#     "368": "",
#     "371": "",
#     "374": "",
#     "377": "",
#     "386": "",
#     "389": "",
#     "392": "",
#     "395": "",
# }

# WIND_SCALE = {
#     0: "1",
#     1: "2",
#     2: "3",
#     3: "4",
#     4: "5",
#     5: "6",
#     6: "7",
#     7: "8",
#     8: "9",
#     9: "10",
#     10: "11",
#     11: "12",
#     12: "13",
#     13: "14",
# }

TEMPERATURE_SCALE = {
    0: "",
    1: "",
    2: "",
    3: "",
    4: "",
}

TIME = {
    0: "",
    1: "",
    2: "",
    3: ""
}

THIN_SPACE=" "

def get_temperature_icon(temperature: int):
    if temperature < 12:
        return TEMPERATURE_SCALE.get(0)
    elif temperature < 18:
        return TEMPERATURE_SCALE.get(1)
    elif temperature < 24:
        return TEMPERATURE_SCALE.get(2)
    elif temperature < 30:
        return TEMPERATURE_SCALE.get(3)
    else:
        return TEMPERATURE_SCALE.get(4)


def get_wind_scale_icon(wind_speed: int):
    if wind_speed < 1:
        return 1
    elif wind_speed < 5:
        return 2
    elif wind_speed < 11:
        return 3
    elif wind_speed < 19:
        return 4
    elif wind_speed < 28:
        return 5
    elif wind_speed < 38:
        return 6
    elif wind_speed < 49:
        return 7
    elif wind_speed < 61:
        return 8
    elif wind_speed < 74:
        return 9
    elif wind_speed < 88:
        return 10
    elif wind_speed < 102:
        return 11
    elif wind_speed < 117:
        return 12
    elif wind_speed < 132:
        return 13
    else:
        return 14


# def get_moon_icon(moon_percentage: float):
#     number_of_icons = len(MOON_PHASES_WI)
#     index = int(math.floor(moon_percentage * 1.0 / 28.0 * 8 + 0.5)) % number_of_icons
#     return MOON_PHASES_WI[index]

def main():

    data = {}
    try:
        weather = requests.get("https://wttr.in/?format=j1").json()
    except:
        data["tooltip"] = "Cannot reach 'wttr.in'"
        data["text"] = "??℃"
        print(json.dumps(data))
        return 0
    # weather = requests.get("https://wttr.in/Pakuranga?format=j1").json()

    # with open("weather.pickle", "wb") as f:
    #     pickle.dump(weather, f)

    # with open("weather.pickle", "rb") as f:
    #     weather = pickle.load(f)

    city = weather.get("nearest_area")[0].get("areaName")[0].get("value")
    country = weather.get("nearest_area")[0].get("country")[0].get("value")

    def format_time(time):
        return time.replace("00", "").zfill(2)

    def format_temp(temp):
        return (hour["FeelsLikeC"] + "℃").ljust(3)

    def format_chances(hour):
        chances = {
            "chanceoffog": "Fog",
            "chanceoffrost": "Frost",
            "chanceofovercast": "Overcast",
            "chanceofrain": "Rain",
            "chanceofsnow": "Snow",
            "chanceofsunshine": "Sunshine",
            "chanceofthunder": "Thunder",
            "chanceofwindy": "Wind",
        }

        conditions = []
        for event in chances.keys():
            if int(hour[event]) > 0:
                conditions.append(chances[event] + " " + hour[event] + "%")
        return ", ".join(conditions)

    # Waybar text
    data["text"] = f"{weather['current_condition'][0]['FeelsLikeC']}℃"

    # Tooltips
    # city, country
    data["tooltip"] = f'<span size="x-large" weight="bold">{city}, {country}</span>\n'

    # Current condition
    air_temperature = weather["current_condition"][0]["temp_C"]
    wind_speed: int = weather["current_condition"][0]["windspeedKmph"]

    data["tooltip"] += " ".join(
        [
            f"{WEATHER_CODES_EMOJI[weather['current_condition'][0]['weatherCode']]}",
            f"{weather['current_condition'][0]['weatherDesc'][0]['value']}",
            f"{get_temperature_icon(float(air_temperature))}{air_temperature}℃",
            f"{weather['current_condition'][0]['humidity']}%",
            f"{wind_speed}km/h {weather['current_condition'][0]['winddir16Point']} {get_wind_scale_icon(float(wind_speed))}\n",
        ]
    )

    # 3-days forecast
    for i, day in enumerate(weather["weather"]):
        # moon_percentage = day["astronomy"][0]["moon_illumination"]

        # Date
        data["tooltip"] += f"\n<b>"
        if i == 0:
            data["tooltip"] += "Today, "
        if i == 1:
            data["tooltip"] += "Tomorrow, "
        data["tooltip"] += f"{day['date']}</b>\n"

        # Overview
        data["tooltip"] += " ".join(
            [
                f"{day['astronomy'][0]['sunrise'].replace(' ', '')}",
                f"{day['astronomy'][0]['sunset'].replace(' ', '')}",
                # f" {day['maxtempC']}℃ {day['mintempC']}℃",
                f"{day['astronomy'][0]['moon_phase']}\n",
            ]
        )

        # Hourly forecast
        for hour in day["hourly"]:
            if i == 0:
                if int(format_time(hour["time"])) < datetime.now().hour - 2:
                    continue

            time = format_time(hour['time'])
            data["tooltip"] += " ".join(
                [
                    f"{TIME[int(time) % 4]}{time}",
                    # f"{get_temperature_icon(float(hour['FeelsLikeC']))}{format_temp(hour['FeelsLikeC'])}",
                    # f"{hour['humidity'].zfill(2)}%",
                    # f"{get_wind_scale_icon(float(hour['windspeedKmph']))}",
                    # f"{hour['windspeedKmph'].zfill(2)}km/h",
                    f"{WEATHER_CODES_EMOJI[hour['weatherCode']]}{format_temp(hour['FeelsLikeC'])}",
                    f"{hour['weatherDesc'][0]['value']}, {format_chances(hour)}\n",
                ]
            )
    # print(data.get("text"))
    # print()
    # print(data.get("tooltip"))
    print(json.dumps(data))

if __name__ == "__main__":
    main()
