@tool
extends Control

@onready var load_texture_btn : Button = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/TextureRect/HBoxContainer/load_btn
@onready var apply_btn : Button = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer2/apply_btn
@onready var texture_rect : TextureRect = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/TextureRect
@onready var grid_container : GridContainer = $ScrollContainer/MarginContainer/VBoxContainer/GridContainer

var img_path = "addons/%s.png" % "save_img"

var color_palette = {}
var shader_material : Material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("plugin added")
	shader_material = texture_rect.material
	add_texture_bind()
	apply_btn.pressed.connect(apply_changes_to_image)
	
	get_image(null)
	#palette_update()
	

	
#打开加载图片对话框
#拖拽图片至窗口
func add_texture_bind():
	var file_dialog = FileDialog.new()
	#使用系统的对话框
	file_dialog.use_native_dialog = true
	file_dialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.png", "*.jpg", "*.jpeg", "*.bmp", "*.tga"]
	add_child(file_dialog)
	
	file_dialog.file_selected.connect(on_file_selected)
	load_texture_btn.pressed.connect(func(): 
		file_dialog.popup_centered()
	)
	#拖拽图片加载
	get_tree().get_root().files_dropped.connect(on_files_droped)
	
	
#应用修改
func apply_changes_to_image():
	print("save img! ")
	
	var img = texture_rect.texture.get_image()
	#texture_rect.material.get_local_scene()

	#应用变换，与材质内变换功能类似
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var color = img.get_pixel(x, y)
			for key in color_palette:
				if color == key:
					color = color_palette[key]
					img.set_pixel(x, y, color)

	#保存图片
	img.save_png(img_path)
	#更新色板，以便下一次修改
	get_image(img_path)
	
	Resource
	

func on_file_selected(path):
	get_image(path)

func on_files_droped(files):
	if not mouse_over_ctrl(texture_rect): return
	var path = files[0]
	get_image(path)

#加载图片并更新色板
func get_image(path):
	#获取图片路径
	if path:
		img_path = path
		var texture = load(img_path)
		if texture:
			texture_rect.texture = texture
	#将图片更新至预览界面
	var img = texture_rect.texture.get_image()

	var width = img.get_width()
	var height = img.get_height()
	
	print("remove_all_picker_btn()")
	remove_all_picker_btn()
	
	color_palette.clear()
	for y in range(height):
		for x in range(width):
			var color = img.get_pixel(x, y)
			if color.a != 0:
				color_palette[color] = color

	color_sort()

	for key in color_palette:
		var value = color_palette[key]
		add_color_picker_btn(value)
	
	palette_update()


func remove_all_picker_btn():
	for child in grid_container.get_children():
		child.get_parent().remove_child(child)
		child.queue_free()

	
func sort_by_brightness(a, b):
	var brightness_a = 0.2126 * a.r + 0.7152 * a.g + 0.0722 * a.b
	var brightness_b = 0.2126 * b.r + 0.7152 * b.g + 0.0722 * b.b
	return brightness_a < brightness_b
func color_sort():
	var color_palette_array = color_palette.keys()
	color_palette_array.sort_custom(sort_by_brightness)
	
	color_palette.clear()
	for color in color_palette_array:
		color_palette[color] = color

	
	

func add_color_picker_btn(color):
	var color_picker_btn := ColorPickerButton.new()
	color_picker_btn.custom_minimum_size = Vector2(50,50)
	color_picker_btn.size = Vector2(50,50)
	grid_container.add_child(color_picker_btn)
	color_picker_btn.owner = grid_container
	color_picker_btn.color = color
	color_picker_btn.color_changed.connect(on_picker_pressed.bind(color))


func on_picker_pressed(color : Color,origin_color : Color):
	color_palette[origin_color] = color
	palette_update()
	
func palette_update():
	var color_origin = []
	var color_new = []
	for key in color_palette.keys():
		color_origin.append(key)
		color_new.append(color_palette[key])
		
	shader_material.set("shader_param/palette_length", color_origin.size())
	shader_material.set("shader_param/color_palette", color_origin)
	shader_material.set("shader_param/color_palette_new", color_new)

	
func mouse_over_ctrl(node : Control):
	var mouse = get_global_mouse_position()
	if mouse.x < node.global_position.x \
			or mouse.x < node.global_position.x > node.global_position.x + node.size.x \
			or mouse.y < node.global_position.y \
			or mouse.y < node.global_position.y > node.global_position.y + node.size.y:
		return false
	return true

func _process(delta: float) -> void:
	pass
