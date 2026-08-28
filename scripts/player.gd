extends CharacterBody2D


const WALK_SPEED = 150
const JUMP_VELOCITY = -275
const JUMP_CUT_MULTIPLIER = 0.5
const DASH_SPEED = 525
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.3
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

var START_POSITION = global_position
var health = 5
var safe_position = global_position
var can_safe_position = true
var last_direct = 1.0
var can_dash = true
var dash_timer = 0
var dash_cooldown_timer = 0
var coyote_timer = 0
var jump_buffer_timer = 0


func _physics_process(delta: float) -> void:
	# Смэртъ

	if health <= 0:
		die()

	# Апдейтим таймеры
	_update_timers(delta)

	# Апдейтим сейв-позицию
	_update_safe_position()

	# Гравитация & coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		velocity += get_gravity() * delta

	# Jump buffer & прыжок
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0):	
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

	if Input.is_action_just_released("jump"):
		velocity.y *= JUMP_CUT_MULTIPLIER

	# Ходьба
	var direct = Input.get_axis("left", "right")

	if direct != 0:
		last_direct = direct

	velocity.x = WALK_SPEED * direct

	# Рывок
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
	global_position = START_POSITION
	health = 5
