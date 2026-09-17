class_name PauseMenu
extends CanvasLayer

@onready var dim: ColorRect = $Dim
@onready var main_panel: Control = $MainPanel
@onready var continue_button: Button = $MainPanel/Panel/VBox/ContinueButton
@onready var settings_button: Button = $MainPanel/Panel/VBox/SettingsButton
@onready var exit_button: Button = $MainPanel/Panel/VBox/ExitButton

@onready var confirm_panel: Control = $ConfirmPanel
@onready var cancel_exit_button: Button = $ConfirmPanel/Panel/VBox/HBox/CancelButton
@onready var confirm_exit_button: Button = $ConfirmPanel/Panel/VBox/HBox/ConfirmButton

@onready var settings_menu: SettingsMenu = $SettingsMenu


func _ready() -> void:
	visible = false
	confirm_panel.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	cancel_exit_button.pressed.connect(_on_cancel_exit_pressed)
	confirm_exit_button.pressed.connect(_on_confirm_exit_pressed)
	settings_menu.closed.connect(_on_settings_closed)


func open() -> void:
	confirm_panel.visible = false
	dim.visible = true
	main_panel.visible = true
	visible = true


func close() -> void:
	visible = false


## Corrige o bug de Pause + Configurações sobrepostos: enquanto o painel de
## Configurações estiver aberto, o Pause fica completamente oculto (não só
## o painel principal, também o próprio fundo escurecido) — nunca as duas
## telas desenhadas ao mesmo tempo. O jogo continua pausado durante tudo.
func _on_settings_pressed() -> void:
	dim.visible = false
	main_panel.visible = false
	settings_menu.open()


func _on_settings_closed() -> void:
	dim.visible = true
	main_panel.visible = true


func _on_continue_pressed() -> void:
	GameManager.resume_gameplay()
	close()


func _on_exit_pressed() -> void:
	main_panel.visible = false
	confirm_panel.visible = true


func _on_cancel_exit_pressed() -> void:
	confirm_panel.visible = false
	main_panel.visible = true


func _on_confirm_exit_pressed() -> void:
	GameManager.go_to_main_menu()
