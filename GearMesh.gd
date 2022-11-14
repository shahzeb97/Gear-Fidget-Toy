tool
extends MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	remake()
	pass

func remake(N:float=GearVariables.N, P:float=GearVariables.P , phi:float=GearVariables.phi , t:float=GearVariables.t):
	# Clear Exsisting Meshes
	mesh.clear_surfaces()

	# Start Making New One
	var surface_array= []
	surface_array.resize(Mesh.ARRAY_MAX)

	var verts = PoolVector3Array()
	var normals = PoolVector3Array()

	# Calculate other gear parameters
	var phir = deg2rad(phi)	# [rad] Pressure angle in radians
	var D = N / P					# [m] Pitch diameter - diameter of the pitch circle, imaginary point of contact between gears
	var D_a = (N + 2)/P				# [m] Addendum diameter - diameter of the circle that touches the outside of the tooth at the top
	var D_d = (N - 2.5)/P				# [m] Dedendum diameter - diameter of the circle that touches the outside of the tooth at the bottom
	var p = D * PI / N				# [m] Circular Pitch - distance between two adjacent teeth
	# var N_min = 4 * x / ( (2*x + 1) * pow( sin(phir) , 2) ) # Calculate minimum number of teeth on this gear to prevent interference

	# Gear Parameters just for modelling
	var r_a = D_a/2					# [m] Radius of the addendum circle
	var r_d = D_d/2					# [m] Radius of the dedendum circle
	var h = r_a - r_d				# [m] Height of the tooth
	var e = h * sin(phir) 			# [m] Tooth width difference between dedendum and addendum circles
	var s_d = p/4 + e/2				# [m] half tooth thickness at the dedendum circle
	var s_a = p/4 - e/2				# [m] half tooth thickness at the addendum circle
	var theta_d = atan(s_d/r_d)		# [rad] angle to point 1
	var theta_a = atan(s_a/r_a)		# [rad] angle to point 3
	var theta_tooth = 2 * PI / N - theta_d # [rad] angle to point 5
	var th = t / 2					# [m] half gear thickness
	
	# Generate Gear Face
	# Define basic vectors which will be used to define the gear
	var p0 = Vector3(0,0,0)
	var ph = Vector3(0,th, 0)
	var pl = Vector3(0,-th, 0)
	var upvec = Vector3(0, 1, 0) 		# [m] Vector pointing up for normals on top side
	var downvec = Vector3(0, -1, 0) 	# [m] Vector pointing down for normals on bottom side
	
	# Fundamental vectors for the gear
	var p1 = r_d * Vector3( cos(theta_d), 0, sin(theta_d))
	var p2 = r_d * Vector3( cos(-theta_d), 0, sin(-theta_d))
	var p3 = r_a * Vector3( cos(theta_a), 0, sin(theta_a))
	var p4 = r_a * Vector3( cos(-theta_a), 0, sin(-theta_a))
	var p5 = r_d * Vector3( cos(theta_tooth), 0, sin(theta_tooth))

	# Fundamental Faces of the Gear
	var f1 = [p0, p2, p1]
	var f2 = [p1, p2, p3]
	var f3 = [p2, p4, p3]
	var f4 = [p0, p1, p5]

	# Initialize the unit array
	var unit_verts = PoolVector3Array()
	var unit_normals = PoolVector3Array()

	# Fill in the faces in a loop to save code
	for y in [th, -th]:
		var p_offset = Vector3(0, y, 0)
		for f in [f1, f2, f3, f4]:
			if y == th:
				unit_normals.append_array(PoolVector3Array([upvec, upvec, upvec]))
			else:
				unit_normals.append_array(PoolVector3Array([downvec, downvec, downvec]))
				f.invert()
			for v in f:
				unit_verts.append(v + p_offset)
	
	# Fill in the edges. Define fundamental faces and duplicate
	var s1 = [p2+ph, p2 +pl, p4+ph]
	var s2 = [p4+ph, p2+pl, p4+pl]
	var s3 = [p4+pl, p3+ph, p4+ph]
	var s4 = [p4+pl, p3+pl, p3+ph]
	var s5 = [p3+ph, p3+pl, p1+ph]
	var s6 = [p3+pl, p1+pl, p1+ph]
	var s7 = [p1+ph, p1+pl, p5+ph]
	var s8 = [p1+pl, p5+pl, p5+ph]

	for s in [s1, s2, s3, s4, s5, s6, s7, s8]:
		var dir1 = s[1] - s[0]
		var dir2 = s[2] - s[0]
		var normal = dir1.cross(dir2)
		for v in s:
			unit_verts.append(v)
			unit_normals.append(normal)

		
	# Generate a PoolVector3Array of Faces
	var base_angle = 2 * PI / N 		# [rad] Angle between two adjacent teeth
	for i in range(N):
		var ai = base_angle * i
		for v in unit_verts:
			var newv = v.rotated(upvec, ai)
			verts.append(newv)
		
		for n in unit_normals:
			var newn = n.rotated(upvec, ai)
			normals.append(newn)


	# Assign arrays to mesh array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_NORMAL] = normals
	
	# Create the Mesh.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
