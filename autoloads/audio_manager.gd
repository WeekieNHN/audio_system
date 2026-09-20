extends Node3D

@export var sound_effects_bus_name: String = "SoundEffects"

## 
## Rough Source: https://www.youtube.com/watch?v=pSpdo9udcJI
## Heavily Edited 
##

func _physics_process(delta: float) -> void:
	update_tracked_sounds()


func play_sound_effect(sound: AudioStream, position: Variant = null, random_pitch: bool = true, max_distance: float = 30.0) -> void:
	# Skip if null sound, nothing to do
	if sound == null: return
	# Set variables for later use
	var pitch_range: Vector2 = Vector2(0.95, 1.05) 
	var volume_db: float = 1.0
	var pause_behaviour = PROCESS_MODE_INHERIT
	# Create a stream player
	var stream_player = AudioStreamPlayer.new() if position == null else AudioStreamPlayer3D.new()
	# Set Properties
	stream_player.stream = sound
	stream_player.bus = sound_effects_bus_name
	stream_player.finished.connect(stream_player.queue_free)
	if random_pitch: stream_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	stream_player.volume_db = volume_db
	# Add the new stream player to scene tree
	add_child(stream_player)
	# If the stream is positional (we gave it a position)
	if position is Vector3:
		stream_player = stream_player as AudioStreamPlayer3D
		# Set the position
		stream_player.global_position = convert_position_to_offset(position)
		# Set the attenuation cutoff
		stream_player.attenuation_filter_cutoff_hz = 20500
		# Set the volume
		stream_player.volume_db = 8.0
	# if the stream is position AND tracked (argument is a Node3D)
	if position is Node3D:
		stream_player = stream_player as AudioStreamPlayer3D
		# Start tracking the sound
		tracked_sound_positions[stream_player] = position
		# Setup attenuation curve
		# stream_player.max_distance = max_distance
		# stream_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		# Set distance where the curve starts full volume
		# stream_player.unit_size = 5.0
		# Simulates distance muffling (air absorption / low-pass filter)
		stream_player.attenuation_filter_cutoff_hz = 5000.0 
		stream_player.attenuation_filter_db = -24.0
		# Set the position
		stream_player.global_position = convert_position_to_offset(position.global_position)
		# Set the volume
		stream_player.volume_db = 2.0
	# Play the sound
	stream_player.play()


@export var button_click_sfx_scene: PackedScene = null
func add_ui_sfx(node: Node) -> void:
	if button_click_sfx_scene:
		for button in node.find_children("*", "Button", true, false):
			# Skip if already has button SFX
			if button.get_children().any(func(child): return child is ButtonClickSFX): 
				continue
			# Add buttons click sfx
			button.add_child(button_click_sfx_scene.instantiate())

#region Environmental sounds

# Keep track of the node since their positions will change over time
# Keep track of audio listeners
var audio_listeners: Array[AudioListener3D] = []
func add_audio_listener(listener: AudioListener3D) -> void: audio_listeners.append(listener)

# Calculate the distance to closest listener
# Localize the position as an offset to that listener
func convert_position_to_offset(original_pos: Vector3) -> Vector3:
	# Find which audio listener is closest 
	var closest_position: Vector3 
	var closest_distance: float = INF
	for lis in audio_listeners:
		if closest_distance == INF: 
			closest_position = lis.global_position
			closest_distance = original_pos.distance_to(lis.global_position)
			continue
		# Otherwise check if distance is shorter
		# Only check active listeners
		if original_pos.distance_to(lis.global_position) < closest_distance and lis.visible:
			closest_position = lis.global_position
			closest_distance = original_pos.distance_to(lis.global_position)
	# Calculate/return offset
	return original_pos - closest_position

var tracked_sound_positions: Dictionary[AudioStreamPlayer3D, Node3D] = {}

func update_tracked_sounds() -> void:
	# Iterate over tracked sounds
	for sound in tracked_sound_positions.keys():
		# var new_pos = convert_position_to_offset(tracked_sound_positions[sound].global_position)
		#print("updating position of %s (%s vs %s, dist: %s)" % [sound.stream.resource_name, tracked_sound_positions[sound].global_position, new_pos, tracked_sound_positions[sound].global_position.distance_to(new_pos)])
		# Keep the position updated
		if not is_instance_valid(sound) or not is_instance_valid(tracked_sound_positions[sound]): 
			tracked_sound_positions.erase(sound)
			sound.queue_free()
			continue
		sound.global_position = convert_position_to_offset(tracked_sound_positions[sound].global_position)

#endregion
