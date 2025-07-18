extends Node2D

var new_building_cost := 50

@export var new_town_center: PackedScene
@export var new_house: PackedScene
@export var new_farm: PackedScene
@export var new_barracks: PackedScene
@export var new_range_building: PackedScene
@export var new_tower: PackedScene

@onready var game_objects: Node2D = $"../../GameObjects"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func add_new_building(new_building):
	game_objects.add_child(new_building)
	
func apply_build_cost_wood():
	Global.increment_wood_count(-new_building_cost)

func apply_build_cost_gold():
	Global.increment_gold_count(-new_building_cost)

func check_sufficient_wood() -> bool:
	return Global.get_wood_count() >= 50
	
func check_sufficient_gold() -> bool:
	return Global.get_gold_count() >= 50
	
func build(new_building, costs_gold: bool = false) -> void:
	if costs_gold && !check_sufficient_gold():
		return
	if check_sufficient_wood():
		add_new_building(new_building)
		apply_build_cost_wood()

func _on_button_build_tc_pressed() -> void:
	build(new_town_center.instantiate(), true)

func _on_button_build_farm_pressed() -> void:
	build(new_farm.instantiate())

func _on_button_build_house_pressed() -> void:
	build(new_house.instantiate())

func _on_button_build_barracks_pressed() -> void:
	build(new_barracks.instantiate())

func _on_button_build_range_pressed() -> void:
	build(new_range_building.instantiate())
		
func _on_button_build_tower_pressed() -> void:
	build(new_tower.instantiate())
