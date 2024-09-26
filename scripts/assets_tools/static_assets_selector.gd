@tool
extends Node2D
class_name StateAssetsSelector

@export_group("Sprite")
@export var texture : Texture2D = null:
	set(value):
		texture = value
		if Engine.is_editor_hint():
			set_sprite()
	get:
		return texture

@export_range(1, 1024) var hframes : int = 1:
	set(value):
		hframes = value
		if Engine.is_editor_hint():
			set_sprite()
	get:
		return hframes
		
@export_range(1, 1024) var vframes : int = 1:
	set(value):
		vframes = value
		if Engine.is_editor_hint():
			set_sprite()
	get:
		return vframes
		

@export var sprite_index : int = 1:
	set(value):
		sprite_index = value
		if Engine.is_editor_hint():
			var sprite = find_child("Sprite2D")
			if not sprite: return
			var range = sprite.get("hframes") * sprite.get("vframes")
			if sprite_index >= range:
				sprite_index = 0
			elif sprite_index < 0:
				sprite_index = range - 1
			set_sprite()

	get:
		return sprite_index
		
		
		
func set_sprite() -> void:
	var sprite = find_child("Sprite2D")
	if not sprite: return
	sprite.set("texture",texture)
	sprite.set("hframes",hframes)
	sprite.set("vframes",vframes)
	sprite.set("frame",sprite_index)
	
func _ready() -> void:
	if Engine.is_editor_hint(): return
	set_sprite()
