extends Control

@export_group("UI")
@export var character_name_text : Label
@export var content_text : Label
@export var left_char_texture : TextureRect
@export var right_char_texture : TextureRect
@export_group("DialogueGroup")
@export var dialogue_group : DialogueGroup

var dialogue_index : int = 0
var typing_tween : Tween

func display_next_dialogue() -> void:
	#对话结束退出对话框
	if dialogue_index >= len(dialogue_group.dialogue_list):
		visible = false
		return
	
	var dialg : Dialogue = dialogue_group.dialogue_list[dialogue_index]
	
	#判断是否打印结束
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		content_text.text = dialg.content
		dialogue_index += 1
	else:
		character_name_text.text = dialg.character_name
		
		typing_tween = get_tree().create_tween()
		content_text.text = ""
		for char in dialg.content:
			typing_tween.tween_callback(append_char.bind(char)).set_delay(0.05)
		typing_tween.tween_callback(func(): dialogue_index += 1)
		
		
		if dialg.show_on_left:
			left_char_texture.texture = dialg.char_texture
			right_char_texture.texture = null
		else:
			left_char_texture.texture = null
			right_char_texture.texture = dialg.char_texture

	

func append_char(char : String) -> void:
	content_text.text += char

func _ready() -> void:
	display_next_dialogue()


func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		display_next_dialogue()
