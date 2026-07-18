import requests, base64, json, sys, os, time
from urllib.parse import urlparse, parse_qs

PLATOBOOST_API = "https://api-gateway.platoboost.com/v1/authenticators/8"
SESSION_API = "https://api-gateway.platoboost.com/v1/sessions/auth/8"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
}

OUTPUT_FILE = r"D:\Roblox Setting\Script\Arya Buat Script\delta_keys.txt"

DELTA_VARIANTS = [
    "com.roblox.client",
    "com.roblox.clienu",
    "com.roblox.clienv",
    "com.roblox.clienw",
    "com.roblox.clienx",
    "com.roblox.clieny",
    "com.roblox.clienz",
]

def get_clipboard():
    try:
        import pyperclip
        return pyperclip.paste()
    except:
        pass
    try:
        import win32clipboard
        win32clipboard.OpenClipboard()
        data = win32clipboard.GetClipboardData()
        win32clipboard.CloseClipboard()
        return data
    except:
        pass
    return input("Paste URL: ").strip()

def set_clipboard(text):
    try:
        import pyperclip
        pyperclip.copy(text)
        return True
    except:
        pass
    try:
        import win32clipboard
        win32clipboard.OpenClipboard()
        win32clipboard.EmptyClipboard()
        win32clipboard.SetClipboardText(text)
        win32clipboard.CloseClipboard()
        return True
    except:
        pass
    print(f"\n[KEY]: {text}")
    return False

def bypass_delta(url):
    parsed = urlparse(url)
    id = parse_qs(parsed.query).get('id', [None])[0]
    if not id:
        d = parse_qs(parsed.query).get('d', [None])[0]
        if not d:
            return {"error": "ID not found in URL"}
        id = d

    # Cek kalo udah ada key
    r = requests.get(f"{PLATOBOOST_API}/{id}", headers=HEADERS)
    data = r.json()
    if 'key' in data:
        return {"key": data['key'], "minutesLeft": data.get('minutesLeft', 0), "cached": True}

    # Create session
    payload = {}
    if data.get('captcha'):
        payload = {"captcha": "turnstile-response", "type": "Turnstile"}

    r = requests.post(f"{SESSION_API}/{id}", json=payload, headers=HEADERS)
    if r.status_code != 200:
        return {"error": f"Session failed: {r.status_code}"}

    # Extract tk dari redirect URL (base64 decode)
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

    # Submit token
    time.sleep(1)
    requests.put(f"{SESSION_API}/{id}/{tk}", headers=HEADERS)

    # Get final key
    time.sleep(0.5)
    r = requests.get(f"{PLATOBOOST_API}/{id}", headers=HEADERS)
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

def save_key(url, result):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(OUTPUT_FILE, 'a') as f:
        f.write(f"[{timestamp}] {url}\n")
        if 'key' in result:
            f.write(f"KEY: {result['key']}  (expires: {result.get('minutesLeft', '?')} min)\n")
        else:
            f.write(f"ERROR: {result.get('error', 'unknown')}\n")
        f.write("-" * 60 + "\n")
    print(f"[SAVED] {OUTPUT_FILE}")

if __name__ == "__main__":
    print("=== Delta Key Bypass ===")

    url = get_clipboard()
    if not url:
        print("No URL found")
        sys.exit(1)

    print(f"[URL] {url}")
    result = bypass_delta(url)

    if 'key' in result:
        key = result['key']
        print(f"[KEY] {key}")
        print(f"[TIME] {result.get('minutesLeft', '?')} minutes remaining")

        set_clipboard(key)
        save_key(url, result)
        written = write_delta_key(key)
        if written:
            print(f"[OK] Written to {written} client variant(s)")
    else:
        print(f"[ERR] {result.get('error', 'Unknown error')}")
