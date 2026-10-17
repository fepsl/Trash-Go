extends CanvasLayer

const Estilo = preload("res://scripts/MenuEstilo.gd")
var _som_botao: AudioStreamPlayer
var _botao_jogar: Button
var _conteudo: Control
var _entrada: Tween
var _iniciando: bool = false

func _ready() -> void:
	_som_botao = AudioStreamPlayer.new()
	_som_botao.stream = preload("res://assets/sounds/bassattack.ogg")
	_som_botao.volume_db = -8.0
	add_child(_som_botao)
	_montar_interface()
	GameManager.estado_mudou.connect(_on_estado_mudou)
	_atualizar_visibilidade(GameManager.estado_atual)

func _montar_interface() -> void:
	_conteudo = Estilo.conteudo($Interface)
	var coluna := Estilo.coluna(_conteudo, Vector2(0, 18), Vector2(470, 510), 18)
	Estilo.texto(coluna, "UMA NOVA CHANCE PARA A CIDADE", 14, Estilo.OURO)
	Estilo.icone(coluna, preload("res://assets/ui/menu/logo_trash_go.svg"), Vector2(470, 180))
	var descricao := Estilo.texto(coluna, "O futuro começa com o que você recolhe.", 22)
	descricao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var detalhe := Estilo.texto(coluna, "Enfrente o lixo. Recupere materiais.\nVolte mais forte a cada jornada.", 18, Estilo.SUAVE)
	detalhe.add_theme_constant_override("line_spacing", 5)
	var espaco := Control.new()
	espaco.custom_minimum_size.y = 10
	coluna.add_child(espaco)
	_botao_jogar = Estilo.botao(coluna, "COMEÇAR JORNADA   →", true)
	_botao_jogar.name = "BotaoJogar"
	_botao_jogar.custom_minimum_size.y = 64
	_botao_jogar.pressed.connect(_on_jogar_pressed)
	var controles := HBoxContainer.new()
	controles.add_theme_constant_override("separation", 12)
	coluna.add_child(controles)
	Estilo.icone(controles, preload("res://assets/ui/menu/mouse.svg"), Vector2(24, 30))
	Estilo.texto(controles, "Clique esquerdo para atacar", 15, Estilo.SUAVE)
	Estilo.texto(coluna, "Seu personagem avança automaticamente.", 14, Estilo.SUAVE)
	var rodape := Estilo.texto(_conteudo, "RECOLHER  /  RECICLAR  /  RECOMEÇAR", 13, Estilo.SUAVE)
	rodape.position = Vector2(0, 565)
	var local := Estilo.texto(_conteudo, "01  /  CIDADE\nO primeiro passo é seu.", 15, Estilo.CREME)
	local.position = Vector2(860, 520)
	local.add_theme_constant_override("line_spacing", 6)

func _on_jogar_pressed() -> void:
	if _iniciando or GameManager.estado_atual != GameManager.Estado.INICIO:
		return
	_iniciando = true
	_botao_jogar.disabled = true
	_som_botao.play()
	if _entrada and _entrada.is_valid():
		_entrada.kill()
	var transicao := create_tween()
	transicao.tween_property(_conteudo, "modulate:a", 0.0, 0.18)
	transicao.tween_callback(func(): GameManager.mudar_estado(GameManager.Estado.JOGANDO))

func _on_estado_mudou(novo_estado: GameManager.Estado) -> void:
	_atualizar_visibilidade(novo_estado)

func _atualizar_visibilidade(estado: GameManager.Estado) -> void:
	visible = estado == GameManager.Estado.INICIO
	$Interface/Cenario.set_process(visible)
	if visible:
		_iniciando = false
		_botao_jogar.disabled = false
		if _entrada and _entrada.is_valid():
			_entrada.kill()
		_entrada = Estilo.aparecer(_conteudo)
		_botao_jogar.grab_focus()
