extends CharacterBody2D


const WALK_SPEED = 150
const JUMP_VELOCITY = -275
const JUMP_CUT_MULTIPLIER = 0.5
const DASH_SPEED = 525
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.3
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1
const WALL_SLIDE_GRAVITY = 50
const WALL_JUMP_VELOCITY = Vector2(200, -350)
const WALL_JUMP_LOCKOUT_TIME = 0.1 

var start_position = global_position
var health = 5
var safe_position = global_position
var can_safe_position = true
var last_direct = 1.0
var can_dash = true
var dash_timer = 0
var dash_cooldown_timer = 0
var coyote_timer = 0
var jump_buffer_timer = 0

var is_wall_sliding = false
var wall_coyote_timer = 0.0
var wall_jump_lockout_timer = 0.0
var last_wall_normal_x = 0.0


func _physics_process(delta: float) -> void:
	# Смэртъ
	if health <= 0:
		die()

	# Апдейтим таймеры
	_update_timers(delta)

	# Апдейтим сейв-позицию
	_update_safe_position()

	var direct = Input.get_axis("left", "right")

	if direct != 0:
		last_direct = direct

	# --- Механика стены ---
	var wall_normal = get_wall_normal()
	var pushing_wall = (direct != 0) and (sign(direct) == -sign(wall_normal.x))

	if is_on_wall() and not is_on_floor() and pushing_wall:
		is_wall_sliding = true
		can_dash = true
		wall_coyote_timer = COYOTE_TIME # Запоминаем окно для прыжка
		last_wall_normal_x = wall_normal.x
	else:
		is_wall_sliding = false

	# --- Гравитация & coyote time ---
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	elif is_wall_sliding:
		velocity.y = WALL_SLIDE_GRAVITY
	else:
		velocity += get_gravity() * delta

	# --- Jump buffer & Прыжки ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0:
		# 1. Отскок от стены (работает и во время скольжения, и во время coyote time стены)
		if is_wall_sliding or wall_coyote_timer > 0:
			velocity.x = last_wall_normal_x * WALL_JUMP_VELOCITY.x
			velocity.y = WALL_JUMP_VELOCITY.y
			jump_buffer_timer = 0
			wall_coyote_timer = 0
			is_wall_sliding = false
			wall_jump_lockout_timer = WALL_JUMP_LOCKOUT_TIME # Блокируем смену ввода
			
		# 2. Обычный прыжок от земли
		elif is_on_floor() or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# --- Ходьба (применяется, только если не действует блокировка после отскока) ---
	if wall_jump_lockout_timer <= 0:
		velocity.x = WALK_SPEED * direct

	# --- Рывок ---
	if Input.is_action_just_pressed("dash") and can_dash:
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		can_dash = false

	if dash_timer > 0:
		velocity.y = 0
		velocity.x = DASH_SPEED * last_direct

	if is_on_floor() and dash_cooldown_timer < 0:
		can_dash = true

	move_and_slide()


func _update_timers(delta: float) -> void:
	dash_timer -= delta
	dash_cooldown_timer -= delta
	coyote_timer -= delta
	jump_buffer_timer -= delta
	wall_coyote_timer -= delta
	wall_jump_lockout_timer -= delta


func change_can_safe_position(can_safe_position_val: bool) -> void:
	can_safe_position = can_safe_position_val 


func _update_safe_position() -> void:
	if is_on_floor() and can_safe_position:
		safe_position = global_position


func take_damage_from_danger(damage: int) -> void:
	set_physics_process(false)
	health -= damage
	global_position = safe_position
	set_physics_process(true)


func die() -> void:
	global_position = start_position
	health = 5
