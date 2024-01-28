extends Node2D

var spawn: bool = false

@export_range(1, 10)
var nb_subjects: int

@export_range(1, 10)
var nb_verbs: int

@export_range(1, 10)
var nb_complements: int

@export_range(0.5, 5)
var cooldown_range

const words_path: String = "words.json"
var words_ref: Dictionary = {}
var words: Dictionary = {}
@onready var cd = $Cooldown
@onready var collectible_bp = preload("res://Scenes/word_collectible/wordCollectible.tscn")

func _pick_words(type: String, nb_words: int):
	if words_ref == {}:
		parse_words()
	if nb_words <= 0:
		nb_words = 1
	var words_to_pick = words_ref[type].duplicate()
	for i in range(nb_words):
		words[type].append(words_to_pick.pop_at(randi_range(0, words_to_pick.size() - 1)))

func reload_words():
	if words == {}:
		words = {"subjects": [], "verbs": [], "complements": []}
	_pick_words("subjects", nb_subjects)
	_pick_words("verbs", nb_verbs)
	_pick_words("complements", nb_verbs)

func parse_words():
	var file = FileAccess.open(words_path, FileAccess.READ)
	words_ref = JSON.parse_string(file.get_as_text())

func _pop_word(type: String):
	randomize()
	if words == {} or words[type].is_empty():
		return null
	return words[type].pop_at(randi_range(0, words[type].size() - 1))

func pop_subject():
	return _pop_word("subjects")

func pop_verb():
	return _pop_word("verbs")

func pop_complement():
	return _pop_word("complements")

@rpc("any_peer")
func _spawn_word():
	var word = pop_subject()
	
	if word == null:
		word = pop_verb()
	if word == null:
		word = pop_complement()
	
	if word == null:
		reload_words()
		spawn_word()
	else:
		var collectible = collectible_bp.instantiate()
		add_child(collectible, true)
		var vp = get_viewport_rect()
		collectible.spawn(Vector2(0,0)) #randi_range(vp.position.x, vp.position.x + vp.size.x), vp.position.y))
		collectible.set_word(word)

func spawn_word():
	rpc("_spawn_word")

func _ready():
	if not (User.host_name in User.peers.values()):
		set_multiplayer_authority(User.ID)
		spawn = true

func _process(delta):
	if spawn and cd.is_stopped():
		cd.start()

func _on_cooldown_timeout():
	spawn_word()
