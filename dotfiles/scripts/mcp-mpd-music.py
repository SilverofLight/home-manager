#!/home/silver/.conda/envs/qwen/bin/python3
"""
MPD MCP Server - Control MPD music player through MPC commands
"""

import asyncio
import subprocess
import json
from typing import List, Dict, Any, Optional

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import (
    Resource,
    Tool,
    TextContent,
    ImageContent,
    EmbeddedResource,
    LoggingLevel,
)


class MPDMCPError(Exception):
    """MCP service exception"""
    pass


def run_mpc_command(command: List[str]) -> tuple[str, str, int]:
    """Execute MPC command and return stdout, stderr, and return code"""
    try:
        result = subprocess.run(
            ["mpc"] + command,
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except subprocess.TimeoutExpired:
        raise MPDMCPError("MPC command execution timeout")
    except FileNotFoundError:
        raise MPDMCPError("mpc command not found, please install mpc")


def get_mpd_host_config() -> List[str]:
    """Get MPD host configuration from environment variables or config file"""
    import os
    host = os.environ.get("MPD_HOST")
    port = os.environ.get("MPD_PORT")
    
    args = []
    if host:
        args.extend(["--host", host])
    if port:
        args.extend(["--port", port])
    return args


# Create MCP server instance
app = Server("mpd-mcp-server")


@app.list_resources()
async def list_resources() -> list[Resource]:
    """List available resources"""
    return [
        Resource(
            uri="mpd://status",
            name="MPD Playback Status",
            description="Current playback status information of MPD player",
            mimeType="application/json",
        )
    ]


@app.read_resource()
async def read_resource(uri: str) -> str:
    """Read resource"""
    if uri == "mpd://status":
        stdout, stderr, code = run_mpc_command(get_mpd_host_config() + ["status"])
        if code != 0:
            return json.dumps({"error": stderr or "Unable to get MPD status"})
        
        # Parse status information
        status = {}
        for line in stdout.split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                status[key.strip().lower()] = value.strip()
        
        return json.dumps(status, ensure_ascii=False, indent=2)
    
    raise ValueError(f"Unknown resource: {uri}")


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List all available tools"""
    return [
        Tool(
            name="list_mpd_playlists",
            description="Get all playlists in MPD",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
        Tool(
            name="add_playlist_to_queue",
            description="Add a playlist to the playback queue",
            inputSchema={
                "type": "object",
                "properties": {
                    "playlist_name": {
                        "type": "string",
                        "description": "Playlist name (obtained from list_mpd_playlists)"
                    }
                },
                "required": ["playlist_name"]
            }
        ),
        Tool(
            name="list_queue",
            description="Get all music in the current playback queue",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
        Tool(
            name="toggle",
            description="Toggle play/pause state",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
        Tool(
            name="play_specific_music",
            description="Play a specific music from the queue based on list_queue results",
            inputSchema={
                "type": "object",
                "properties": {
                    "position": {
                        "type": "integer",
                        "description": "Music position in queue (1-indexed, obtained from list_queue)"
                    }
                },
                "required": ["position"]
            }
        ),
        Tool(
            name="clear_queue",
            description="Clear the current playback queue",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
        Tool(
            name="next_track",
            description="Play next track",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
        Tool(
            name="previous_track",
            description="Play previous track",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
    ]


@app.call_tool()
async def call_tool(
    name: str, 
    arguments: dict[str, Any] | None
) -> list[TextContent | ImageContent | EmbeddedResource]:
    """Call tool"""
    
    if name == "list_mpd_playlists":
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(host_config + ["lsplaylists"])
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to get playlists'}")]
            
            playlists = [p.strip() for p in stdout.split('\n') if p.strip()]
            
            if not playlists:
                return [TextContent(type="text", text="No playlists found")]
            
            result = "Available playlists:\n" + "\n".join([f"- {p}" for p in playlists])
            return [TextContent(type="text", text=result)]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    elif name == "add_playlist_to_queue":
        if not arguments or "playlist_name" not in arguments:
            return [TextContent(type="text", text="Error: playlist_name parameter required")]
        
        playlist_name = arguments["playlist_name"]
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(
                host_config + ["load", playlist_name]
            )
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to load playlist'}")]
            
            # Get queue information
            stdout, _, _ = run_mpc_command(host_config + ["playlist"])
            tracks = [t.strip() for t in stdout.split('\n') if t.strip()]
            
            return [TextContent(
                type="text", 
                text=f"Successfully loaded playlist '{playlist_name}', added {len(tracks)} tracks to queue"
            )]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    elif name == "list_queue":
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(host_config + ["playlist"])
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to get playback queue'}")]
            
            tracks = [t.strip() for t in stdout.split('\n') if t.strip()]
            
            if not tracks:
                return [TextContent(type="text", text="Playback queue is empty")]
            
            # Get current playback status
            status_stdout, _, _ = run_mpc_command(host_config + ["status"])
            current_pos = None
            for line in status_stdout.split('\n'):
                if line.startswith('[playing]') or line.startswith('[paused]'):
                    # Parse current track position
                    parts = line.split('#', 1)
                    if len(parts) > 1:
                        pos_part = parts[1].split('/')[0].strip()
                        try:
                            current_pos = int(pos_part)
                        except ValueError:
                            pass
            
            result = "Current playback queue:\n"
            for i, track in enumerate(tracks, 1):
                marker = "▶️ " if current_pos == i else "  "
                result += f"{marker}{i}. {track}\n"
            
            return [TextContent(type="text", text=result)]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    elif name == "toggle":
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(host_config + ["toggle"])
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to toggle playback state'}")]
            
            # Get new status
            status_stdout, _, _ = run_mpc_command(host_config + ["status"])
            state = "Unknown"
            for line in status_stdout.split('\n'):
                if line.startswith('[playing]'):
                    state = "Playing"
                    break
                elif line.startswith('[paused]'):
                    state = "Paused"
                    break
            
            return [TextContent(type="text", text=f"Toggle successful, current state: {state}")]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    elif name == "play_specific_music":
        if not arguments or "position" not in arguments:
            return [TextContent(type="text", text="Error: position parameter required")]
        
        try:
            position = int(arguments["position"])
            if position < 1:
                return [TextContent(type="text", text="Error: position must be a positive integer")]
        except ValueError:
            return [TextContent(type="text", text="Error: position must be a valid integer")]
        
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(
                host_config + ["play", str(position)]
            )
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to play specified music'}")]
            
            # Get playback information
            stdout, _, _ = run_mpc_command(host_config + ["current"])
            current_track = stdout.strip() if stdout.strip() else "Unknown track"
            
            return [TextContent(
                type="text", 
                text=f"Now playing: {current_track}"
            )]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    elif name == "clear_queue":
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(host_config + ["clear"])
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to clear queue'}")]
            
            return [TextContent(type="text", text="Playback queue cleared")]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    elif name == "next_track":
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(host_config + ["next"])
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to switch to next track'}")]
            
            stdout, _, _ = run_mpc_command(host_config + ["current"])
            current_track = stdout.strip() if stdout.strip() else "Unknown track"
            
            return [TextContent(type="text", text=f"Next: {current_track}")]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    elif name == "previous_track":
        try:
            host_config = get_mpd_host_config()
            stdout, stderr, code = run_mpc_command(host_config + ["prev"])
            
            if code != 0:
                return [TextContent(type="text", text=f"Error: {stderr or 'Unable to switch to previous track'}")]
            
            stdout, _, _ = run_mpc_command(host_config + ["current"])
            current_track = stdout.strip() if stdout.strip() else "Unknown track"
            
            return [TextContent(type="text", text=f"Previous: {current_track}")]
            
        except MPDMCPError as e:
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    else:
        raise ValueError(f"Unknown tool: {name}")


async def main():
    """Start MCP server"""
    # Check if mpc is available
    try:
        run_mpc_command(["version"])
    except MPDMCPError as e:
        print(f"Error: {e}")
        print("\nPlease ensure mpc (Music Player Client) is installed:")
        print("  Debian/Ubuntu: sudo apt-get install mpc")
        print("  macOS: brew install mpc")
        print("  And MPD server is running")
        return
    
    async with stdio_server() as streams:
        await app.run(
            streams[0],
            streams[1],
            app.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())
