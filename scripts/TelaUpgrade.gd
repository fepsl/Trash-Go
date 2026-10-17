extends CanvasLayer

const Estilo = preload("res://scripts/MenuEstilo.gd")
const NOMES_FASE: Array[String] = ["Cidade", "Aterro", "Rio", "Fábrica"]
const MELHORIAS: Array[Dictionary] = [
	{"chave": "vida", "titulo": "Vitalidade", "subtitulo": "Fôlego para ir além", "icone": preload("res://assets/HUD/pixel/heart.svg"), "cor": Color("ee9391")},
	{"chave": "dano", "titulo": "Impacto", "subtitulo": "Cada golpe faz diferença", "icone": preload("res://assets/ui/menu/dano.svg"), "cor": Color("efbe78")},
	{"chave": "recarga", "titulo": "Cadência", "subtitulo": "Mantenha o ritmo", "icone": preload("res://assets/ui/menu/recarga.svg"), "cor": Color("a9ccdf")},
	{"chave": "velocidade", "titulo": "Agilidade", "subtitulo": "Sempre um passo à frente", "icone": preload("res://assets/ui/menu/velocidade.svg"), "cor": Color("a5e6a1")},
]

var _som_botao: AudioStreamPlayer
var _conteudo: Control
var _label_materiais: Label
var _label_destino: Label
var _feedback: Label
var _botao_continuar: Button
var _cartoes: Dictionary = {}
var _entrada: Tween
var _ultimo_poder: String = ""

func _ready() -> void:
	_som_botao = AudioStreamPlayer.new()
	_som_botao.stream = preload("res://assets/sounds/bassattack.ogg")
	_som_botao.volume_db = -8.0
	add_child(_som_botao)
	_montar_interface()
	GameManager.estado_mudou.connect(_on_estado_mudou)
	GameManager.poder_concedido.connect(_on_poder_concedido)
	GameManager.material_coletado.connect(_on_material_coletado)
	_on_estado_mudou(GameManager.estado_atual)

func _montar_interface() -> void:
	_conteudo = Estilo.conteudo($Interface)
	var cabecalho := Estilo.coluna(_conteudo, Vector2.ZERO, Vector2(750, 110), 5)
	Estilo.texto(cabecalho, "UMA PAUSA PARA EVOLUIR", 14, Estilo.VERDE)
	Estilo.texto(cabecalho, "Oficina de reciclagem", 38)
	Estilo.texto(cabecalho, "Transforme o que você recolheu em força para continuar.", 18, Estilo.SUAVE)
	var carteira := PanelContainer.new()
	carteira.position = Vector2(870, 5)
	carteira.size = Vector2(250, 100)
	carteira.add_theme_stylebox_override("panel", Estilo.caixa(Color("172b30"), Color("658775")))
	_conteudo.add_child(carteira)
	var saldo := HBoxContainer.new()
	saldo.add_theme_constant_override("separation", 16)
	carteira.add_child(saldo)
	Estilo.icone(saldo, preload("res://assets/HUD/pixel/material.svg"), Vector2(38, 38))
	var numeros := VBoxContainer.new()
	numeros.add_theme_constant_override("separation", 0)
	saldo.add_child(numeros)
	Estilo.texto(numeros, "MATERIAIS", 12, Estilo.SUAVE)
	_label_materiais = Estilo.texto(numeros, "0", 30, Estilo.VERDE)
	_label_materiais.name = "LabelMateriais"
	var grade := HBoxContainer.new()
	grade.position = Vector2(0, 145)
	grade.size = Vector2(1120, 310)
	grade.add_theme_constant_override("separation", 16)
	_conteudo.add_child(grade)
	for dados in MELHORIAS:
		_criar_cartao(grade, dados)
	var rodape := Estilo.coluna(_conteudo, Vector2(0, 485), Vector2(710, 90), 8)
	_feedback = Estilo.texto(rodape, "Escolha suas melhorias ou siga para a próxima fase.", 16, Estilo.VERDE)
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label_destino = Estilo.texto(rodape, "", 14, Estilo.SUAVE)
	_botao_continuar = Estilo.botao(_conteudo, "CONTINUAR   →", true)
	_botao_continuar.name = "BotaoContinuar"
	_botao_continuar.position = Vector2(820, 495)
	_botao_continuar.size = Vector2(300, 64)
	_botao_continuar.pressed.connect(_on_continuar_pressed)

func _criar_cartao(pai: Node, dados: Dictionary) -> void:
	var chave: String = dados["chave"]
	var cor: Color = dados["cor"]
	var painel := PanelContainer.new()
	painel.name = "Cartao" + chave.capitalize()
	painel.custom_minimum_size = Vector2(268, 310)
	painel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	painel.add_theme_stylebox_override("panel", Estilo.caixa(Color(0.055, 0.095, 0.125, 0.97), cor.darkened(0.5)))
	pai.add_child(painel)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 10)
	painel.add_child(coluna)
	var topo := HBoxContainer.new()
	topo.add_theme_constant_override("separation", 16)
	coluna.add_child(topo)
	Estilo.icone(topo, dados["icone"], Vector2(48, 48))
	var nivel := Estilo.texto(topo, "NÍVEL 00", 13, cor)
	nivel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nivel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	nivel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	Estilo.texto(coluna, dados["titulo"], 25)
	Estilo.texto(coluna, dados["subtitulo"], 13, Estilo.SUAVE)
	Estilo.linha(coluna, cor.darkened(0.6))
	var efeito := Estilo.texto(coluna, "", 17, cor)
	efeito.custom_minimum_size.y = 52
	efeito.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var espaco := Control.new()
	espaco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(espaco)
	var custo := Estilo.texto(coluna, "", 13, Estilo.SUAVE)
	var botao := Estilo.botao(coluna, "MELHORAR", false, cor)
	botao.name = "Botao" + chave.capitalize()
	match chave:
		"vida": botao.pressed.connect(_on_vida_pressed)
		"dano": botao.pressed.connect(_on_dano_pressed)
		"recarga": botao.pressed.connect(_on_recarga_pressed)
		"velocidade": botao.pressed.connect(_on_velocidade_pressed)
	_cartoes[chave] = {"nivel": nivel, "efeito": efeito, "custo": custo, "botao": botao}

