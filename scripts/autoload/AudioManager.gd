extends Node

## AudioManager Singleton
## Manages all sound effects and background music in the game

# AudioStreamPlayer nodes (allows multiple sounds to play simultaneously)
var button_click_player: AudioStreamPlayer
var success_player: AudioStreamPlayer
var failure_player: AudioStreamPlayer
var victory_player: AudioStreamPlayer
var death_player: AudioStreamPlayer
var damage_player: AudioStreamPlayer
var alarm_player: AudioStreamPlayer
var event_start_player: AudioStreamPlayer
var laser_fire_player: AudioStreamPlayer
var explosion_player: AudioStreamPlayer
var reactor_powerdown_player: AudioStreamPlayer
var room_lock_player: AudioStreamPlayer

# Music player
var music_player: AudioStreamPlayer

# Preloaded sound resources
var button_click_sound = preload("res://assets/sounds/SFX/button_click.wav")
var success_sound = preload("res://assets/sounds/SFX/success.wav")
var failure_sound = preload("res://assets/sounds/SFX/failure.wav")
var victory_sound = preload("res://assets/sounds/SFX/victory.wav")
var death_sound = preload("res://assets/sounds/SFX/death.wav")
var damage_sound = preload("res://assets/sounds/SFX/damage.wav")
var alarm_sound = preload("res://assets/sounds/SFX/alarm.wav")
var event_start_sound = preload("res://assets/sounds/SFX/event_start.wav")
var laser_fire_sound = preload("res://assets/sounds/SFX/ES_Blaster, Laser, Boom x4 - Epidemic Sound - 0000-1207.wav")
var explosion_sound = preload("res://assets/sounds/SFX/ES_Loud Powerful Blast, Heavy impact, Deep Rumble, Subtle Wooden Debris, Low Explosion Sweetener 01 - Epidemic Sound - 0000-3522.wav")
var reactor_powerdown_sound = preload("res://assets/sounds/SFX/ES_Charge Down, Power Off, Descend - Epidemic Sound - 0000-2889.wav")
var room_lock_sound = preload("res://assets/sounds/SFX/ES_Metal Padlock, Large, Movement - Epidemic Sound - 0000-0340.wav")

# Music tracks
var music_tracks = [
	preload("res://assets/sounds/music/Stellar Blueprints.mp3"),
	preload("res://assets/sounds/music/Stellar Blueprints (1).mp3")
]
var current_track_index: int = 0

func _ready():
	# Initialize AudioStreamPlayer nodes
	button_click_player = AudioStreamPlayer.new()
	button_click_player.stream = button_click_sound
	add_child(button_click_player)

	success_player = AudioStreamPlayer.new()
	success_player.stream = success_sound
	add_child(success_player)

	failure_player = AudioStreamPlayer.new()
	failure_player.stream = failure_sound
	add_child(failure_player)

	victory_player = AudioStreamPlayer.new()
	victory_player.stream = victory_sound
	add_child(victory_player)

	death_player = AudioStreamPlayer.new()
	death_player.stream = death_sound
	add_child(death_player)

	damage_player = AudioStreamPlayer.new()
	damage_player.stream = damage_sound
	add_child(damage_player)

	alarm_player = AudioStreamPlayer.new()
	alarm_player.stream = alarm_sound
	add_child(alarm_player)

	event_start_player = AudioStreamPlayer.new()
	event_start_player.stream = event_start_sound
	add_child(event_start_player)

	laser_fire_player = AudioStreamPlayer.new()
	laser_fire_player.stream = laser_fire_sound
	add_child(laser_fire_player)

	explosion_player = AudioStreamPlayer.new()
	explosion_player.stream = explosion_sound
	add_child(explosion_player)

	reactor_powerdown_player = AudioStreamPlayer.new()
	reactor_powerdown_player.stream = reactor_powerdown_sound
	add_child(reactor_powerdown_player)

	room_lock_player = AudioStreamPlayer.new()
	room_lock_player.stream = room_lock_sound
	add_child(room_lock_player)

	# Initialize music player
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -5.0  # Slightly quieter than SFX
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)

	# Start background music
	start_music()

## Play button click sound
func play_button_click():
	if button_click_player and not button_click_player.playing:
		button_click_player.play()

## Play success sound (e.g., template loaded, room placed successfully)
func play_success():
	if success_player:
		success_player.play()

## Play failure sound (e.g., invalid room placement)
func play_failure():
	if failure_player:
		failure_player.play()

## Play victory sound (e.g., combat won)
func play_victory():
	if victory_player:
		victory_player.play()

## Play death sound (e.g., ship destroyed)
func play_death():
	if death_player:
		death_player.play()

## Play damage sound (e.g., room takes damage in combat)
func play_damage():
	if damage_player:
		damage_player.play()

## Play alarm sound (e.g., critical system failure)
func play_alarm():
	if alarm_player:
		alarm_player.play()

## Play event start sound (e.g., combat begins, new phase)
func play_event_start():
	if event_start_player:
		event_start_player.play()

## Play laser fire sound (e.g., weapons shooting in combat)
func play_laser_fire():
	if laser_fire_player:
		laser_fire_player.play()

## Play explosion sound (e.g., room destroyed)
func play_explosion():
	if explosion_player:
		explosion_player.play()

## Play reactor powerdown sound (e.g., reactor destroyed, power lost)
func play_reactor_powerdown():
	if reactor_powerdown_player:
		reactor_powerdown_player.play()

## Play room lock sound (e.g., room successfully placed in designer)
func play_room_lock():
	if room_lock_player:
		room_lock_player.play()

## Start background music playback
func start_music():
	if music_player and music_tracks.size() > 0:
		music_player.stream = music_tracks[current_track_index]
		music_player.play()

## Called when a music track finishes - rotates to next track
func _on_music_finished():
	# Move to next track (loop back to 0 after last track)
	current_track_index = (current_track_index + 1) % music_tracks.size()
	start_music()

## Stop background music
func stop_music():
	if music_player:
		music_player.stop()

## Set music volume (-80 to 0 dB)
func set_music_volume(volume_db: float):
	if music_player:
		music_player.volume_db = volume_db
