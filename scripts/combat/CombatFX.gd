class_name CombatFX
extends Node2D

## Combat visual effects manager
## Handles spawning and animating combat visual effects like lasers, shields, impacts, etc.
## All effects respect the speed_multiplier from the parent Combat scene for consistent timing

## Reference to parent camera for screen shake
@onready var camera: Camera2D = null

## Current screen shake offset
var shake_offset: Vector2 = Vector2.ZERO

## Spawn a laser beam effect from attacker weapon to defender
## duration: Duration in seconds (will be multiplied by speed_multiplier)
func spawn_laser_beam(start_pos: Vector2, end_pos: Vector2, duration: float = 0.3) -> void:
	var laser = Line2D.new()
	add_child(laser)

	# Set up laser appearance
	laser.width = 4.0
	laser.default_color = Color(0.886, 0.290, 0.290, 1.0)  # Red
	laser.add_point(start_pos)
	laser.add_point(end_pos)

	# Add glow effect with second slightly wider line
	var glow = Line2D.new()
	add_child(glow)
	glow.width = 8.0
	glow.default_color = Color(0.886, 0.290, 0.290, 0.3)  # Red with transparency
	glow.add_point(start_pos)
	glow.add_point(end_pos)

	# Get speed multiplier from parent Combat scene
	var speed_mult = _get_speed_multiplier()
	var adjusted_duration = duration * speed_mult

	# Fade out and remove
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(laser, "modulate:a", 0.0, adjusted_duration)
	tween.tween_property(glow, "modulate:a", 0.0, adjusted_duration)
	tween.chain().tween_callback(func():
		laser.queue_free()
		glow.queue_free()
	)

## Spawn a torpedo projectile that travels from start to end position
## duration: Travel time in seconds (will be multiplied by speed_multiplier)
func spawn_torpedo(start_pos: Vector2, end_pos: Vector2, duration: float = 0.5) -> void:
	var torpedo = ColorRect.new()
	add_child(torpedo)

	# Set up torpedo appearance
	torpedo.custom_minimum_size = Vector2(12, 8)
	torpedo.color = Color(0.290, 0.565, 0.886, 1.0)  # Blue
	torpedo.position = start_pos - torpedo.custom_minimum_size / 2

	# Add trail particles
	var trail = CPUParticles2D.new()
	torpedo.add_child(trail)
	trail.position = torpedo.custom_minimum_size / 2
	trail.amount = 20
	trail.lifetime = 0.3
	trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	trail.direction = Vector2(-1, 0)  # Trail behind
	trail.spread = 15.0
	trail.initial_velocity_min = 50.0
	trail.initial_velocity_max = 100.0
	trail.scale_amount_min = 2.0
	trail.scale_amount_max = 4.0
	trail.color = Color(0.886, 0.831, 0.290, 0.7)  # Yellow glow
	trail.emitting = true

	# Get speed multiplier
	var speed_mult = _get_speed_multiplier()
	var adjusted_duration = duration * speed_mult

	# Animate movement
	var tween = create_tween()
	tween.tween_property(torpedo, "position", end_pos - torpedo.custom_minimum_size / 2, adjusted_duration)
	tween.tween_callback(func():
		torpedo.queue_free()
	)

## Spawn shield impact effect at position
## radius: Radius of the shield ripple effect
## duration: Duration in seconds (will be multiplied by speed_multiplier)
func spawn_shield_impact(impact_pos: Vector2, radius: float = 40.0, duration: float = 0.4) -> void:
	# Create multiple expanding rings for ripple effect
	for i in range(3):
		var ring = _create_shield_ring(impact_pos, radius)

		# Get speed multiplier
		var speed_mult = _get_speed_multiplier()
		var adjusted_duration = duration * speed_mult
		var delay = i * 0.1 * speed_mult

		# Animate expansion and fade
		await get_tree().create_timer(delay).timeout
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(ring, "scale", Vector2(2.0, 2.0), adjusted_duration)
		tween.tween_property(ring, "modulate:a", 0.0, adjusted_duration)
		tween.chain().tween_callback(func():
			ring.queue_free()
		)

