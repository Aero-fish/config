#!/bin/python3
import glob
import logging
import os
import re
import pathlib

logging.basicConfig(format="[%(levelname)s]%(module)s.%(funcName)s: %(message)s")

FILENAME_PATTERN = r"""[^_]*_(?P<year>[0-9]+)-(?P<month>[0-9]+)-(?P<day>[0-9]+)_(?P<hours>[0-9]+)-(?P<minutes>[0-9]+)-(?P<seconds>[0-9]+)-(?P<micro_seconds>[0-9]+).*"""


def main() -> int:

    # Glob png in the yuzu directory
    # directory = os.path.dirname(os.path.realpath(__file__)) + "/yuzu"
    directory = str(pathlib.Path.home()) + "/Pictures/yuzu"
    ext = "png"

    for file_path in glob.glob(os.path.join(directory, f"*.{ext}")):
        file_name = os.path.basename(file_path)

        # Extract information from file name
        match = re.match(FILENAME_PATTERN, file_name)
        if match:
            date = f"{match.group('year')}-{match.group('month')}-{match.group('day')}"

            time = (
                f"{match.group('hours')}_{match.group('minutes')}_"
                + f"{match.group('seconds')}."
                + f"{int(int(match.group('micro_seconds'))/10):02}"
            )

        else:
            logging.warning(
                f"'{file_name}' does not match the predefined file name pattern"
            )
            continue
        print(file_name, " to ", f"{date} {time}")
        os.rename(f"{directory}/{file_name}", f"{directory}/{date} {time}.{ext}")

    return 0


if __name__ == "__main__":
    main()
