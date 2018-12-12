extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var count = 0
onready var cubeScene = preload("res://Cube.tscn")
onready var thread = Thread.new()
var placeQueue = []

func _ready():
	pass
"""
func instanceThing(x,y,z):
"""
	

func place(x,y,z):
	var testMesh = MeshInstance.new()
	var mesh = Mesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#left
	st.add_vertex(Vector3(0,0,0))
	st.add_vertex(Vector3(0,1,0))
	st.add_vertex(Vector3(0,0,1))
	st.add_vertex(Vector3(0,1,1))
	st.add_vertex(Vector3(0,0,1))
	st.add_vertex(Vector3(0,1,0))
	#right
	st.add_vertex(Vector3(1,0,0))
	st.add_vertex(Vector3(1,0,1))
	st.add_vertex(Vector3(1,1,0))
	st.add_vertex(Vector3(1,1,1))
	st.add_vertex(Vector3(1,1,0))
	st.add_vertex(Vector3(1,0,1))
	#back
	st.add_vertex(Vector3(0,0,0))
	st.add_vertex(Vector3(1,0,0))
	st.add_vertex(Vector3(0,1,0))
	st.add_vertex(Vector3(1,1,0))
	st.add_vertex(Vector3(0,1,0))
	st.add_vertex(Vector3(1,0,0))
	#front
	st.add_vertex(Vector3(0,0,1))
	st.add_vertex(Vector3(0,1,1))
	st.add_vertex(Vector3(1,0,1))
	st.add_vertex(Vector3(1,1,1))
	st.add_vertex(Vector3(1,0,1))
	st.add_vertex(Vector3(0,1,1))
	#bottom
	st.add_vertex(Vector3(0,0,0))
	st.add_vertex(Vector3(0,0,1))
	st.add_vertex(Vector3(1,0,0))
	st.add_vertex(Vector3(1,0,1))
	st.add_vertex(Vector3(1,0,0))
	st.add_vertex(Vector3(0,0,1))
	#top
	st.add_vertex(Vector3(0,1,0))
	st.add_vertex(Vector3(1,1,0))
	st.add_vertex(Vector3(0,1,1))
	st.add_vertex(Vector3(1,1,1))
	st.add_vertex(Vector3(0,1,1))
	st.add_vertex(Vector3(1,1,0))

	st.index()
	st.generate_normals()
	
	st.commit(mesh)
	
	testMesh.set_mesh(mesh)
	testMesh.set_name("testMesh")
	self.add_child(testMesh)
	testMesh.set_translation(Vector3(x,y,z))
	#var cube = cubeScene.instance()
	#self.call_deferred("add_child", cube)

	#self.add_child(testMesh)
	testMesh.set_name(str(str(x)+" "+str(y)+" "+str(z)))
	count+=1


	
func delete(x,y,z):

	get_node(str(str(x)+" "+str(y)+" "+str(z))).free()
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
