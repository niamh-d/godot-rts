extends Area2D

@export var cleared_block: PackedScene
@export var new_worker: PackedScene
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var button_tc: Button = $ButtonTC
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var timer_worker: Timer = $TimerWorker
@onready var timer_ui_on: Timer = $TimerUiOn

var worker_cost := 50
var health := 10
var dead := false
var x_val := 0
var y_val := 0

var removed_collision := false
var create := false
var new_id := "0"

var max_num_in_queue := 0
var num_workers_in_queue

func _ready() -> void:
	num_workers_in_queue = max_num_in_queue
	
	var new_pos = cleared_block.instantiate()
	add_child(new_pos)
	if position.x > 0:
		new_pos.position.x -= position.x
	if position.x < 0:
		new_pos.position.x += (position.x * -1)
	if position.y > 0:
		new_pos.position.y -= position.y
	if position.x < 0:
		new_pos.position.y += (position.y * -1)
	
	while new_pos.position.x < (0):
		if new_pos.position.x < (position.x):
			new_pos.position.x += 40
			x_val += 1
	while new_pos.position.x > 40:
		if new_pos.position.x > (position.x):
			new_pos.position.x -= 40
			x_val -= 1
	while new_pos.position.y < (-40):
		if new_pos.position.y < (position.y):
			new_pos.position.y += 40
			y_val += 1
	while new_pos.position.y > (0):
		if new_pos.position.y > (position.y):
			new_pos.position.y -= 40
			y_val -= 1
	
	x_val -= 1
	new_pos.position.y += 20
	new_pos.position.x -= 20
	
	create = true
	
	add_to_group("building")
	add_to_group("town_center")
	new_id = Utils.generate_id(10)
	add_to_group("unit")

func _physics_process(delta: float) -> void:
	if create:
		Global.add_to_no_nav_spot.append(Vector2i(x_val, y_val))
		Global.update_max_pop_count(10)
		create = false
		
	if health <= 0:
		remove()
	
	progress_bar.value = health
	if Global.are_workers_selected && health > 0 || Global.is_building_selected:
		button_tc.visible = false
		canvas_layer.visible = false
	
	if !Global.are_workers_selected && health > 0:
		button_tc.visible = true
	
	if num_workers_in_queue > 0 && timer_worker.is_stopped() && !Global.pop_is_maxed_out():
		timer_worker.start()
	
	var workers: Array[Node] = canvas_layer.get_children()
	
	for w in workers:
		w.visible = false
	for n in range(num_workers_in_queue):
		workers[n].visible = true

func remove():
	if !removed_collision:
		Global.add_nav_spot.append(Vector2i(x_val,y_val))
		remove_from_group("building")
		remove_from_group("town_center")
		Global.update_max_pop_count(-10)
		queue_free()
		removed_collision = true

func kill():
	health = 0

func increment_num_workers_in_queue(amount: int) -> void:
	num_workers_in_queue += amount

func _on_button_remove_pressed() -> void:
	kill()

func sustain_damage(damage: int) -> void:
	health -= damage

func _on_button_add_worker_pressed() -> void:
	if num_workers_in_queue < max_num_in_queue && !Global.pop_is_maxed_out() && Global.get_food_count() >= worker_cost:
		timer_worker.start()
		increment_num_workers_in_queue(1)
		Global.increment_food_count(-worker_cost)

func _on_button_tc_pressed() -> void:
	Global.is_building_selected = true
	timer_ui_on.start()

func _on_timer_worker_timeout() -> void:
	var new_worker_created = new_worker.instantiate()
	add_sibling(new_worker_created)
	new_worker_created.position = position + Vector2(0, 60)
	increment_num_workers_in_queue(-1)
	
	if num_workers_in_queue > 0 && !Global.pop_is_maxed_out():
		timer_worker.start()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_laser"):
		sustain_damage(-1)
		area.queue_free()

func _on_timer_ui_on_timeout() -> void:
	Global.is_building_selected = false
	canvas_layer.visible = true