func _on_poder_concedido(poder: String) -> void:
	_ultimo_poder = poder

func _on_material_coletado(_quantidade: int) -> void:
	if visible:
		_atualizar_botoes()

func _on_estado_mudou(estado: GameManager.Estado) -> void:
	visible = estado == GameManager.Estado.UPGRADE
	$Interface/Cenario.set_process(visible)
	if estado == GameManager.Estado.INICIO:
		_ultimo_poder = ""
	if visible:
		$Interface/Cenario.fase = GameManager.fase_atual
		$Interface/Cenario.queue_redraw()
		_atualizar_botoes()
		_label_destino.text = "PRÓXIMA PARADA  /  %02d · %s    /    CICLO %02d" % [GameManager.fase_atual, NOMES_FASE[GameManager.fase_atual - 1].to_upper(), GameManager.num_loops + 1]
		_feedback.text = "Poder recebido: %s. Prepare-se para a próxima parada." % _ultimo_poder if not _ultimo_poder.is_empty() else "Escolha suas melhorias ou siga para a próxima fase."
		if _entrada and _entrada.is_valid():
			_entrada.kill()
		_entrada = Estilo.aparecer(_conteudo)
		_botao_continuar.grab_focus()

func _atualizar_botoes() -> void:
	_label_materiais.text = str(GameManager.materiais)
	for dados in MELHORIAS:
		var chave: String = dados["chave"]
		var nivel: int = GameManager.get("nivel_upgrade_" + chave)
		var base: int = GameManager.get("CUSTO_BASE_" + chave.to_upper())
		var custo := GameManager.custo_upgrade(base, nivel)
		var cartao: Dictionary = _cartoes[chave]
		var botao: Button = cartao["botao"]
		cartao["nivel"].text = "NÍVEL %02d" % nivel
		cartao["custo"].text = "CUSTO  /  %d materiais" % custo
		botao.disabled = GameManager.materiais < custo
		botao.text = "FALTAM %d MAT." % (custo - GameManager.materiais) if botao.disabled else "MELHORAR   +"
		match chave:
			"vida": cartao["efeito"].text = "+%d de vida máxima\nRestaura toda a vida" % (25 + GameManager.num_loops * 15)
			"dano": cartao["efeito"].text = "+%d de dano\nem cada ataque" % (5 + GameManager.num_loops * 3)
			"recarga": cartao["efeito"].text = "Melhora a recarga\ndos seus ataques"
			"velocidade": cartao["efeito"].text = "+%d de velocidade\npara seguir em frente" % (20 + GameManager.num_loops * 10)

func _comprar(chave: String, nome: String) -> bool:
	if GameManager.estado_atual != GameManager.Estado.UPGRADE:
		return false
	var nivel: int = GameManager.get("nivel_upgrade_" + chave)
	var base: int = GameManager.get("CUSTO_BASE_" + chave.to_upper())
	var custo := GameManager.custo_upgrade(base, nivel)
	if GameManager.materiais < custo:
		return false
	_som_botao.play()
	GameManager.materiais -= custo
	GameManager.set("nivel_upgrade_" + chave, nivel + 1)
	GameManager.material_coletado.emit(0)
	_feedback.text = "%s aprimorada!  −%d materiais  ·  Nível %02d" % [nome, custo, nivel + 1]
	return true

func _on_vida_pressed() -> void:
	if not _comprar("vida", "Vitalidade"):
		return
	GameManager.vida_maxima += 25 + GameManager.num_loops * 15
	GameManager.vida_atual = GameManager.vida_maxima
	GameManager.vida_atualizada.emit(GameManager.vida_atual, GameManager.vida_maxima)
	_atualizar_botoes()

func _on_dano_pressed() -> void:
	if not _comprar("dano", "Força de impacto"):
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.dano_ataque += 5 + GameManager.num_loops * 3
	_atualizar_botoes()

func _on_recarga_pressed() -> void:
	if not _comprar("recarga", "Cadência"):
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.reduzir_recarga_ataque(0.02 + GameManager.num_loops * 0.01)
	_atualizar_botoes()

func _on_velocidade_pressed() -> void:
	if not _comprar("velocidade", "Agilidade"):
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.velocidade += 20.0 + GameManager.num_loops * 10.0
	_atualizar_botoes()

func _on_continuar_pressed() -> void:
	if GameManager.estado_atual != GameManager.Estado.UPGRADE:
		return
	_som_botao.play()
	GameManager.mudar_estado(GameManager.Estado.JOGANDO)
