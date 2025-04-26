extends CharacterBody2D

@export_range(0.0, 1.0) var accel_factor :float = 0.1
@export_range(0.0, 1.0) var rotation_accel_factor :float = 0.1
@export var max_speed : float = 200.0
@export var projectile_scene : PackedScene

var speed : float = 0.0

var direction := Vector2.ZERO
var last_direction := Vector2.ZERO

signal projectile_fired(projectile)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	move()
	rotate_towar_mouse()

func _input(event: InputEvent) -> void:
	direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if direction != Vector2.ZERO:
		last_direction = direction
	
	if event.is_action_pressed("fire"):
		fire()

func fire() -> void:
	var projectile = projectile_scene.instantiate()
	projectile.transform = global_transform
	projectile.rotation = rotation
	projectile_fired.emit(projectile)

func move() -> void:
	# accelaration
	if direction == Vector2.ZERO:
		speed = lerp(speed, 0.0, accel_factor)
	else:
		speed = lerp(speed, max_speed, accel_factor)
		
	# move ship
	velocity = last_direction * speed
	move_and_slide()
	
func rotate_towar_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	var angle = global_position.angle_to_point(mouse_pos)
	rotation = lerp_angle(rotation, angle, rotation_accel_factor)
