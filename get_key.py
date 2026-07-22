import subprocess, time, json, urllib.request

API_URL = "http://kiiyword.xyz/keyproxy/api/v1/6da40b0f-3893-49d2-8756-d315aea2d890/submit"
LICENSE_PATH = "/storage/emulated/0/Delta/Internals/Cache/license"
DEVICE = "Pixel-8"
DEVICE_ID = "9774d56d682e549c"

def get_clipboard():
    r = subprocess.run(["termux-clipboard-get"], capture_output=True, text=True)
    return r.stdout.strip()

def bypass(url):
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

print("Waiting for clipboard URL...")
while True:
    url = get_clipboard()
    if url.startswith("http"):
        print("URL: {}".format(url))
        key = bypass(url)
        if key:
            write_license(key)
            print("Done! Next...")
        time.sleep(3)
    time.sleep(1)
