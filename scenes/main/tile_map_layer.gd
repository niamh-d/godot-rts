extends TileMapLayer

const nav_id := 0
const no_nav_id := 1

func _process(delta: float) -> void:
	if Global.add_nav_spot != null:
		for spot in Global.add_nav_spot:
			erase_cell(Vector2(spot.x, spot.y))
			erase_cell(Vector2(spot.x + 1, spot.y))
			erase_cell(Vector2(spot.x, spot.y + 1))
			erase_cell(Vector2(spot.x + 1, spot.y + 1))
			
			set_cell(Vector2(spot.x, spot.y), nav_id, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y), nav_id, Vector2i(0,0))
			set_cell(Vector2(spot.x, spot.y + 1), nav_id, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y + 1), nav_id, Vector2i(0,0))
		Global.add_nav_spot.clear()
	
	if Global.add_to_no_nav_spot != null:
		for spot in Global.add_to_no_nav_spot:
			erase_cell(Vector2(spot.x, spot.y))
			erase_cell(Vector2(spot.x + 1, spot.y))
			erase_cell(Vector2(spot.x, spot.y + 1))
			erase_cell(Vector2(spot.x + 1, spot.y + 1))
			
			set_cell(Vector2(spot.x, spot.y), no_nav_id, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y), no_nav_id, Vector2i(0,0))
			set_cell(Vector2(spot.x, spot.y + 1), no_nav_id, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y + 1), no_nav_id, Vector2i(0,0))
		Global.add_to_no_nav_spot.clear()
