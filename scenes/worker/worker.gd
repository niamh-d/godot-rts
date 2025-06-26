extends CharacterBody2D

@export var default_speed := 150
@export var speed := 150
@export var laser: PackedScene
@export var pursuit_speed := 150

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var back_sprite: Sprite2D = $Body/backSprite
@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_still_too_long: Timer = $TimerStillTooLong
@onready var timer_shoot: Timer = $TimerShoot
@onready var worker_body: Node2D = $Body
@onready var progress_bar: ProgressBar = $ProgressBar

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
	Global.update_num_friendly_units(1)
	Global.update_pop_count(1)
	
	new_id = Utils.generate_id(10)
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
			reset_stand_still_time()
	
	check_if_no_more_resources_for_jobs()
	
	if velocity != Vector2(0,0):
		worker_body.look_at(nav_agent.get_next_path_position())
	
	if job_attack_building && target != null:
		var distance_to_enemy = (target - global_position).length()
		
		if distance_to_enemy <= 70:
			worker_body.look_at(target_middle_of_enemy)
			speed = 0
			if is_able_to_shoot:
				is_able_to_shoot = false
				timer_shoot.start()
				var new_laser = laser.instantiate()
				new_laser.is_good_laser = true
				add_sibling(new_laser)
				new_laser.position = worker_body.global_position
				new_laser.look_at(target_middle_of_enemy)
				new_laser.owner_id = new_id
			
			find_enemy()
		else:
			find_enemy()
			speed = pursuit_speed
	
	progress_bar.value = health
	
	if health <= 0:
		Global.update_num_friendly_units(-1)
		Global.update_pop_count(-1)
		queue_free()

func increment_health(val: int) -> void:
	var new_val = health + val
	health = new_val if new_val >= 0 else 0

func find_closest_side_of_tile() -> void:
	if (target != null
	&& target.x < self.position.x
	&& target.y < self.position.y):
		target.x = target.x + 40
		target.y = target.y + 40
		
	if (target != null
	&& target.x < self.position.x
	&& target.y > self.position.y):
		target.x = target.x + 40
		target.y = target.y - 40
	
	if (target != null
	&& target.x > self.position.x
	&& target.y < self.position.y):
		target.x = target.x - 40
		target.y = target.y + 40
	
	if (target != null
	&& target.x > self.position.x
	&& target.y > self.position.y):
		target.x = target.x - 40
		target.y = target.y - 40
			
func find_enemy() -> void:
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	var targeted_enemy_is_found := false
			
	for en in all_enemies:
		if en.new_id == target_id:
			target = en.position
			target_middle_of_enemy = target
			find_closest_side_of_tile()
			targeted_enemy_is_found = true
			
	if !targeted_enemy_is_found:
		job_attack_building == false
		target = null
		target_id = null
		turn_off_all_jobs()

func check_jobs_wood_gold_farm() -> bool:
	return (job_cutting_wood || job_mining_gold || job_farming_farm)

func turn_off_all_jobs() -> void:
	target_id = null
	job_attack_building = false
	job_attack_unit = false
	job_building = false
	job_cutting_wood = false
	job_mining_gold = false
	job_farming_farm = false
	using_worker_tools = false
	speed = default_speed
	
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
		if position.distance_to(target) < target_radius:
			target = null
	av = avoid()
	velocity = (velocity + av * avoid_weight).normalized() * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(velocity)
	
	move_and_slide()
	var next_path_position = nav_agent.get_next_path_position()

func reset_gathered_resources() -> void:
	gold_gathered = 0
	wood_gathered = 0
	food_gathered = 0

func get_to_work(area: Area2D) -> void:
	using_worker_tools = true
	worker_body.look_at(area.position)

func _on_area_2d_area_entered(area) -> void:
	
	if (area.is_in_group("built_building")
	&& job_building):
		using_worker_tools = false
		find_closest_target_for_job()
		reset_stand_still_time()
		return
	
	if check_jobs_wood_gold_farm() && area.is_in_group("town_center"):
		Global.increment_wood_count(wood_gathered)
		Global.increment_gold_count(gold_gathered)
		Global.increment_food_count(food_gathered)
		
		reset_gathered_resources()
		worker_body.look_at(area.position)
		go_back_to_resource_source()
	
	if ((area.is_in_group("unbuilt_building")
	&& job_building) || (area.is_in_group("tree")
	&& job_cutting_wood) || (area.is_in_group("gold")
	&& job_mining_gold) || (area.is_in_group("farm")
	&& job_farming_farm)
	&& area.new_id == target_id):
		get_to_work(area)
	
	if area.is_in_group("enemy_laser"):
		increment_health(-1)
		
		if target_id != area.owners_id:
			turn_off_all_jobs()
			job_attack_building = true
			job_attack_unit = true
			target_id = area.owners_id
			worker_body.look_at(area.position)
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			for en in all_enemies:
				if en.new_id == target_id:
					target = en.position
					target_middle_of_enemy = target
					
		area.queue_free()

func reset_stand_still_time() -> void:
	timer_still_too_long.start()
	
func set_all_nodes() -> Array:
	var nodes: Array = []
	if job_building:
		nodes = get_tree().get_nodes_in_group("unbuilt_building")
	if job_cutting_wood:
		nodes = get_tree().get_nodes_in_group("tree")
	if job_mining_gold:
		nodes = get_tree().get_nodes_in_group("gold")
	if job_farming_farm:
		nodes = get_tree().get_nodes_in_group("farm")
	if job_attack_building:
		nodes = get_tree().get_nodes_in_group("enemy")
	
	return nodes
		
func find_closest_target_for_job() -> void:
	var shortest_distance = INF
	var closest_job
	var all_jobs: Array = []
	
	all_jobs = set_all_nodes() 
	
	for job in all_jobs:
		var distance = job.global_position.distance_to(position)
		if distance < shortest_distance:
			closest_job = job.position
			shortest_distance = distance
			target_id = job.new_id
			target = closest_job
			
			if !job_farming_farm:
				find_closest_side_of_tile()

func find_closest_drop_off_spot() -> void:
	var shortest_distance = INF
	var closest_drop_off
	var all_drop_offs: Array = []
	
	all_drop_offs = get_tree().get_nodes_in_group("town_center")
	
	for drop in all_drop_offs:
		var distance = drop.global_position.distance_to(position)
		if distance < shortest_distance:
			closest_drop_off = drop.position
			shortest_distance = distance
			target = closest_drop_off
			
func go_back_to_resource_source() -> void:
	var shortest_distance = INF
	var all_resources: Array = []
	
	all_resources = set_all_nodes()
	
	for resource in all_resources:
		var distance = resource.global_position.distance_to(position)
		if resource.new_id == target_id:
			target = resource.position
			if !job_farming_farm:
				find_closest_side_of_tile()

func check_if_no_more_resources_for_jobs() -> void:
	var shortest_distance = INF
	var all_resources: Array = []
	
	all_resources = set_all_nodes()
	
	if all_resources.size() == 0:
		turn_off_all_jobs()

func _on_timer_shoot_timeout() -> void:
	is_able_to_shoot = true
