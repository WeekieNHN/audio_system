extends Node3D

@export var sound_effects_bus_name: String = "SoundEffects"

## 
## Rough Source: https://www.youtube.com/watch?v=pSpdo9udcJI
## Heavily Edited 
##

func play_sound_effect(sound: AudioStream, position: Vector3 = Vector3.ZERO) -> void:
	# Skip if null sound, nothing to do
	if sound == null: return
	# Set variables for later use
	var pitch_range: Vector2 = Vector2(0.95, 1.05)
	var volume_db: float = 1.0
	var pause_behaviour = PROCESS_MODE_INHERIT
	# Create a stream player
	var stream_player = AudioStreamPlayer.new() if position == Vector3.ZERO else AudioStreamPlayer3D.new()
	# Set Properties
	stream_player.stream = sound
	stream_player.bus = sound_effects_bus_name
	stream_player.finished.connect(stream_player.queue_free)
	stream_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	stream_player.volume_db = volume_db
	# Add the new stream player to scene tree
	add_child(stream_player)
	# If the stream is positional (we gave it a position)
	if position != Vector3.ZERO:
		stream_player = stream_player as AudioStreamPlayer3D
		# Set the position
		stream_player.global_position = position
		# Set the attenuation cutoff
		stream_player.attenuation_filter_cutoff_hz = 20500
		# Set the volume
		stream_player.volume_db = 8.0
	# Play the sound
	stream_player.play()


@export var button_click_sfx_scene: PackedScene = null
func add_ui_sfx(node: Node) -> void:
	if button_click_sfx_scene:
		for button in node.find_children("*", "Button", true, false):
			# Skip if already has button SFX
			if button.get_children().any(func(child): return child is ButtonClickSFX): 
				print(button.name)
				continue
			# Add buttons click sfx
			button.add_child(button_click_sfx_scene.instantiate())
