extends Node3D

@export var sound_effects_bus_name: String = "SoundEffects"

func play_sound_effect(sound: AudioStream, positional: bool = false) -> void:
	var pitch_range: Vector2 = Vector2(0.95, 1.05)
	var volume_db: float = 1.0
	var pause_behaviour = PROCESS_MODE_INHERIT
	
	if sound != null:
		var stream_player = AudioStreamPlayer.new() if !positional else AudioStreamPlayer3D.new()

		stream_player.stream = sound
		stream_player.bus = sound_effects_bus_name
		stream_player.finished.connect(stream_player.queue_free)
		stream_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
		stream_player.volume_db = volume_db

		# Add the new stream player to scene tree
		add_child(stream_player)
		if positional:
			print("set position, attenuation filter cutoff, and volume, of the sound")

		# Play the sound
		stream_player.play()
