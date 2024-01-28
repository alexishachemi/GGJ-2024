extends RigidBody2D

@export
var scaleX = 0.0
@export
var scaleY = 0.0

@onready var label = $Label
@onready var label_base_scale = label.scale
@onready var label_base_pos = label.position
var reset_state = false
var moveVector: Vector2

@rpc("any_peer","call_remote","reliable")
func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(0.0, moveVector)
		reset_state = false

func move_body(targetPos: Vector2):
	moveVector = targetPos
	reset_state = true

func set_word(word: String):
	label.text = word
	var default_size = label.get_theme_default_font_size() / 2
	var words = label.text.length()
	var shape = CapsuleShape2D.new()
	shape.radius = default_size * scaleY
	shape.height = default_size * words * scaleX
	$CollisionShape2D.shape = shape

func _process(delta):
	var vp = get_viewport_rect()

func _physics_process(_delta):
	if rotation_degrees > 120 or rotation_degrees < -120:
		label.scale = -label_base_scale
		label.position = -label_base_pos
	else:
		label.scale = label_base_scale
		label.position = label_base_pos

func spawn(pos: Vector2):
	move_body(pos)

