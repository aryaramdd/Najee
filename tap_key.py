import os, subprocess, time, json, urllib.request
from PIL import Image
import pytesseract

API_URL = "http://kiiyword.xyz/keyproxy/api/v1/6da40b0f-3893-49d2-8756-d315aea2d890/submit"
LICENSE_PATH = "/storage/emulated/0/Delta/Internals/Cache/license"
DEVICE = "Pixel-8"
DEVICE_ID = "9774d56d682e549c"

def get_clipboard():
    r = subprocess.run(["termux-clipboard-get"], capture_output=True, text=True)
    url = r.stdout.strip()
    return url if url.startswith("http") else None

def tap_key():
    subprocess.run("su -c '/system/bin/screencap -p /sdcard/screen.png'", shell=True)
    if not os.path.getsize("/sdcard/screen.png") > 1000:
        return False
    img = Image.open("/sdcard/screen.png")
    data = pytesseract.image_to_data(img, output_type=pytesseract.Output.DICT)
    for i, word in enumerate(data["text"]):
        w = word.strip().upper()
        if w in ("GET", "RECEIVE") and i + 1 < len(data["text"]):
            if data["text"][i+1].strip().upper() == "KEY":
                x = data["left"][i] + data["width"][i] // 2
                y = data["top"][i] + data["height"][i] // 2
                subprocess.run(["/system/bin/input", "tap", str(x), str(y)])
                print("Tapped ({},{})".format(x, y))
                return True
    return False

def bypass_url(url):
    payload = json.dumps({"link": url, "device": DEVICE, "device_id": DEVICE_ID}).encode()
    req = urllib.request.Request(API_URL, data=payload, headers={"Content-Type": "application/json"})
    try:
        r = urllib.request.urlopen(req, timeout=15)
        data = json.loads(r.read().decode())
        key = data.get("key")
        if key:
            print("Key: {}".format(key[:30]))
            return key
        print("API: {}".format(data.get("message", "unknown")))
    except Exception as e:
        print("Error: {}".format(e))
    return None

def write_license(key):
    subprocess.run("su -c 'mkdir -p {}'".format(os.path.dirname(LICENSE_PATH)), shell=True)
    subprocess.run("su -c 'echo {} > {}'".format(key, LICENSE_PATH), shell=True)
    subprocess.run("su -c 'chmod 644 {}'".format(LICENSE_PATH), shell=True)
    print("License written!")

print("Switch to Delta now! Script starts in 10s...")
time.sleep(10)
print("Running...")
while True:
    url = get_clipboard()
    if url:
        print("URL: {}".format(url))
        key = bypass_url(url)
        if key:
            write_license(key)
        time.sleep(5)
    else:
        tap_key()
    time.sleep(2)
