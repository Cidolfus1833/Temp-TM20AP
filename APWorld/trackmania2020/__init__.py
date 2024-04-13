import random
import string
from BaseClasses import Item, Location, Tutorial, ItemClassification, Region, MultiWorld, LocationProgressType
from Options import StartInventoryPool
from .Items import item_table
# from .Rules import set_rules
from .options import Trackmania2020Options
from .locations import location_table, BASE_ID

from ..AutoWorld import World, WebWorld
from typing import List, Dict, Any
import random
from datetime import datetime

class Trackmania2020WebWorld(WebWorld):
    theme = 'dirt'
    tutorials = [
        Tutorial(
            tutorial_name='Setup Guide',
            description='A guide to playing Trackmania 2020',
            language='English',
            file_name='guide_en.md',
            link='guide/en',
            authors=['Cidolfus1833']
    )]


class Trackmania2020Item(Item):
    game: str = "Trackmania2020"


class Trackmania2020Location(Location):
    game: str = "Trackmania2020"


class Trackmania2020World(World):
    """
    An arcade racing game
    """
    game = "Trackmania 2020"
    data_version = 1
    web = Trackmania2020WebWorld()
    options_dataclass = Trackmania2020Options
    options: Trackmania2020Options
    topology_present = False
    item_name_to_id = item_table
    item_id_to_name = item_table
    location_name_to_id = location_table
    location_id_to_name = location_table


    # location_name_to_id = {loc["name"]: loc["mapid"] for loc in location_table}
    # location_id_to_name = {loc["mapid"]: loc["name"] for loc in location_table}

    # location_name_to_id = {loc["name"]: loc["mapid"] for loc in location_table}
    # location_id_to_name = {loc["mapid"]: loc["name"] for loc in location_table}

    # def create_items(self):
    #    self.multiworld.push_precollected(self.create_item( item_name_to_id[0] ))

    def create_item(self, name: str, id: int, itmclass: ItemClassification) -> Trackmania2020Item:
        # Locations and Items are the same
        return Trackmania2020Item(name, itmclass, id, self.player)

    def create_items(self) -> None:
        # self.multiworld.random.shuffle(location_table)
        keys = list(item_table.keys())
        random.shuffle(keys)
        ndx = 1
        for key in keys:
            value = item_table[key]
            item = self.create_item(key, value, ItemClassification.progression)
            if ndx <= self.options.maps_on_start:
                # self.multiworld.push_precollected(item)
                self.multiworld.precollected_items[item.player].append(item)
                self.multiworld.state.collect(item, True)
            else:
                self.multiworld.itempool.append(item)
            ndx = ndx + 1

        # for i in range(self.options.maps_on_start):
        #    item = self.multiworld.itempool[i]
        #    # self.multiworld.push_precollected(item)
        #    self.multiworld.precollected_items[item.player].append(item)
        #    self.multiworld.state.collect(item, True)

#    def generate_early(self) -> None:
#        self.create_regions()
#        self.create_items()

    def create_regions(self) -> None:
        version1 = 2
        totalItems = len(item_table)
        regionMenu = Region("Menu", self.player, self.multiworld)
        self.multiworld.regions.append(regionMenu)
        if version1 == 2:
            mainCup = Region("MainCup", self.player, self.multiworld)
            for i in range(1, totalItems - self.options.maps_on_start + 1):  # start at 1, should finish at qty+1
                loc = Trackmania2020Location(self.player, "AP-Main-" + str(i), i + BASE_ID, mainCup)
                mainCup.locations.append(loc)
                # self.location_id_to_name[i] = "AP-Main-" + str(i)
                # self.location_name_to_id["AP-Main-" + str(i)] = i
            regionMenu.connect(mainCup, "MainCup")
            self.multiworld.regions.append(mainCup)

    def connect(self: MultiWorld,world: MultiWorld, player: int, source: str, target: str):
        sourceRegion = world.get_region(source, player)
        targetRegion = world.get_region(target, player)
        sourceRegion.connect(targetRegion, rule=lambda state: True)


    def fill_slot_data(self) -> Dict[str, Any]:
        options_dict = self.options.as_dict("gamemode", "maps_on_start", "goal_per_maps",
                                            "ceil_to_seconds",
                                            casing="camel")
        return {
            **options_dict,
            "seed": "".join(self.random.choice(string.digits) for _ in range(16))
        }
