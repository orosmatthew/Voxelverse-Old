from godot import exposed, export
from godot.bindings import *
from godot.globals import *


@exposed
class Testt(Node):

    # member variables here, example:
    a = export(int)
    b = export(str, default='foo')

    def _ready(self):
        """
        Called every time the node is added to the scene.
        Initialization here.
        """
        pass
