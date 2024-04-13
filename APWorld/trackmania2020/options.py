from dataclasses import dataclass

from Options import Toggle, Choice, Range, PerGameCommonOptions, NamedRange


class GameMode(Choice):
    """
    The game mode will make the game vary from the type of map and the ruleset.
    RPG Like: You have 10 random map to complete, but each has a MapPack related to it, you have to complete them too.
    Randomizer: Lot's of random map, but with the help of any teammates (more later).
    Campaign: You select which campaign to use, and you have to complete them (more later)
    """
    internal_name = "gamemode"
    display_name = "Game mode"
    option_RPG_like = 1
    option_Randomizer = 2
    option_Campaign = 3
    default = 1


class AvailableMapsOnStart(Range):
    """
    The number of "free map" that are accessible from the start.
    For mode: RPG, Randomizer.
    """
    internal_name = "maps_on_start"
    display_name = "Available maps on start"
    range_start = 1
    range_end = 5
    default = 3


class GoalPerMaps(NamedRange):
    """
    Compare to the AuthorTime, what do you consider the goal?
    """
    internal_name = "goal_per_maps"
    display_name = "Goal per map"
    range_start = 90
    range_end = 150
    default = 106
    special_range_names = {
        "Champions? 0.95*": 95,
        "0.96*": 96,
        "0.97*": 97,
        "0.98*": 98,
        "0.99*": 99,
        "Author Time 1.00*": 100,
        "1.01*": 101,
        "1.02*": 102,
        "1.03*": 103,
        "1.04*": 104,
        "1.05*": 105,
        "Gold 1.06*": 106,
        "1.07*": 107,
        "1.08*": 108,
        "1.09*": 109,
        "1.10*": 110,
        "Silver 1.20": 120,
        "Bronze 1.50": 150
    }


class UseAutomaticMedalCalculation(Toggle):
    """
    The goal will be calculate using the Automatic Medal calculation when the author do the AT.
    If set to True: Time will be round to the seconds higher.
    If set to False: Time will keep the milliseconds after the Objective calculation
    """
    internal_name = "ceil_to_seconds"
    display_name = "Use Automatic Medal Calculation"
    default = True

@dataclass
class Trackmania2020Options(PerGameCommonOptions):
    gamemode: GameMode
    maps_on_start: AvailableMapsOnStart
    goal_per_maps: GoalPerMaps
    ceil_to_seconds: UseAutomaticMedalCalculation