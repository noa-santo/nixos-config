import gi
gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib
from gi.repository.Playerctl import Player
from collections import deque
import argparse
import logging
import sys
import signal
import gi
import json
import os

logger = logging.getLogger(__name__)

def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    # loop.quit()
    sys.exit(0)


class PlayerManager:
    def __init__(self, selected_player=None, excluded_player=[]):
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()
        self.manager.connect(
            "name-appeared", lambda *args: self.on_player_appeared(*args))
        self.manager.connect(
            "player-vanished", lambda *args: self.on_player_vanished(*args))

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
        self.selected_player = selected_player
        self.excluded_player = excluded_player.split(',') if excluded_player else []
        self.scroll_id = None
        self.title_deque = deque()
        self.artist_deque = deque()
        self.icon_ref = ""
        self.current_player_ref = None

        self.init_players()

    def init_players(self):
        for player in self.manager.props.player_names:
            if player.name in self.excluded_player:
                continue
            if self.selected_player is not None and self.selected_player != player.name:
                logger.debug(f"{player.name} is not the filtered player, skipping it")
                continue
            self.init_player(player)

    def run(self):
        logger.info("Starting main loop")
        self.loop.run()

    def init_player(self, player):
        logger.info(f"Initialize new player: {player.name}")
        player = Playerctl.Player.new_from_name(player)
        player.connect("playback-status",
                       self.on_playback_status_changed, None)
        player.connect("metadata", self.on_metadata_changed, None)
        self.manager.manage_player(player)
        self.on_metadata_changed(player, player.props.metadata)

    def get_players(self) -> list[Player]:
        return self.manager.props.players

    def write_output(self, text, player):
        logger.debug(f"Writing output: {text}")

        output = {"text": text,
                  "class": "custom-" + player.props.player_name,
                  "alt": player.props.player_name}

        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        sys.stdout.write("\n")
        sys.stdout.flush()

    def on_playback_status_changed(self, player, status, _=None):
        logger.debug(f"Playback status changed for player {player.props.player_name}: {status}")
        self.on_metadata_changed(player, player.props.metadata)

    def get_first_playing_player(self):
        players = self.get_players()
        logger.debug(f"Getting first playing player from {len(players)} players")
        if len(players) > 0:
            # if any are playing, show the first one that is playing
            # reverse order, so that the most recently added ones are preferred
            for player in players[::-1]:
                if player.props.status == "Playing":
                    return player
            # if none are playing, show the first one
            return players[0]
        else:
            logger.debug("No players found")
            return None

    def show_most_important_player(self):
        logger.debug("Showing most important player")
        # show the currently playing player
        # or else show the first paused player
        # or else show nothing
        current_player = self.get_first_playing_player()
        if current_player is not None:
            self.on_metadata_changed(current_player, current_player.props.metadata)
        else:
            self.clear_output()

    def do_scroll(self):
        if len(self.artist_deque) > len(self.title_deque):
            self.artist_deque.rotate(-1)
        elif len(self.title_deque) > len(self.artist_deque):
            self.title_deque.rotate(-1)

        title_str = "".join(self.title_deque)
        artist_str = "".join(self.artist_deque)
        self.write_output(f"{self.icon_ref}{title_str} - {artist_str}", self.current_player_ref)
        return True

    def on_metadata_changed(self, player, metadata, _=None):
        logger.debug(f"Metadata changed for player {player.props.player_name}")
        if self.scroll_id is not None:
            GLib.source_remove(self.scroll_id)
            self.scroll_id = None

        player_name = player.props.player_name
        artist = player.get_artist() or ""
        title = player.get_title() or ""

        if player_name == "spotify" and "mpris:trackid" in metadata.keys() and ":ad:" in player.props.metadata["mpris:trackid"]:
            self.write_output("Advertisement", player)
            return

        track_info = ""
        if artist and title:
            track_info = f"{title} - {artist}"
        else:
            track_info = title or artist

        icon = "   " if player.props.status == "Playing" else "   "

        # only print output if no other player is playing
        current_playing = self.get_first_playing_player()
        if current_playing is None or current_playing.props.player_name == player_name:
            if len(track_info) > 40 and artist and title:
                if len(artist) > len(title):
                    self.artist_deque = deque(artist.ljust(len(artist) + 5))
                    self.title_deque = deque(title)
                else:
                    self.title_deque = deque(title.ljust(len(title) + 5))
                    self.artist_deque = deque(artist)
                self.current_player_ref = player
                self.icon_ref = icon
                self.scroll_id = GLib.timeout_add(200, self.do_scroll)
            else:
                if track_info:
                    self.write_output(f"{icon}{track_info}", player)
                else:
                    self.clear_output()

    def on_player_appeared(self, _, player):
        logger.info(f"Player has appeared: {player.name}")
        if player.name in self.excluded_player:
            logger.debug(
                "New player appeared, but it's in exclude player list, skipping")
            return
        if player is not None and (self.selected_player is None or player.name == self.selected_player):
            self.init_player(player)
        else:
            logger.debug(
                "New player appeared, but it's not the selected player, skipping")

    def on_player_vanished(self, _, player):
        logger.info(f"Player {player.props.player_name} has vanished")
        self.show_most_important_player()

def parse_arguments():
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded player")
    parser.add_argument("--player")
    parser.add_argument("--enable-logging", action="store_true")
    return parser.parse_args()

def main():
    arguments = parse_arguments()

    # Initialize logging
    if arguments.enable_logging:
        logfile = os.path.join(os.path.dirname(
            os.path.realpath(__file__)), "media-player.log")
        logging.basicConfig(filename=logfile, level=logging.DEBUG,
                            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s")

    # Logging is set by default to WARN and higher.
    # With every occurrence of -v it's lowered by one
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    logger.info("Creating player manager")
    if arguments.player:
        logger.info(f"Filtering for player: {arguments.player}")
    if arguments.exclude:
        logger.info(f"Exclude player {arguments.exclude}")

    player = PlayerManager(arguments.player, arguments.exclude)
    player.run()


if __name__ == "__main__":
    main()
