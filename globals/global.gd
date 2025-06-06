extends Node

enum WORKER_ACTIONS {
	WOOD,
	BUILD,
	ATTACK_BUILDING,
	ATTACK_UNIT,
	GOLD,
	FARM,
	TILE
}

var add_nav_spot = PackedVector2Array()
var add_to_no_nav_spot = PackedVector2Array()
var are_workers_selected := false
var is_building_selected := false

var food_count := 1200
var gold_count := 1200
var wood_count := 1200
var pop_count := 0
var max_pop_count := 0

var new_worker_target = null
var new_worker_target_type = null
var new_worker_target_job = null
var new_worker_target_id = null

var num_enemy_units = 0
var num_friendly_units = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func check_workers_selected() -> bool:
	return are_workers_selected
	
func get_gold_count() -> int:
	return gold_count

func increment_gold_count(amount: int) -> void:
	var new_val = gold_count + amount
	gold_count = new_val if new_val >= 0 else 0

func get_wood_count() -> int:
	return wood_count

func get_food_count() -> int:
	return food_count

func get_pop_count() -> int:
	return pop_count

func get_max_pop_count() -> int:
	return max_pop_count

func update_pop_count(val: int) -> void:
	pop_count += val

func update_num_friendly_units(val: int) -> void:
	num_friendly_units += val

func update_num_enemy_units(val: int) -> void:
	num_enemy_units += val

func increment_food_count(amount: int) -> void:
	var new_val = food_count + amount
	food_count = new_val if new_val >= 0 else 0

func increment_wood_count(amount: int) -> void:
	var new_val = wood_count + amount
	wood_count = new_val if new_val >= 0 else 0

func reset_all_vars() -> void:
	add_nav_spot = PackedVector2Array()
	add_to_no_nav_spot = PackedVector2Array()
	are_workers_selected = false
	is_building_selected = false

	food_count = 1200
	gold_count = 1200
	wood_count = 1200
	pop_count = 0
	max_pop_count = 0

	new_worker_target = null
	new_worker_target_type = null
	new_worker_target_job = null
	new_worker_target_id = null

	num_enemy_units = 0
	num_friendly_units = 0
