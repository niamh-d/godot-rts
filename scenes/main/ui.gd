extends CanvasLayer

@onready var label_wood: Label = $ResourceText/LabelWood
@onready var label_food: Label = $ResourceText/LabelFood
@onready var label_gold: Label = $ResourceText/LabelGold
@onready var label_population: Label = $ResourceText/LabelPopulation
@onready var worker_build_options: Node2D = $WorkerBuildOptions

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	set_label_text()
	check_worker_options_visibility()
	
func set_label_text() -> void:
	label_wood.text = "Wood: %d" % Global.get_wood_count()
	label_gold.text = "Gold %d" % Global.get_gold_count()
	label_food.text = "Food: %d" % Global.get_food_count()
	var pop_counts_array = [Global.get_pop_count(), Global.get_max_pop_count()]
	label_population.text = "Population: %d/%d" % pop_counts_array

func check_worker_options_visibility() -> void:
	worker_build_options.visible = Global.check_workers_selected()
