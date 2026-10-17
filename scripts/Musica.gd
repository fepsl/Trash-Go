extends Node
## Música e preferências independentes da fase e dos efeitos sonoros.

const ARQUIVO_CONFIG := "user://audio.cfg"
const VOLUME_PADRAO: float = 25.0

var volume: float = VOLUME_PADRAO
var silenciada: bool = false
var _player: AudioStreamPlayer
var _timer_salvar: Timer

signal volume_mudou(valor: float, sem_som: bool)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config := ConfigFile.new()
	if config.load(ARQUIVO_CONFIG) == OK:
		var salvo: Variant = config.get_value("musica", "volume", VOLUME_PADRAO)
		if (salvo is float or salvo is int) and is_finite(float(salvo)):
			volume = clampf(float(salvo), 0.0, 100.0)
		var mudo: Variant = config.get_value("musica", "silenciada", false)
		if mudo is bool:
			silenciada = mudo
	_player = AudioStreamPlayer.new()
	_player.name = "TrilhaSonora"
	# A playlist longa precisa ser decodificada aos poucos; no modo Sample,
	# a exportação Web tenta alocar a faixa inteira e esgota a memória.
	_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	var trilha := preload("res://assets/sounds/musica_lofi.ogg") as AudioStreamOggVorbis
	trilha.loop = true
	_player.stream = trilha
	add_child(_player)
	_timer_salvar = Timer.new()
	_timer_salvar.one_shot = true
	_timer_salvar.wait_time = 0.35
	_timer_salvar.timeout.connect(salvar_preferencias)
	add_child(_timer_salvar)
	_aplicar_volume()
	_player.play()

func definir_volume(valor: float) -> void:
	if not is_finite(valor):
		return
	volume = clampf(valor, 0.0, 100.0)
	# Mover o controle permite voltar a ouvir após usar o botão de silenciar.
	if volume > 0.0:
		silenciada = false
	_aplicar_volume()
	volume_mudou.emit(volume, silenciada)
	_timer_salvar.start()

func alternar_silencio() -> void:
	silenciada = not silenciada
	_aplicar_volume()
	volume_mudou.emit(volume, silenciada)
	salvar_preferencias()

func _aplicar_volume() -> void:
	_player.volume_linear = 0.0 if silenciada else volume / 100.0

func salvar_preferencias() -> void:
	var config := ConfigFile.new()
	config.set_value("musica", "volume", volume)
	config.set_value("musica", "silenciada", silenciada)
	var erro := config.save(ARQUIVO_CONFIG)
	if erro != OK:
		push_warning("Não foi possível salvar o volume da música: %s" % error_string(erro))

func _exit_tree() -> void:
	salvar_preferencias()
