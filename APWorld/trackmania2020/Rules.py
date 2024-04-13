from BaseClasses import MultiWorld
from ..AutoWorld import LogicMixin
from ..generic.Rules import set_rule


class Trackmania2020Logic(LogicMixin):
    def _trackmania2020_location_is_accessible(self, player_id, items_required):
        return sum(self.prog_items[player_id].values()) >= items_required


# def set_rules(world: MultiWorld, player: int):
#     for i in range(1, 100):
#         set_rule(
#             world.get_location(f"{i}", player)
#         )