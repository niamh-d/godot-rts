extends Node

var add_nav_spot = PackedVector2Array()
var add_to_nav_spot = PackedVector2Array()
var workers_selected := false
var building_selected := false

var food_count := 1200
var gold_count := 1200
var wood_count := 1200
var pop_count := 0
var max_pop_count := 0

var new_worker_target = null
var new_worker_target_type = null
var new_worker_target_job = null
var new_worker_target_id = null

var enemy_units = 0
var good_units = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func get_gold_count():
	return gold_count

func increment_gold_count(amount: int):
	var new_val = gold_count + amount
	gold_count = new_val if new_val >= 0 else 0

func get_wood_count():
	return wood_count

func increment_wood_count(amount: int):
	var new_val = wood_count + amount
	wood_count = new_val if new_val >= 0 else 0

func reset_all_vars():
	add_nav_spot = PackedVector2Array()
	add_to_nav_spot = PackedVector2Array()
	workers_selected = false
	building_selected = false

	food_count = 1200
	gold_count = 1200
	wood_count = 1200
	pop_count = 0
	max_pop_count = 0

	new_worker_target = null
	new_worker_target_type = null
	new_worker_target_job = null
	new_worker_target_id = null

	enemy_units = 0
	good_units = 0
