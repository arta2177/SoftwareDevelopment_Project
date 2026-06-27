extends CharacterBody2D

@export_category("Movement Variables")
@export var move_speed = 120.0
@export var decelaration = 0.1
@export var gravity = 250.0
var movement = Vector2()

@export_category("Jump Variable")
@export var jump_speed = 190.0
@export var acceleration = 290.0
@export var jump_amount = 2

@export_category("Wall Jump Variable")
@export var wall_slide = 10
@onready var ray_left: RayCast2D = $Raycast/ray_left
@onready var ray_right: RayCast2D = $Raycast/ray_right
@export var wall_x_force = 200.0
@export var wall_y_force = -220.0
var is_wall_jumping = false

@export_category("Dash Variable")
@export var dash_speed = 400.0
@export var facing_rightDir = true
@export var dash_gravity = 0
var dash_key_pressed = 0
var is_dashing = false
var dash_timer = Timer
@export var dash_cooldown = 0.6
var can_dash = true

func _physics_process(delta: float) -> void:
	
	velocity.y += gravity * delta
	
	horizontal_movement()
	jump_logic()
	wall_logic()
	change_dir()
	set_animations()
	
	move_and_slide()


func horizontal_movement():
	if is_wall_jumping == false:
		movement = Input.get_axis("left", "right")
		
		if movement:
			velocity.x = movement * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0 , move_speed * decelaration)
	
	if Input.is_action_just_pressed("dash") and dash_key_pressed == 0:
		dash_key_pressed = 1
		dash()
	if dash_key_pressed == 1 and movement != 0:
	
		dash()
		
	
salam :)
func set_animations():
	if velocity.x != 0:
		$AnimationPlayer.play("Move")
	if velocity.x == 0:
		$AnimationPlayer.play("Idle")
	if velocity.y < 0:
		$AnimationPlayer.play("Jump")
	if velocity.y < 0 && velocity.x !=0:
		$AnimationPlayer.play("Jump")
			
	if velocity.y > 10:
		$AnimationPlayer.play("Fall")
	if is_on_wall_only():
		$AnimationPlayer.play("Fall")

func change_dir():
	if velocity.x > 0.0:
		scale.x = scale.y * 1
		wall_x_force = 200.0
		facing_rightDir = true
	if velocity.x < 0.0:
		scale.x = scale.y * -1
		wall_x_force = -200.0
		facing_rightDir = false
	
func jump_logic():
	if is_on_floor():
		jump_amount = 5
		if Input.is_action_just_pressed("jump"):
			jump_amount -= 1
			velocity.y -= lerp(jump_speed, acceleration, 1)
			
	if not is_on_floor():
		if jump_amount > 0:
			if Input.is_action_just_pressed("jump"):
				jump_amount -= 1
				velocity.y -= lerp(jump_speed, acceleration , 1)
		
			if Input.is_action_just_released("jump"):
				velocity.y = lerp(velocity.y , gravity , 0.2)
				velocity.y *=  0.3
			
	else:
		return			
		
func wall_logic():
	if is_on_wall_only():
		velocity.y = 10	
	if Input.is_action_just_pressed("jump"):
		#if ray_left.is_colliding():
			#velocity = Vector2(wall_x_force, wall_y_force)
			#wall_jumping()
		if ray_right.is_colliding():
			jump_amount = 2
			velocity = Vector2(-wall_x_force, wall_y_force)
			wall_jumping()
			
func wall_jumping():
	is_wall_jumping = true
	await get_tree().create_timer(0.12).timeout
	is_wall_jumping = false

func dash():
	if dash_key_pressed == 1:
		is_dashing = true
	else:
		is_dashing = false
	
	if facing_rightDir == true :
		velocity.x = dash_speed
		velocity.y = 0
		dash_started()
	if facing_rightDir == false:
		velocity.x = -dash_speed
		velocity.y = 0
		dash_started()
		
func dash_started():
	if is_dashing == true:
		dash_key_pressed = 1
		await get_tree().create_timer(0.3).timeout
		is_dashing = false
		dash_key_pressed = 0
		can_dash = false

	else:
		return
