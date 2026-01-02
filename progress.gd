extends Node

const SAVE_PATH = "user://night_progress.dat"
const DIFFICULTY_PATH = "user://difficulty.dat"

func _read_file(path: String, fallback):
	if !FileAccess.file_exists(path):
		return fallback
	
	var file = FileAccess.open(path, FileAccess.READ)
	return file.get_var()

func _write_file(path, variable):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(variable)

func save_difficulty(difficulty: String):
	_write_file(DIFFICULTY_PATH, difficulty)

func load_difficulty() -> String:
	return _read_file(DIFFICULTY_PATH, "normal")

func save_progress(night: int):
	if night == 5:
		night = 4
	# guarda o número da noite num arquivo
	_write_file(SAVE_PATH, night)

func load_progress() -> int:
	# se não tem progresso registrado, começa da noite 1
	# se tiver, pega o progresso já existente
	return _read_file(SAVE_PATH, 1)

func delete_progress():
	# deletar o arquivo por completo
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
