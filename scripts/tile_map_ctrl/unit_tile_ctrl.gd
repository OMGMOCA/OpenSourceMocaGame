@tool
extends Node2D


var pre_pos : Vector2
var tile_map_unit : TileMapLayer
var tile_size : Vector2i

#var assets_root : Node2D

@export var atlas_cood_land : Vector2i = Vector2i(2,0)
@export var atlas_cood_water : Vector2i = Vector2i(0,3)



func _ready(): 
	pre_pos = position 
	tile_map_unit = find_child("TileMapUnit")
	tile_size = tile_map_unit.tile_set.tile_size
	
	#assets_root = find_child("assets_root")
	
	snap_to_cell()
	enable_change()

	
func _process(delta): 
	if Engine.is_editor_hint():
		snap_to_cell()
		enable_change()
		
func snap_to_cell():
	if position != pre_pos: 
		position = Vector2(int(position.x/tile_size.x) * tile_size.x,int(position.y/tile_size.y) * tile_size.y)
		pre_pos = position 

func enable_change():
	var parent = get_parent()
	if parent and parent.name == "units":
		if tile_map_unit.enabled:
			tile_map_unit.enabled = false
