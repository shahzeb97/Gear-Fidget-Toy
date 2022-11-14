extends RigidBody

export var impulse_strength = 0.5
export var density = 1.0
var initial_transform

# Get Child Nodes and save them in variables
onready var GearMesh = $GearMesh

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_transform = get_global_transform()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	# var maxpos = OS.get_real_window_size().y * 0.9
	if event is InputEventScreenDrag:
		var maxlimit = get_viewport().get_size().y * 0.75 
		print(maxlimit)
		print(event.get_position())
		if event.get_position().y < maxlimit:
			var drag_vector = event.get_relative()
			var drag_vector_3D = Vector3(drag_vector.x, -drag_vector.y, 0)
			var torque_axis = drag_vector_3D.cross(Vector3(0,0,-1)).normalized()
			apply_torque_impulse(torque_axis * 0.1)


func _on_N_slider_value_changed(value):
	# Set the singleton value
	set_angular_velocity(Vector3(0,0,0))
	GearVariables.N = value
	GearMesh.remake()

func _on_P_slider_value_changed(value):
	# Set the singleton value
	set_angular_velocity(Vector3(0,0,0))
	GearVariables.P = value
	GearMesh.remake()

func _on_t_slider_value_changed(value:float):
	# Set the singleton value
	set_angular_velocity(Vector3(0,0,0))
	GearVariables.t = value
	GearMesh.remake()

func _on_phi_slider_value_changed(value:float):
	# Set the singleton value
	set_angular_velocity(Vector3(0,0,0))
	GearVariables.phi = value
	GearMesh.remake()

func _on_ResetButton_pressed():
	set_transform(initial_transform)
	set_angular_velocity(Vector3(0,0,0))
	pass # Replace with function body.


func _on_StopButton_pressed():
	set_angular_velocity(Vector3(0,0,0))
	pass # Replace with function body.

func _on_SpinButton_pressed():
	var spin_vector = get_global_transform().basis.y
	apply_torque_impulse(spin_vector)
	pass # Replace with function body.
