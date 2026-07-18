import requests, base64, json, sys, os, time
from urllib.parse import urlparse, parse_qs

PLATOBOOST_API = "https://api-gateway.platoboost.com/v1/authenticators/8"
SESSION_API = "https://api-gateway.platoboost.com/v1/sessions/auth/8"

HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}

DELTA_VARIANTS = [
    "com.roblox.client", "com.roblox.clienu", "com.roblox.clienv",
    "com.roblox.clienw", "com.roblox.clienx", "com.roblox.clieny", "com.roblox.clienz",
]

def bypass_delta(url):
    parsed = urlparse(url)
    pid = parse_qs(parsed.query).get('id', [None])[0]
    if not pid:
        d = parse_qs(parsed.query).get('d', [None])[0]
        if not d:
            return {"error": "ID not found in URL"}
        pid = d

    r = requests.get(f"{PLATOBOOST_API}/{pid}", headers=HEADERS)
    data = r.json()
    if 'key' in data:
        return {"key": data['key'], "minutesLeft": data.get('minutesLeft', 0), "cached": True}

    payload = {}
    if data.get('captcha'):
        payload = {"captcha": "turnstile-response", "type": "Turnstile"}

    r = requests.post(f"{SESSION_API}/{pid}", json=payload, headers=HEADERS)
    if r.status_code != 200:
        return {"error": f"Session failed: {r.status_code}"}

    redirect = r.json().get('redirect', '')
    if not redirect:
        return {"error": "No redirect URL"}

    decoded = requests.utils.unquote(redirect)
    r_param = parse_qs(urlparse(decoded).query).get('r', [None])[0]
    if not r_param:
        return {"error": "No r param"}

    tk_url = base64.b64decode(r_param).decode('utf-8')
    tk = parse_qs(urlparse(tk_url).query).get('tk', [None])[0]
    if not tk:
        return {"error": "No tk param"}

    time.sleep(1)
    requests.put(f"{SESSION_API}/{pid}/{tk}", headers=HEADERS)

    time.sleep(0.5)
    r = requests.get(f"{PLATOBOOST_API}/{pid}", headers=HEADERS)
    result = r.json()

    if 'key' in result:
        return {"key": result['key'], "minutesLeft": result.get('minutesLeft', 0), "cached": False}
    return {"error": "Key not found in response"}

def write_delta_key(key):
    written = 0
    for variant in DELTA_VARIANTS:
        path = f"/storage/emulated/0/Android/data/{variant}/files/gloop/external/Internals/Cache/license"
        if os.path.exists(os.path.dirname(path)):
            try:
                with open(path, 'w') as f:
                    f.write(key)
                print(f"[WRITE] {path}")
                written += 1
            except Exception as e:
                print(f"[FAIL] {path}: {e}")
    return written

if __name__ == "__main__":
    print("=== Delta Key Bypass (Termux) ===")
    url = input("Paste URL: ").strip()
    if not url:
        print("No URL")
        sys.exit(1)

    print(f"\n[URL] {url}")
    result = bypass_delta(url)

    if 'key' in result:
        key = result['key']
        print(f"\n[KEY] {key}")
        print(f"[TIME] {result.get('minutesLeft', '?')} minutes")

        print("\nWriting to Delta variants...")
        written = write_delta_key(key)
        print(f"[OK] Written to {written} client variant(s)")
    else:
        print(f"\n[ERR] {result.get('error', 'Unknown')}")
