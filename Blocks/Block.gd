extends Node

var pos = Vector3()
var vertices = []
var uvs = []
var type = 0
var collision_vertices = []

func _ready():
	pass
	
func add_vertice(v):
	vertices.append(v)
	
func add_uv(u):
	uvs.append(u)
	
func set_collision_vertices():
	for v in vertices:
		collision_vertices.append(v)
