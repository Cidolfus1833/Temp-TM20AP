#import ModuleUpdate
#ModuleUpdate.update()
import Utils
from worlds.trackmania2020.Client import launch

if __name__ == "__main__":
    Utils.init_logging("Trackmania2020Client", exception_logger="Client")
    launch()