## Create a single shield ring for ripple effect
func _create_shield_ring(center: Vector2, radius: float) -> Node2D:
	var ring = Node2D.new()
	add_child(ring)
	ring.position = center

	# Draw circle with Line2D
	var circle = Line2D.new()
	ring.add_child(circle)
	circle.width = 3.0
	circle.default_color = Color(0.290, 0.886, 0.886, 0.8)  # Cyan
	circle.closed = true

	# Create circle points
	var points = 32
	for i in range(points + 1):
		var angle = (i / float(points)) * TAU
		var point = Vector2(cos(angle), sin(angle)) * radius
		circle.add_point(point)

	return ring

## Spawn hull impact particles at position
## particle_count: Number of particles to spawn
## duration: Particle lifetime in seconds (will be multiplied by speed_multiplier)
func spawn_hull_impact(impact_pos: Vector2, particle_count: int = 30, duration: float = 0.5) -> void:
	var particles = CPUParticles2D.new()
	add_child(particles)
	particles.position = impact_pos

	# Configure particles
	particles.amount = particle_count
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 5.0
	particles.direction = Vector2(0, 0)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 200)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0
	particles.color = Color(0.886, 0.290, 0.290, 1.0)  # Red
	particles.color_ramp = _create_fade_gradient()

	# Get speed multiplier and adjust lifetime
	var speed_mult = _get_speed_multiplier()
	particles.lifetime = duration * speed_mult

	particles.emitting = true

	# Clean up after particles finish
	await get_tree().create_timer(particles.lifetime).timeout
	particles.queue_free()

## Spawn muzzle flash at weapon position
## duration: Flash duration in seconds (will be multiplied by speed_multiplier)
func spawn_muzzle_flash(weapon_pos: Vector2, duration: float = 0.1) -> void:
	var flash = ColorRect.new()
	add_child(flash)

	# Set up flash appearance - circular white glow
	flash.custom_minimum_size = Vector2(20, 20)
	flash.color = Color(1.0, 1.0, 1.0, 0.9)
	flash.position = weapon_pos - flash.custom_minimum_size / 2

	# Get speed multiplier
	var speed_mult = _get_speed_multiplier()
	var adjusted_duration = duration * speed_mult

	# Fade out quickly
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "modulate:a", 0.0, adjusted_duration)
	tween.tween_property(flash, "scale", Vector2(1.5, 1.5), adjusted_duration)
	tween.chain().tween_callback(func():
		flash.queue_free()
	)

## Spawn screen shake effect
## intensity: Shake intensity in pixels
## duration: Shake duration in seconds (will be multiplied by speed_multiplier)
func spawn_screen_shake(intensity: float = 5.0, duration: float = 0.2) -> void:
	if camera == null:
		return

	# Get speed multiplier
	var speed_mult = _get_speed_multiplier()
	var adjusted_duration = duration * speed_mult

	# Save original position
	var original_offset = camera.offset

	# Shake with random offsets
	var shake_timer = 0.0
	var shake_interval = 0.05 * speed_mult

	while shake_timer < adjusted_duration:
		camera.offset = original_offset + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(shake_interval).timeout
		shake_timer += shake_interval

	# Restore original position
	camera.offset = original_offset

## Get speed multiplier from parent Combat scene
func _get_speed_multiplier() -> float:
	var combat = get_parent()
	if combat and combat.has_method("_get_speed_multiplier_value"):
		return combat._get_speed_multiplier_value()
	# Fallback: check if parent has speed_multiplier property
	if combat and "speed_multiplier" in combat:
		return combat.speed_multiplier
	return 1.0

## Create a gradient that fades to transparent (for particles)
func _create_fade_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.colors = [
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0)
	]
	gradient.offsets = [0.0, 1.0]
	return gradient
