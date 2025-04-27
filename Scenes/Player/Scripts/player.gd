extends CharacterBody2D
class_name Player

@export_range(0.0, 1.0) var accel_factor: float = 0.1
@export_range(0.0, 1.0) var rotation_accel_factor: float = 0.1
@export var max_speed: float = 200.0
@export var projectile_scene: PackedScene

var speed: float = 0.0
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

signal projectile_fired(projectile)
signal destroyed

var screen_size: Vector2

func _ready() -> void:
    screen_size = Vector2(
        ProjectSettings.get_setting("display/window/size/viewport_width"),
        ProjectSettings.get_setting("display/window/size/viewport_height")
    )

func _physics_process(_delta: float) -> void:
    move()
    rotate_toward_mouse()
    wrap_around_screen()

func _input(event: InputEvent) -> void:
    direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    if direction != Vector2.ZERO:
        last_direction = direction

    if event.is_action_pressed("fire"):
        fire()

func fire() -> void:
    AudioManagerSingleton.play_sfx("fire", true)
    var projectile = projectile_scene.instantiate()
    projectile.transform = global_transform
    projectile.rotation = rotation
    projectile_fired.emit(projectile)
	

func move() -> void:
    # Acceleration
    if direction == Vector2.ZERO:
        speed = lerp(speed, 0.0, accel_factor)
    else:
        speed = lerp(speed, max_speed, accel_factor)

    velocity = last_direction * speed
    move_and_slide()

func rotate_toward_mouse() -> void:
    var mouse_pos = get_global_mouse_position()
    var angle = global_position.angle_to_point(mouse_pos)
    rotation = lerp_angle(rotation, angle, rotation_accel_factor)

func wrap_around_screen() -> void:
    if global_position.x < 0:
        global_position.x = screen_size.x
    elif global_position.x > screen_size.x:
        global_position.x = 0

    if global_position.y < 0:
        global_position.y = screen_size.y
    elif global_position.y > screen_size.y:
        global_position.y = 0

func destroy() -> void:
    destroyed.emit()
    queue_free()