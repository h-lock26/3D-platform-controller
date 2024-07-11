extends CharacterBody3D


var SPEED = 6.0
var JUMP_VELOCITY = 6

@onready var animation_player = $AnimationPlayer
@onready var player_sprite = $PlayerSprite
@onready var water_sprite = $CamOrigin/SpringArm3D/Camera3D/water_sprite
@onready var crickets = $CamOrigin/SpringArm3D/Camera3D/AudioStreamPlayer3D2
@onready var music = $CamOrigin/SpringArm3D/Camera3D/AudioStreamPlayer3D3

@onready var pivot = $CamOrigin
@export var sens = 0.5
@onready var camera_3d = $CamOrigin/SpringArm3D/Camera3D
@onready var ray_cast_3d = $RayCast3D
@onready var jump_player = $AudioStreamPlayer3D
@onready var shoot_player = $AudioStreamPlayer3D2
@onready var hurt = $AudioStreamPlayer3D3
@onready var door = $AudioStreamPlayer3D4
@onready var transition = $"../CanvasLayer/transition"

var bullet = load("res://scenes/bullet.tscn")
var instance
var shot_cooldown = .5
var time_shot = 0

@export var jump_count = 0
@export var max_jumps = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		
func _physics_process(delta):
	
	if position.y < -10 or Global.health < 1:
		get_tree().reload_current_scene()
		Global.key_count = 0
		Global.health = 200
	
	if position.y < -2:
		gravity = 7
		JUMP_VELOCITY = 1
		max_jumps = 100
		player_sprite.modulate = Color.BLUE
		camera_3d.fov = 75
		water_sprite.visible = true
	else:
		gravity = 9
		JUMP_VELOCITY = 6
		max_jumps = 0
		player_sprite.modulate = Color.WHITE
		camera_3d.fov = 90
		water_sprite.visible = false
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and jump_count <= max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_player.play()
	if Input.is_action_just_pressed("jump") and !is_on_floor():
		jump_count = jump_count + 1
		
		
	if is_on_floor():
		jump_count = 0
		
	time_shot += delta
		
	if Input.is_action_just_pressed("shoot") and time_shot >= shot_cooldown:
		time_shot = 0
		instance = bullet.instantiate()
		instance.position = ray_cast_3d.global_position
		instance.transform.basis = ray_cast_3d.global_transform.basis
		get_parent().add_child(instance)
		shoot_player.play()
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("shoot"):
		pass
	
	
	print(Global.health)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
		
	if Input.is_action_pressed("left"):
		player_sprite.flip_h = true
	if Input.is_action_pressed("right"):
		player_sprite.flip_h = false
		
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("left") and is_on_floor():
		animation_player.play("run")
	elif is_on_floor():
		animation_player.play("idle")
	elif not is_on_floor():
		animation_player.play("jump")
		
	if not crickets.playing:
		crickets.play()
	if not music.playing:
		music.play()
	

	move_and_slide()
	


func health_remove():
	Global.health = Global.health -1
	hurt.play()
