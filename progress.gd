extends Node

const SAVE_PATH = "user://night_progress.dat"

func save_progress(night: int):
	# guarda o número da noite num arquivo
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(night)

func load_progress() -> int:
	# se não tem progresso registrado, começa da noite 1
	if !FileAccess.file_exists(SAVE_PATH):
		return 1
	
	# se tiver, pega esse progresso
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	return file.get_var()

func delete_progress():
	# deletar o arquivo por completo
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
