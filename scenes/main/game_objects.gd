extends Node2D

var is_dragging := false
var drag_start: Vector2 = Vector2.ZERO
var select_rect: RectangleShape2D = RectangleShape2D.new()
var selected_arr: Array = []

func _process(delta: float) -> void:
	if !Global.are_workers_selected:
		selected_arr = []

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if selected_arr.size() == 0:
				is_dragging = true
				drag_start = get_global_mouse_position()
			else:
				for item in selected_arr:
					if str(item.collider) != "<Freed Object>":
						item.collider.target = get_global_mouse_position()
						item.collider.turn_off_all_jobs()
						item.collider.selected = false
				selected_arr = []
		elif is_dragging:
			is_dragging = false
			queue_redraw()
			var drag_end = get_global_mouse_position()
			select_rect.extents = abs(drag_end - drag_start) / 2
			var space = get_world_2d().direct_space_state
			var q = PhysicsShapeQueryParameters2D.new()
			q.shape = select_rect
			q.collision_mask = 2
			q.transform = Transform2D(0, (drag_end + drag_start) / 2)
			selected_arr = space.intersect_shape(q)
			for item in selected_arr:
				item.collider.selected = true 
	
	if event is InputEventMouseMotion && is_dragging:
		queue_redraw()
			

func _draw():
	if is_dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), Color.WHITE, false, 4.0)
