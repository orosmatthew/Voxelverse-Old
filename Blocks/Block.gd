extends Node

var pos = Vector3()
var vertices = []
var UVs = []
var collisionVertices = []

func _ready():
	pass
	
func addVertice(v):
	vertices.append(v)
	
func addUV(u):
	UVs.append(u)
	
func setCollisionVertices():
	for v in vertices:
		collisionVertices.append(v)
