@tool
extends Node2D


#子节点
var tile_map_world : TileMapLayer = null
var tile_map_display : TileMapLayer = null
var tile_map_water : TileMapLayer = null
var units : Node2D = null

#units转世界的更新频率
var update_interval : float = 0.5
var update_time : float = 0.0

#世界转显示对照表
var display_tile_atlas_cood : Dictionary = {
	#命名顺序：左上，右上，左下，右下
	#"0010":Vector3i(0,0,是否为基础块),值为0代表基础块，1代表非基础
	"0010":Vector2i(0,0),
	"0101":Vector2i(1,0),
	"1011":Vector2i(2,0),
	"0011":Vector2i(3,0),
	"1001":Vector2i(0,1),
	"0111":Vector2i(1,1),
	"1111":Vector2i(2,1),
	"1110":Vector2i(3,1),
	"0100":Vector2i(0,2),
	"1100":Vector2i(1,2),
	"1101":Vector2i(2,2),
	"1010":Vector2i(3,2),
	"0000":Vector2i(0,3),
	"0001":Vector2i(1,3),
	"0110":Vector2i(2,3),
	"1000":Vector2i(3,3),

}
#显示联动
var display_world_tile : bool = false
var display_display_tile : bool = true

#临时变量
@export var source_id = 1

#细节复杂度
@export_range(0, 1000) var complexity_normal: int = 100
@export_range(0, 1000) var complexity_inside: int = 5



func _ready() -> void:
	#初始化
	tile_map_world = find_child("TileMapWorld")
	tile_map_display = find_child("TileMapDisplay")
	tile_map_water = tile_map_display.find_child("TileMapWater")
	units = find_child("units")
	
	tile_map_world.visible = display_world_tile
	tile_map_display.visible = display_display_tile
	
	world_tile_ctrl()
	display_tile_ctrl()

func _process(delta: float) -> void:
	#如果是编辑器模式，每隔0.5s更新一下world map tile
	if Engine.is_editor_hint():
		update_time += delta
		if update_time >= update_interval:
			world_tile_ctrl()
			#display_tile_ctrl()
			update_time = 0.0
		
		#显示联动控制
		if tile_map_world.visible != display_world_tile:
			display_world_tile = tile_map_world.visible
			display_display_tile = not tile_map_world.visible 
			tile_map_display.visible = not tile_map_world.visible
			display_tile_ctrl()
		elif tile_map_display.visible != display_display_tile:
			display_display_tile = tile_map_display.visible
			display_world_tile = not tile_map_display.visible 
			tile_map_world.visible = not tile_map_display.visible
			display_tile_ctrl()
			

func world_tile_ctrl() -> void:
	#刷新worldMapTile
	clear_tilemap(tile_map_world)
	for tile_map_root in units.get_children():
		map_cells(tile_map_root)

func map_cells(tile_map_root) -> void:
	#将unit中的tile数据转录至tile map world
	var tile_map_pos : Vector2 = tile_map_root.position
	var tile_map : TileMapLayer = tile_map_root.find_child("TileMapUnit")
	for y in range(-1,tile_map.get_used_rect().size.y + 1):
		for x in range(-1,tile_map.get_used_rect().size.x + 1):
			var cell_x = x + tile_map.get_used_rect().position.x
			var cell_y = y + tile_map.get_used_rect().position.y
			var cell_vec = Vector2i(cell_x,cell_y)
			var original_atlas_cood = tile_map.get_cell_atlas_coords(cell_vec)
			if original_atlas_cood != Vector2i(-1,-1):
				var world_cell_vec = cell_vec + tile_map_world.local_to_map(tile_map_pos)
				var atlas_cood_land = tile_map_root.atlas_cood_land
				var atlas_cood_water = tile_map_root.atlas_cood_water
				if original_atlas_cood == Vector2i(0,0):
					#清空Vector2i(0,0)位置的cell
					tile_map_world.set_cell(world_cell_vec,0,Vector2i(-1,-1),0)
				elif original_atlas_cood == Vector2i(1,0):
					#Vector2i(1,0)为陆地
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(1,0),atlas_cood_land,atlas_cood_water)
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(1,1),atlas_cood_land,atlas_cood_water)
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(0,1),atlas_cood_land,atlas_cood_water)
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(-1,1),atlas_cood_land,atlas_cood_water)
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(-1,0),atlas_cood_land,atlas_cood_water)
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(-1,-1),atlas_cood_land,atlas_cood_water)
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(0,-1),atlas_cood_land,atlas_cood_water)
					set_gradient_cell(tile_map_world,world_cell_vec + Vector2i(1,-1),atlas_cood_land,atlas_cood_water)
					
					tile_map_world.set_cell(world_cell_vec,0,atlas_cood_land,0)
				elif original_atlas_cood == Vector2i(2,0):
					#Vector2i(2,0)为水
					tile_map_world.set_cell(world_cell_vec,0,atlas_cood_water,0)
					pass

