extends Node

func generate_id(length) -> String:
	var chars = 'abcdefghijklmnopqrstuvwxyz'
	var id: String
	var n_chars = len(chars)
	
	for i in range(length):
		id += chars[randi() % n_chars]
	
	return id
