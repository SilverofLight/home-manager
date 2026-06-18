import os
import re
import subprocess
import sys


def get_mpc_output(command):
    """Runs an mpc command and returns its stdout, or None on error."""
    try:
        # Run command, ensure it completes successfully (check=True)
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True,
            encoding='utf-8'
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Suppress errors like 'mpc is not running' or 'command not found'
        print("")
        return None


def main():
    """
    Finds and prints the current lyric for the song playing in MPC.
    """
    # 1. Get the current song title from MPC.
    song_name = get_mpc_output(['mpc', 'current', '--format', '%title%'])
    if not song_name:
        # Silently exit if no song is playing, mimicking the original script's behavior.
        print("")
        sys.exit(0)

    # 2. Construct the path to the corresponding lyrics file.
    lyrics_file_path = os.path.join(
        os.path.expanduser('~'), 'Music', 'lyrics', f'{song_name}.lrc'
    )
    if not os.path.isfile(lyrics_file_path):
        print("lyrics file not found", file=sys.stderr)
        print("")
        sys.exit(0)

    # 3. Get the current playback time from MPC status.
    mpc_status = get_mpc_output(['mpc', 'status'])
    if not mpc_status:
        print("")
        sys.exit(0)

    # Exit silently if MPC is paused.
    if '[paused]' in mpc_status:
        print("")
        sys.exit(0)

    current_total_seconds = -1
    # The second line of 'mpc status' contains timing info.
    if len(mpc_status.split('\n')) > 1:
        time_line = mpc_status.split('\n')[1]
        # Extract the current time, e.g., '0:45' from '0:45/3:30'.
        match = re.search(r'(\d+):(\d+)/(\d+:\d+)', time_line)
        if match:
            minutes, seconds = map(int, match.groups()[:2])
            current_total_seconds = minutes * 60 + seconds

    if current_total_seconds == -1:
        # Exit if time could not be parsed.
        print("")
        sys.exit(0)

    # 4. Parse the LRC file to find the current lyric.
    max_time = -1
    current_lyric = ""

    try:
        with open(lyrics_file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                # The actual lyric text is what remains after removing timestamps.
                clean_text = re.sub(r'\[.*?\]', '', line).strip()
                if not clean_text:
                    continue

                # A single line can have multiple timestamps, e.g., [00:10.50][01:15.00]Lyric
                for match in re.finditer(r'\[(\d+):(\d+)\.?\d*\]', line):
                    minutes, seconds = map(int, match.groups())
                    timestamp_seconds = minutes * 60 + seconds

                    # We want the latest lyric that has already started.
                    if timestamp_seconds <= current_total_seconds and timestamp_seconds > max_time:
                        max_time = timestamp_seconds
                        current_lyric = clean_text
    except IOError as e:
        print(f"Error reading lyrics file: {e}", file=sys.stderr)
        sys.exit(0)

    # 5. Print the found lyric to standard output.
    if current_lyric:
        print(current_lyric)


if __name__ == "__main__":
    main()
