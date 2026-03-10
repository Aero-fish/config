#!/bin/python3
from typing import Tuple
from urllib import request
import contextlib
import datetime
import glob
import json
import logging
import os
import re
import subprocess
import sys

WALLPAPER_DIR = "".join([os.path.expandvars("$HOME"), "/misc/BingWallpaper"])

DATE_FMT = "%Y%m%d"

logging.basicConfig(format="%(levelname)s: %(message)s", level=logging.INFO)


def set_wallpaper():
    glob_path = "".join([WALLPAPER_DIR, "/*.jpg"])
    downloaded_wallpaper = glob.glob(glob_path)
    downloaded_wallpaper.sort()
    wallpaper_path = downloaded_wallpaper[-1]

    if sys.platform.startswith("win32"):
        cmd = (
            "REG ADD \"HKCU\\Control Panel\\Desktop\" /v Wallpaper /t REG_SZ /d \"%s\" /f"
            % wallpaper_path
        )
        os.system(cmd)
        os.system("rundll32.exe user32.dll, UpdatePerUserSystemParameters")
        logging.info("Wallpaper is set.")
    elif sys.platform.startswith("linux"):
        os.system(
            f'if [ ! -f "$XDG_RUNTIME_DIR/wayland_wallpaper" ] || [ "$(readlink -f "$XDG_RUNTIME_DIR/wayland_wallpaper")" != "$(readlink -f {wallpaper_path})" ]; then systemctl --user restart swaybg.service; fi'
        )

        logging.info("Wallpaper is set.")
    else:
        logging.warning("OS not supported.")
        return
    return


def download_old_wallpapers(minus_days=False):
    """Uses download_wallpaper(set_wallpaper=False) to download the last 20 wallpapers.
    If minus_days is given an integer a specific day in the past will be downloaded.
    """
    if minus_days:
        download_wallpaper(idx=minus_days, use_wallpaper=False)
        return
    for i in range(0, 20):  # max 20
        download_wallpaper(idx=i, use_wallpaper=False)


def get_latest_wallpaper_date_and_url() -> Tuple[str, str]:
    """Get the date and URL of the latest Bing wallpaper.

    Returns:
        Tuple[str, str]: ("Date in %Y%m%d", "URL")
    """
    url = "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"
    with contextlib.closing(request.urlopen(url)) as usock:
        response = json.load(usock).get("images")[0]

    url = f"http://www.bing.com{response.get('url')}"
    url = re.sub("_[0-9]+x[0-9]+", "_UHD", url)
    return response.get("startdate"), url


def download_wallpaper(num_of_new_wallpaper=0, use_wallpaper=True):
    if not os.path.exists(WALLPAPER_DIR):
        os.makedirs(WALLPAPER_DIR)

    url = f"http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n={num_of_new_wallpaper}&mkt=en-US"

    with contextlib.closing(request.urlopen(url)) as usock:
        response = json.load(usock).get("images")

    for img in response:
        date = img.get("startdate")
        url = f"http://www.bing.com{img.get('url')}"
        url = re.sub("_[0-9]+x[0-9]+", "_UHD", url)

        # Get file name from URL
        regex = "^http://www\\.bing\\.com/.*?\\.(.*?(?=\\.jpg)).*"

        match = re.search(regex, url)
        if match:
            filename = match.group(1)
        else:
            filename = "Unknown"

        output_path = "".join([WALLPAPER_DIR, "/", date, "-", filename, ".jpg"])
        if os.path.exists(output_path):
            logging.warning(f"Image already exists: {output_path}")
            continue

        request.urlretrieve(url, output_path)
        logging.info(f"Downloaded: {output_path}")


def check_number_of_new_wallpapers() -> int:
    """Check how many new Bing wallpapers are available.

    Returns:
        int: Number of new wallpapers.
    """
    glob_path = "".join([WALLPAPER_DIR, "/*.jpg"])
    downloaded_wallpaper = glob.glob(glob_path)
    downloaded_wallpaper.sort()

    regex = "^(.*/)?([0-9]+).*"
    match = re.search(regex, downloaded_wallpaper[-1])
    last_download_date = None
    if match:
        last_download_date = match.group(2)
    else:
        logging.error(
            "Unable to detect last download date from existing images.\n"
            f"Last image path: {downloaded_wallpaper[-1]}\n"
        )

        exit(1)

    last_download_date = datetime.datetime.strptime(last_download_date, DATE_FMT).date()
    lastest_bing_wallpaper_date, _ = get_latest_wallpaper_date_and_url()
    lastest_bing_wallpaper_date = datetime.datetime.strptime(
        lastest_bing_wallpaper_date, DATE_FMT
    ).date()
    return (lastest_bing_wallpaper_date - last_download_date).days


if __name__ == "__main__":
    try:
        try:
            with contextlib.closing(
                request.urlopen("https://www.google.com/")
            ) as usock:
                has_internet = True
        except:
            has_internet = False

        if has_internet:
            num_of_new_wallpaper = check_number_of_new_wallpapers()
            logging.info(f"New wallpaper: {num_of_new_wallpaper}")

            if num_of_new_wallpaper > 0:
                download_wallpaper(
                    num_of_new_wallpaper=num_of_new_wallpaper, use_wallpaper=True
                )

        set_wallpaper()

    except Exception:
        # os.system("notify-send -t 10000 -u critical 'Bing wallpaper download failed.'")
        raise
