extends Control

# Сигналы для уведомления об окончании фоновых операций
signal connection_checked(result: bool)
signal login_result(success: bool, error_msg: String)

@onready var err_label:=$pc/mc/vbc/err
@onready var login_btn:=$pc/mc/vbc/log
@onready var user_filed:=$pc/mc/vbc/user
@onready var password_filed:=$pc/mc/vbc/pass
@onready var retry_btn:=$pc/mc/vbc/retry
@onready var settings_btn:=$to_settings
@onready var exit_btn:=$pc/mc/vbc/hbc/exit
@onready var offline_play:=$pc/mc/vbc/hbc/jpb

var is_active = true
var connection_thread : Thread = null

var ctx = HashingContext.new()
func _ready():
	# Подключаем обработчики сигналов
	connection_checked.connect(_on_connection_checked)
	login_result.connect(_on_login_result)
	# Подключаем сигналы кнопок к методам
	login_btn.pressed.connect(_on_login_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	# Автоматически проверяем соединение при старте
	_check_connection()

func _check_connection():
	if connection_thread and connection_thread.is_alive():
		return  # Предотвращаем запуск нового, если старый ещё работает
	connection_thread = Thread.new()
	connection_thread.start(_thread_check_connection)


func _thread_check_connection():
	if is_active:
		var success = sqlc.CheckConnection()
		call_deferred("emit_signal", "connection_checked", success)


func _on_connection_checked(result):
	# Обработчик сигнала по результату проверки соединения
	if result:
		err_label.text = ""  # Очищаем сообщение об ошибке
		# Разрешаем кнопку входа, скрываем retry
		login_btn.disabled = false
		retry_btn.disabled = true
	else:
		err_label.text = "Ошибка: нет соединения с базой данных"
		# Если нет соединения, блокируем вход и показываем retry
		login_btn.disabled = true
		retry_btn.disabled = false

func _on_retry_pressed():
	# Пользователь нажал кнопку 'Retry' для повторной проверки
	err_label.text = ""  # Очищаем предыдущее сообщение об ошибке
	_check_connection()

func _on_login_pressed():
	# Блокируем UI при попытке входа
	login_btn.text = "Ожидайте"
	login_btn.disabled = true
	user_filed.editable = false
	password_filed.editable = false
	# Блокируем другие кнопки (например, Настройки, Выход)
	settings_btn.disabled = true
	exit_btn.disabled = true
	retry_btn.disabled = true
	# Получаем введенные логин/пароль
	var login = user_filed.text
	var password = password_filed.text
	# Запускаем фоновую авторизацию
	var thread = Thread.new()
	thread.start(_thread_login.bindv([login, password]))

func _thread_login(login, password):
	# Фоновая задача: проверка учетных данных
	var success = false
	var error_msg = ""
	var ok=sqlc.CheckConnection()
	if ok:
		# Пример простой проверки (имитация)
		if not ( user_filed.text=="" or password_filed.text==""):
			ctx.start(HashingContext.HASH_SHA256)
			ctx.update(password_filed.text.to_utf8_buffer())
			var ps=ctx.finish().hex_encode()
			var arr:Array=sqlc.query("
		select login from users where login=\"{0}\" and password=\"{1}\" and status = 1".
			format([user_filed.text,ps]))
			if !arr.is_empty():
				arr=arr[0]
				gmd.user_login=arr[0]
				arr=sqlc.query("SELECT level_id, points, collected, hits FROM user_level_records WHERE user_login = '{0}' ORDER BY record_date DESC LIMIT 1;".format([gmd.user_login]))
				gmd.online=true
				success = true
			else:
				error_msg = "Неверное имя пользователя или пароль"
		else:
			error_msg = "Введите данные в поля логина и пароля"
	else:
		error_msg = "нет доступа к БД"
	# Возвращаем результат в главный поток через сигнал
	call_deferred("emit_signal", "login_result", success, error_msg)

func _on_login_result(success, err):
	if success:
		# Успешный вход: переходим на главный экран
		
		get_tree().change_scene_to_file("res://main/main_ui.tscn")
	else:
		# Авторизация не удалась: разблокируем UI и показываем ошибку
		login_btn.text = "Войти"
		login_btn.disabled = false
		user_filed.editable = true
		password_filed.editable = true
		settings_btn.disabled = false
		exit_btn.disabled = false
		retry_btn.disabled = false
		err_label.text = err


func _on_just_play_button_down() -> void:
	gmd.online=false
	get_tree().change_scene_to_file("res://main/main_ui.tscn")

func _exit_tree():
	is_active = false
	if connection_thread and connection_thread.is_alive():
		connection_thread.wait_to_finish()


func _on_settings_button_pressed() -> void:
	$settings.hide()
	$to_settings.show()
	$to_settings.grab_focus()


func _on_to_settings_button_down() -> void:
	$settings.show()
	$to_settings.hide()
	$settings/mc/vbc/hbc/bc.grab_focus()


func _on_exit_button_down() -> void:
	get_tree().quit()
