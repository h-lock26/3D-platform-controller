extends Node3D


const SPEED = 20.0

@onready var sprite = $Sprite3D
@onready var ray = $RayCast3D
@onready var gpu_particles_3d = $GPUParticles3D

@export var collide_with_bodies = true
@onready var animation_player = $AnimationPlayer

@onready var sound = $AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	animation_player.play("fire")
	if ray.is_colliding():
		sprite.visible = false
		ray.enabled = false
		gpu_particles_3d.emitting = true
		if ray.get_collider().is_in_group("enemy"):
			sound.play()
			ray.get_collider().queue_free()
		await get_tree().create_timer(1.5).timeout
		hide()


func _on_timer_timeout():
	queue_free()
