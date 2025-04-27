extends Node2D
class_name Level

@export var asteroid_scene: PackedScene

@export var spawn_circle_radius: float = 350.0
@export var asteroid_direction_variance: float = 15.0

@onready var border_rect: ReferenceRect = %BorderRect
@onready var asteroids_container: Node2D = $Asteroids
@onready var game_over: Control = %GameOver

var screen_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

func spawn_asteroid_on_border() -> void:
	var screen_center = screen_size * 0.5
	var angle = randf_range(0.0, TAU)
	
	var dir_to_point = Vector2.RIGHT.rotated(angle)
	var spawn_point = (screen_center + dir_to_point * spawn_circle_radius).clamp(
		border_rect.global_position,
		border_rect.global_position + border_rect.size
	)
	
	var dir_to_center = spawn_point.direction_to(screen_center)
	var asteroid_dir = dir_to_center.rotated(randfn(0.0, deg_to_rad(asteroid_direction_variance)))
	var asteroid_size = randi_range(0, Asteroid.SIZE.size() - 1)
	
	spawn_asteroid(spawn_point, asteroid_dir, asteroid_size)

func spawn_asteroid(pos: Vector2, dir: Vector2, size: Asteroid.SIZE) -> void:
	var asteroid = asteroid_scene.instantiate()
	asteroids_container.add_child.call_deferred(asteroid)
	
	asteroid.position = pos
	asteroid.direction = dir
	asteroid.size = size
	
	asteroid.destroyed.connect(_on_asteroid_destroyed.bind(asteroid))

func _on_asteroid_destroyed(asteroid: Asteroid) -> void:
	if asteroid.size > 0:
		for i in range(randi_range(2, 3)):
			var rot = deg_to_rad(([-1, 1].pick_random()) * (90.0 + randfn(0.0, asteroid_direction_variance)))
			var new_dir = asteroid.direction.rotated(rot)
			
			spawn_asteroid(asteroid.global_position, new_dir, asteroid.size - 1)

func _on_spawn_timer_timeout() -> void:
	spawn_asteroid_on_border()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_player_destroyed() -> void:
	game_over.show()

func _ready() -> void:
	AudioManagerSingleton.play_sfx("soundscape", false)
