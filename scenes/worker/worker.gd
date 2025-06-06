extends CharacterBody2D

@export var speed := 150
@export var laser: PackedScene

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var back_sprite: Sprite2D = $Body/backSprite
@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_still_too_long: Timer = $TimerStillTooLong
@onready var body: Node2D = $Body

var target_radius = 10
var av: Vector2 = Vector2.ZERO
var avoid_weight := 0.1

var job_building := false
var job_cutting_wood := false
var job_mining_gold := false
var job_farming_farm := false
var job_attack_building := false
var job_attack_unit := false
var using_worker_tools := false
var target_id = null
var target_middle_of_enemy = null

var wood_gathered := 0
var gold_gathered := 0
var food_gathered := 0

var is_able_to_shoot := true
var new_id = null

var health := 10

var selected = false:
	set = set_selected
	
var target = null:
	set = set_target

func _ready() -> void:
	Global.good_units += 1
	Global.pop_count += 1
	
	var chars = 'abcdefghijklmnopqrstuvwxyz'
	new_id = generate_id(chars, 10)
	add_to_group("unit")
	
func _physics_process(delta: float) -> void:
	make_path()
	move_towards_target()
	
	if selected && Global.new_worker_target != null:
		turn_off_all_jobs()
		target = Global.new_worker_target
		target_id = Global.new_worker_target_id
		
		if Global.new_worker_target_job == Global.WORKER_ACTIONS.BUILD:
			job_building = true
		elif Global.new_worker_target_job == Global.WORKER_ACTIONS.WOOD:
			job_cutting_wood = true
		elif Global.new_worker_target_job == Global.WORKER_ACTIONS.GOLD:
			job_mining_gold = true
		elif  Global.new_worker_target_job == Global.WORKER_ACTIONS.ATTACK_BUILDING:
			job_attack_building = true
		elif Global.new_worker_target_job == Global.WORKER_ACTIONS.ATTACK_UNIT:
			job_attack_unit = true
		elif Global.new_worker_target_job == Global.WORKER_ACTIONS.FARM:
			job_farming_farm = true
		elif Global.new_worker_target_job == (
			Global.WORKER_ACTIONS.TILE 
			&& !job_farming_farm):
			find_closest_side_of_tile()
		selected = false
	
	if using_worker_tools:
		speed = 0
		animation_player.play("use_tools")
		await animation_player.animation_finished
		
		if check_jobs_wood_gold_farm():
			find_closest_drop_off_spot()
			find_closest_side_of_tile()
		
		if ((check_jobs_wood_gold_farm()
		|| job_building)
		&& timer_still_too_long.time_left == 0
		&& velocity == Vector2(0,0)
		&& target == null):
			using_worker_tools = false
			find_closest_target_for_job()
			reset_stand_still_timer()
	
	check_if_no_more_resources_for_job()
	
	if velocity != Vector2(0,0):
		body.look_at(nav_agent.get_next_path_position())

func check_jobs_wood_gold_farm() -> bool:
	return (job_cutting_wood || job_mining_gold || job_farming_farm)

func turn_off_all_jobs() -> void:
	job_attack_building = false
	job_attack_unit = false
	job_building = false
	job_cutting_wood = false
	job_mining_gold = false
	
func set_selected(val) -> void:
	selected = val
	if selected:
		back_sprite.visible = true
		Global.are_workers_selected = true
	else:
		back_sprite.visible = false
		Global.are_workers_selected = false
	
func set_target(val) -> void:
	target = val
	
func avoid() -> Vector2:
	var result = Vector2.ZERO
	var neighbors = area_2d.get_overlapping_bodies()
	if neighbors:
		for n in neighbors:
			result += n.position.direction_to(position)
		result /= neighbors.size()
	return result.normalized()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func make_path() -> void:
	if target != null:
		nav_agent.target_position = target

func move_towards_target() -> void:
	velocity = Vector2.ZERO
	if target != null:
		velocity = position.direction_to(target)
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		if position.direction_to(target) < target_radius:
			target = null
	av = avoid()
	velocity = (velocity + av * avoid_weight).normalized() * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(velocity)
	
	move_and_slide()
	var next_path_position = nav_agent.get_next_path_position()




	
	
	
	
	
	
