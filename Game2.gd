extends Node

onready var fps_label = get_node('fps_label')

func _ready():
	pass
	
func makeCube(pos):
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
	testMesh.set_translation(pos)
	#var meshScene = mesh.instance()
var offz = 0
var offx = 0
var offy = 0


func _process(delta):
	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	var list = []
	if offz<18:
		if offy <18:
			if offx < 18:
				for i in range(6):
					for j in range(6):
						for k in range(6):
							list.append(Vector3(offx+i,offy+j,offz+k))
				offx+=6
			else:
				offy+=6
				offx=0
		else:
			offx = 0
			offy = 0
			offz+=6
	for l in list:
		makeCube(l)
		#build(list)
