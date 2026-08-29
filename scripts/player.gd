extends CharacterBody2D

const WALK_SPEED = 125.0
var JUMP_VELOCITY = -300.0
const JUMP_CUT_MULTIPLIER = 0.5
const DASH_SPEED = 475.0
const DASH_DURATION = 0.2
const UP_DASH_DURATION = 0.06
const DASH_COOLDOWN = 0.3
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1
var WALL_SLIDE_GRAVITY = 50.0
var WALL_JUMP_VELOCITY = Vector2(200.0, -350.0)
const WALL_JUMP_LOCKOUT_TIME = 0.1 

var is_gravity_changed: bool = false
var grav_dir: float = 1.0 

var start_position: Vector2
var safe_position: Vector2
var can_safe_position: bool = true
var last_direct: float = 1.0
var can_dash: bool = true

var dash_timer: float = 0.0
var up_dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var wall_coyote_timer: float = 0.0
var wall_jump_lockout_timer: float = 0.0

var is_wall_sliding: bool = false
var last_wall_normal_x: float = 0.0

signal hp_changed(new_hp)
var hp: int = 3:
	set(value):
		hp = value
		hp_changed.emit(hp)


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	start_position = global_position
	safe_position = global_position


func _physics_process(delta: float) -> void:
	if hp <= 0:
		die()
		return 

	_update_timers(delta)
	_update_safe_position()

	var direct = Input.get_axis("left", "right")
	if direct != 0:
		last_direct = sign(direct)

	var wall_normal = get_wall_normal()
	var pushing_wall = (direct != 0) and (sign(direct) == -sign(wall_normal.x))

	if is_on_wall() and not is_on_floor() and pushing_wall:
		is_wall_sliding = true
		can_dash = true
		wall_coyote_timer = COYOTE_TIME
		last_wall_normal_x = wall_normal.x
	else:
		is_wall_sliding = false

	# Состояние земли & coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		if dash_cooldown_timer <= 0:
			can_dash = true

	if dash_timer <= 0 and up_dash_timer <= 0:
		var is_falling = (velocity.y * grav_dir) > 0
		if is_wall_sliding and is_falling:
			velocity.y = WALL_SLIDE_GRAVITY * grav_dir
		else:
			velocity += get_gravity() * grav_dir * delta

	# Ввод дэша
	if Input.is_action_just_pressed("dash") and can_dash:
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		can_dash = false

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0:
		if is_wall_sliding or wall_coyote_timer > 0:
			velocity.x = last_wall_normal_x * WALL_JUMP_VELOCITY.x
			velocity.y = WALL_JUMP_VELOCITY.y * grav_dir
			jump_buffer_timer = 0.0
			wall_coyote_timer = 0.0
			is_wall_sliding = false
			wall_jump_lockout_timer = WALL_JUMP_LOCKOUT_TIME
			
		elif is_on_floor() or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY * grav_dir
			jump_buffer_timer = 0.0
			coyote_timer = 0.0

	var is_moving_up = (velocity.y * grav_dir) < 0
	if Input.is_action_just_released("jump") and is_moving_up:
		velocity.y *= JUMP_CUT_MULTIPLIER

	if dash_timer > 0:
		velocity.y = 0.0
		velocity.x = DASH_SPEED * last_direct
	elif up_dash_timer > 0:
		velocity.x = WALK_SPEED * direct 
		velocity.y = -DASH_SPEED * grav_dir
	else:
		if wall_jump_lockout_timer <= 0:
			velocity.x = WALK_SPEED * direct

	move_and_slide()


func _update_timers(delta: float) -> void:
	dash_timer -= delta
	dash_cooldown_timer -= delta
	coyote_timer -= delta
	jump_buffer_timer -= delta
	wall_coyote_timer -= delta
	wall_jump_lockout_timer -= delta
	up_dash_timer -= delta


func change_can_safe_position(can_safe_position_val: bool) -> void:
	can_safe_position = can_safe_position_val 


func _update_safe_position() -> void:
	if is_on_floor() and can_safe_position:
		safe_position = global_position


func take_damage_from_danger(damage: int) -> void:
	hp -= damage
	if hp > 0:
		global_position = safe_position
		velocity = Vector2.ZERO


func die() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	hp = 3


func up_dash() -> void:
	up_dash_timer = UP_DASH_DURATION
	can_dash = true


func change_gravity() -> void:
	is_gravity_changed = !is_gravity_changed
	grav_dir = -1.0 if is_gravity_changed else 1.0
	
	up_direction = Vector2.DOWN if is_gravity_changed else Vector2.UP
	
	# Визуально переворачиваем персонажа по вертикали
	scale.y = -abs(scale.y) if is_gravity_changed else abs(scale.y)
