class_name ButtonClickSFX extends Node

@export var button_sfx: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("get_audio_manager") # Need to make sure that we can play audio
	
	if get_parent() is not Button: print("Parent is not button")
	else: get_parent().pressed.connect(on_pressed)

var audio_manager_exists: bool = false
func get_audio_manager() -> void:
	audio_manager_exists = has_node("/root/AudioManager")

func on_pressed() -> void:
	if !audio_manager_exists: return
	# play the sound effect
	AudioManager.play_sound_effect(button_sfx, false)
