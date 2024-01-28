extends TextureRect

var personalities = []

func load_json_file(filePath: String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading file")
	else:
		print("File doesn't exist!")

func _ready():
	var json_data = load_json_file("res://personality.json")

	if json_data.size() > 0:
		personalities = json_data["personalities"]
		if personalities == null:
			print("Le fichier JSON ne contient pas de nœud 'personalities'")
		else:
			print("JE SUIS PASSÉ PAR LÀ")
			display_random_personalities()
	else:
		print("Impossible de charger le fichier JSON")

func display_random_personalities():
	var random_personality = personalities[randi() % personalities.size()]
	var image_path = random_personality.image_path
	print(image_path)
	texture = load(image_path)
	self.texture = texture
