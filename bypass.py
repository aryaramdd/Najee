#!/usr/bin/env python3
"""
Delta key bypass wrapper for 300 cloudphone automation.
Uses deltax library (Platoboost v2 API + captcha solving + ad link bypass).
Install: pip install curl_cffi requests pycryptodome cryptography numpy Pillow
Usage:
  python bypass.py <url>                          # single bypass
  python bypass.py <url> --write                  # bypass + write to Delta
  python bypass.py --batch urls.txt               # batch bypass from file
  python bypass.py --batch urls.txt --write       # batch + write to Delta
"""

import sys, os, json, time, threading
from concurrent.futures import ThreadPoolExecutor, as_completed

IMPORT_OK = False
try:
    from deltax import getKey
    IMPORT_OK = True
except ImportError:
    pass

# ── Delta license paths ────────────────────────────────────────────────
DELTA_VARIANTS = [
    "com.roblox.client", "com.roblox.clienu", "com.roblox.clienv",
    "com.roblox.clienw", "com.roblox.clienx", "com.roblox.clieny", "com.roblox.clienz",
]
CACHE_BASE = "/storage/emulated/0/Android/data"
CACHE_REL  = "files/gloop/external/Internals/Cache"
LICENSE_FILE = "license"


def write_key(key):
    written = 0
    for v in DELTA_VARIANTS:
        p = f"{CACHE_BASE}/{v}/{CACHE_REL}/{LICENSE_FILE}"
        if os.path.exists(os.path.dirname(p)):
            try:
                with open(p, 'w') as f:
                    f.write(key)
                written += 1
            except Exception:
                pass
    return written


def save_key(url, key, outfile):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(outfile, 'a') as f:
        f.write(f"[{ts}] {url}\nKEY: {key}\n{'-'*60}\n")


def print_ok(msg):
    sys.stdout.write(f"  \x1b[32m\u2713\x1b[0m {msg}\n")
    sys.stdout.flush()


def print_fail(msg):
    sys.stdout.write(f"  \x1b[31m\u2717\x1b[0m {msg}\n")
    sys.stdout.flush()


def process_url(url, do_write=False, outfile="delta_keys.txt", idx=None, total=None):
    prefix = f"[{idx}/{total}] " if idx else ""
    try:
        sys.stdout.write(f"{prefix}Processing...\n")
        sys.stdout.flush()
        key = getKey(url)
        if key and not key.startswith("bypass fail!"):
            if do_write:
                w = write_key(key)
                print_ok(f"Key: {key[:24]}... | Written to {w} variant(s)")
            else:
                print_ok(f"Key: {key[:24]}...")
            if outfile:
                save_key(url, key, outfile)
            return key
        else:
            print_fail(f"Bypass failed: {key}")
            return None
    except Exception as e:
        print_fail(f"Error: {e}")
        return None


def main():
    if not IMPORT_OK:
        print("\x1b[31mERROR: deltax.py not found or deps missing.\x1b[0m")
        print("Install: pip install curl_cffi requests pycryptodome cryptography numpy Pillow")
        print("Make sure deltax.py is in the same directory.\n")
        sys.exit(1)

    args = sys.argv[1:]
    if not args:
        print(__doc__)
        sys.exit(0)

    do_write = "--write" in args
    batch_file = None
    if "--batch" in args:
        bi = args.index("--batch")
        if bi + 1 < len(args):
            batch_file = args[bi + 1]

    outfile = "delta_keys.txt"

    if batch_file:
        with open(batch_file) as f:
            urls = [l.strip() for l in f if l.strip()]
        print(f"Batch: {len(urls)} URLs\n")

        results = []
        for i, url in enumerate(urls, 1):
            r = process_url(url, do_write, outfile, i, len(urls))
            results.append(r)
            print()

        ok = sum(1 for r in results if r)
        fail = len(results) - ok
        print(f"Done: {ok} ok, {fail} failed")

    else:
        url = [a for a in args if not a.startswith("--")][0]
        process_url(url, do_write, outfile)


if __name__ == "__main__":
    main()
