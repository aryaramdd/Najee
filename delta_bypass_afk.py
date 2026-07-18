import requests, base64, json, sys, os, time, subprocess
from urllib.parse import urlparse, parse_qs

PLATOBOOST_API = "https://api-gateway.platoboost.com/v1/authenticators/8"
SESSION_API = "https://api-gateway.platoboost.com/v1/sessions/auth/8"
HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}

DELTA_VARIANTS = [
    "com.roblox.client", "com.roblox.clienu", "com.roblox.clienv",
    "com.roblox.clienw", "com.roblox.clienx", "com.roblox.clieny", "com.roblox.clienz",
]
LICENSE_FILE = "license"
CACHE_BASE = "/storage/emulated/0/Android/data"
CACHE_REL = "files/gloop/external/Internals/Cache"

def get_clipboard():
    try:
        return subprocess.run(["termux-clipboard-get"], capture_output=True, text=True).stdout.strip()
    except:
        return None

def is_delta_url(text):
    return "auth.platorelay.com" in text or "platoboost" in text or (
        "http" in text and ("id=" in text or "d=" in text)
    )

def write_delta_key(key):
    written = 0
    for variant in DELTA_VARIANTS:
        path = f"{CACHE_BASE}/{variant}/{CACHE_REL}/{LICENSE_FILE}"
        if os.path.exists(os.path.dirname(path)):
            try:
                with open(path, 'w') as f:
                    f.write(key)
                print(f"  [WRITE] {variant}")
                written += 1
            except:
                pass
    return written

def bypass(url):
    parsed = urlparse(url)
    pid = parse_qs(parsed.query).get('id', [None])[0]
    if not pid:
        pid = parse_qs(parsed.query).get('d', [None])[0]
    if not pid:
        return None

    r = requests.get(f"{PLATOBOOST_API}/{pid}", headers=HEADERS)
    data = r.json()
    if 'key' in data:
        return data['key']

    payload = {}
    if data.get('captcha'):
        payload = {"captcha": "turnstile-response", "type": "Turnstile"}

    r = requests.post(f"{SESSION_API}/{pid}", json=payload, headers=HEADERS)
    if r.status_code != 200:
        return None

    redirect = r.json().get('redirect', '')
    if not redirect:
        return None

    decoded = requests.utils.unquote(redirect)
    r_param = parse_qs(urlparse(decoded).query).get('r', [None])[0]
    if not r_param:
        return None

    tk_url = base64.b64decode(r_param).decode('utf-8')
    tk = parse_qs(urlparse(tk_url).query).get('tk', [None])[0]
    if not tk:
        return None

    time.sleep(1)
    requests.put(f"{SESSION_API}/{pid}/{tk}", headers=HEADERS)
    time.sleep(0.5)
    r = requests.get(f"{PLATOBOOST_API}/{pid}", headers=HEADERS)
    result = r.json()
    return result.get('key')

if __name__ == "__main__":
    print("=== Delta AFK Bypass ===")
    print("Monitoring clipboard every 3s...\n")
    last = ""

    while True:
        clip = get_clipboard()
        if clip and clip != last and is_delta_url(clip):
            print(f"[DETECT] {clip[:60]}...")
            try:
                key = bypass(clip)
                if key:
                    print(f"[KEY] {key}")
                    w = write_delta_key(key)
                    print(f"[OK] Written to {w} variant(s)")
                else:
                    print("[FAIL] Bypass error")
            except Exception as e:
                print(f"[FAIL] {e}")
            last = clip
        time.sleep(3)
