from asyncio import subprocess
from dotenv import load_dotenv
from os.path import join, dirname
import os
import requests
from random import randint
import subprocess

dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

contract="0x033c33e6756c59831ee773996c09090a16d68298cc3f1b65f9949672c7783b7f"

weatherAPI = os.environ.get("WEATHER_API")
coords = {
    'singapore': [1, 103],
    'monument valley': [37, 110]
}

# https://openweathermap.org/current

query = f'https://api.openweathermap.org/data/2.5/weather?lat={coords["singapore"][0]}&lon={coords["singapore"][1]}&appid={weatherAPI}&units=metric'
print(query)
print('-----request-----')
response = requests.get(query)
jsonresponse = response.json()
# print(jsonresponse)
weather_id = jsonresponse["weather"][0]["id"]
print(f'main: {weather_id}')
print(f'temperature deg: {jsonresponse["main"]["temp"]}')
print(f'humidity %: {jsonresponse["main"]["humidity"]}')
print(f'visibility m: {jsonresponse["visibility"]}')
print(f'wind speed m/s: {jsonresponse["wind"]["speed"]}')
print(f'wind deg: {jsonresponse["wind"]["deg"]}')
print(f'cloud cover %: {jsonresponse["clouds"]["all"]}')
# print(f'rain vol 1h: {jsonresponse["rain"]["1h"]}')
# print(f'snow vol 1h: {jsonresponse["snow"]["1h"]}')


randomint = randint(0, 1206167596222043737899107594365023368541035738443865566657697352045290673496)
print(randomint)


# call starknet contract with weather data and 
dirname = os.path.dirname(os.path.realpath(__file__))
# print(dirname)
weather_exec = os.path.join(dirname, 'weather.sh')
random_exec = os.path.join(dirname, 'random.sh')
# all_exec = os.path.join(dirname, 'all.sh')
all_exec = "root/redline-alpha/server/all.sh"

# update all
all_proc = subprocess.Popen([all_exec, contract, str(randomint), str(weather_id)])
all_proc.wait()
print("done")

# update weather
# weather_proc = subprocess.Popen([weather_exec, str(weather_id), contract])
# weather_proc.wait()

# update random
# random_proc = subprocess.Popen([random_exec, str(randomint), contract])
# random_proc.wait()
