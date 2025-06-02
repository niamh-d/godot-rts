extends Camera2D

var cam_speed := 6
var mini_map_speed = 0.2

var cam_move_right := false
var cam_move_left := false
var cam_move_up := false
var cam_move_down := false

@onready var mini_map_screen: Node2D = %Screen

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	check_mouse_pos_and_set_cam_dirs()
	move_cam()

func check_mouse_pos_and_set_cam_dirs():
	if get_local_mouse_position().x > 540:
		cam_move_right = true
		cam_move_left = false
	if get_local_mouse_position().x < -540:
		cam_move_right = false
		cam_move_left = true
	if get_local_mouse_position().x > -540 && get_local_mouse_position().x < 540:
		cam_move_right = false
		cam_move_left = false

	if get_local_mouse_position().y > 280:
		cam_move_up = false
		cam_move_down = true
	if get_local_mouse_position().y < -280:
		cam_move_up = true
		cam_move_down = false
	if get_local_mouse_position().y > -280 && get_local_mouse_position().y < 280:
		cam_move_up = false
		cam_move_down = false

func move_cam():
	if cam_move_right && position.x <= 1960:
		position += Vector2(1,0) * cam_speed
		mini_map_screen.position += Vector2(1,0) * mini_map_speed
		
	if cam_move_left && position.x >= -860:
		position -= Vector2(1,0) * cam_speed
		mini_map_screen.position -= Vector2(1,0) * mini_map_speed
	
	if cam_move_down && position.y <= 1700:
		position += Vector2(0,1) * cam_speed
		mini_map_screen.position += Vector2(0,1) * mini_map_speed
	
	if cam_move_up && position.y >= -1060:
		position -= Vector2(0,1) * cam_speed
		mini_map_screen.position -= Vector2(0,1) * mini_map_speed
