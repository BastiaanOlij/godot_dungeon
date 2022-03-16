extends Spatial

const ACCELERATE = 25.0
const DAMPENING = 1.0

var room_scales : PoolRealArray
var room_velocity : PoolRealArray

var make_visible_room : int = 0
var started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	room_scales.resize(16)
	room_velocity.resize(16)
	
	for i in 16:
		var room : Spatial = $Rooms.get_node("Room" + str(i+1))
		room.visible = false
		room.scale = Vector3(0.1, 0.1, 0.1)
		room_scales[i] = 0.1
		room_velocity[i] = 0.0

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and !started:
		started = true
		$Timer.start()
	
	for i in 16:
		var room : Spatial = $Rooms.get_node("Room" + str(i+1))
		if room.visible:
			room_velocity[i] = lerp(room_velocity[i], ACCELERATE * (1.0 - room_scales[i]), delta)
			room_velocity[i] = room_velocity[i] - (DAMPENING * room_velocity[i] * delta)
			
			room_scales[i] = room_scales[i] + (room_velocity[i] * delta)
			room.scale = Vector3(room_scales[i], room_scales[i], room_scales[i])

func _on_Timer_timeout():
	make_visible_room = make_visible_room + 1
	if make_visible_room == 16:
		# we are done
		$Timer.stop()
	
	var room : Spatial = $Rooms.get_node("Room" + str(17- make_visible_room))
	if room:
		room.visible = true
