# from .data.mappack import MAPPACK_JSON
import json
import pkgutil

# item_table = {
#    "164080": 164080,
#    "164081": 164081,
#    "164082": 164082,
#    "164083": 164083,
#    "164084": 164084,
#    "164085": 164085,
#    "164086": 164086,
#    "164087": 164087,
#    "164088": 164088,
#    "164089": 164089
# }

BASE_ID = 183300000

MAPPACK_JSON = pkgutil.get_data(__name__, f"data/mappack.json").decode("utf-8")
Spring2024 = json.loads(MAPPACK_JSON)

lst = [item['mapid'] for item in Spring2024[0]["Maps"]]

item_table = {}
mapid = 0
for kv in lst:
    item_table[str(kv)] = mapid + BASE_ID
    mapid += 1
