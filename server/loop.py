import time
import subprocess

while True:
    subprocess.call(['python', 'oracles.py'])
    time.sleep(60 * 15)
    # print("end")