func clear_tilemap(tile_map : TileMapLayer):
	# 清空tilemap，用于刷新tile
	var used_cells = tile_map.get_used_cells()
	for cell_vec in used_cells:
		tile_map.set_cell(cell_vec,0,Vector2i(-1,-1),0)  # 设置网格值为 -1，表示清空
		
func set_gradient_cell(tile_map : TileMapLayer,adjacent_cell_vec : Vector2i,atlas_cood_land : Vector2i,atlas_cood_water : Vector2i) -> void:
	#如果相邻两块有差异，则在中间添加基础块
	var adjacent_cell_atlas_cood = tile_map.get_cell_atlas_coords(adjacent_cell_vec)
	#elif 是水: 不设置 尝试使用atlas_cood_water判断
	if adjacent_cell_atlas_cood != atlas_cood_water:
		if adjacent_cell_atlas_cood != atlas_cood_land and adjacent_cell_atlas_cood != Vector2i(-1,-1):
			tile_map.set_cell(adjacent_cell_vec,0,Vector2i(0,0),0)
		
func display_tile_ctrl() -> void:
	clear_tilemap(tile_map_display)
	clear_tilemap(tile_map_water)
	
	var world_used_cells = tile_map_world.get_used_cells()
	for y in range(-1,tile_map_world.get_used_rect().size.y + 1):
		for x in range(-1,tile_map_world.get_used_rect().size.x + 1):
			var cell_x = x + tile_map_world.get_used_rect().position.x
			var cell_y = y + tile_map_world.get_used_rect().position.y
			var cells_vec = Vector2i(cell_x,cell_y)
			
			var atlas_cood = get_display_tile_atlas_cood(tile_map_world,cells_vec)
			#var source_id = atlas_cood_to_source_id(tile_map_world,cells_vec)
			tile_map_display.set_cell(cells_vec,source_id,atlas_cood,0)
			
			#人为规定worldtile的第四行都是水
			var atlas_cood_world = tile_map_world.get_cell_atlas_coords(cells_vec)
			if atlas_cood_world.y == 3:
				tile_map_water.set_cell(cells_vec,0,Vector2i(0,0),0)
			#如果是水
			#在新的水tile层创建水的方块，这一层的位置与world一致，没有偏移
			#...

		await get_tree().create_timer(0.0).timeout

func get_display_tile_atlas_cood(tile_map_world : TileMapLayer,world_cell_vec : Vector2i) -> Vector2i:
	var up_left = is_used_cell(tile_map_world,world_cell_vec + Vector2i(0,-1))
	var up_right = is_used_cell(tile_map_world,world_cell_vec + Vector2i(1,-1))
	var down_left = is_used_cell(tile_map_world,world_cell_vec)
	var down_right = is_used_cell(tile_map_world,world_cell_vec + Vector2i(1,0))
	var atlas_cood_name :String = up_left + up_right + down_left + down_right
	#print("atlas_cood_name: ",atlas_cood_name)
	var atlas_cood = display_tile_atlas_cood[atlas_cood_name]
	#随机替换
	if randi() % 1000 <= complexity_normal and atlas_cood_name != "1111" or randi() % 1000 <= complexity_inside and atlas_cood_name == "1111":
		atlas_cood += Vector2i(4,0)
	return atlas_cood

func is_used_cell(tile_map_layer : TileMapLayer,cell_vec : Vector2i) -> String:
	#在此增加主题源索引，四个块中，只会存在两种类型。
	#脚本合并后，由tile_map_root.atlas_cood_water代替水的检测？或规定水在第四列
	if tile_map_layer.get_cell_atlas_coords(cell_vec) == Vector2i(-1,-1) or tile_map_layer.get_cell_atlas_coords(cell_vec) == Vector2i(0,3):
		return "0"
	else:
		return "1"
	#elif tile_map_layer.get_cell_atlas_coords(cell_vec) == Vector2i(0,0): #是不是基础块
		#return "1"
	#else:
		##非基础块 return 2
		#return "2"
		
		
