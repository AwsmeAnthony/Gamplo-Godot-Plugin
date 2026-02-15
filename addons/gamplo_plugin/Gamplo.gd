extends Node

signal loged_in(data)

@onready var auto_login_http_request := HTTPRequest.new()
@onready var achievement_http_request: HTTPRequest = HTTPRequest.new()

const ACHIEVEMNT_URL := "https://gamplo.com/api/sdk"
const GAMPLO_AUTH_URL := "https://gamplo.com/api/sdk/auth"
const GAMPLO_API_BASE := "https://gamplo.com/api"

var gamplo_token: String = ""
var session_id: String = ""

var gamplo_data: Dictionary = {}
var errors: Array = []


func _ready():
#region Autologin Ready
	if gamplo_data != {}:
		emit_signal("loged_in", gamplo_data)
		achievement_start_request()
		return
	add_child(auto_login_http_request)
	auto_login_http_request.request_completed.connect(_on_autologin_request_completed)

	if OS.has_feature("web"):
		gamplo_token = _get_gamplo_token_from_url()
		if gamplo_token != "":
			_authenticate_with_gamplo(gamplo_token)
		else:
			errors.append("No gamplo_token found")
	else:
		errors.append("Gamplo needs a web build")
#endregion
	
	achievement_start_request()


#region AutoLogin

func _authenticate_with_gamplo(token: String) -> void:
	var headers = ["Content-Type: application/json"]

	var body = JSON.stringify({
		"token": token
	})

	auto_login_http_request.request(
		GAMPLO_AUTH_URL,
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	
func _on_autologin_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		errors.append("Gamplo request failed: %s" % response_code)

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed == null:
		errors.append("Invalid JSON from Gamplo")
		return

	_merge_dictionary(gamplo_data, parsed)

	if parsed.has("sessionId"):
		session_id = parsed["sessionId"]

	errors.append("Gamplo data updated:")
	get_achievements()
	emit_signal("loged_in", gamplo_data)
	
	errors.append(str(gamplo_data))

func call_gamplo_api(endpoint: String, method := HTTPClient.METHOD_GET, body := "") -> void:
	if session_id == "":
		errors.append("No Gamplo session ID")
		return

	var headers = [
		"Content-Type: application/json",
		"x-sdk-session: %s" % session_id
	]

	auto_login_http_request.request(
		GAMPLO_API_BASE + endpoint,
		headers,
		method,
		body
	)

func _get_gamplo_token_from_url() -> String:
	return str(
		JavaScriptBridge.eval(
			"new URLSearchParams(window.location.search).get('gamplo_token')"
		)
	)

func _merge_dictionary(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		if target.has(key) and target[key] is Dictionary and source[key] is Dictionary:
			_merge_dictionary(target[key], source[key])
		else:
			target[key] = source[key]
#endregion

#region Achievemnts


func achievement_start_request():
	add_child(achievement_http_request)
	achievement_http_request.request_completed.connect(_on_achievement_request_completed)


func get_achievements():
	var url = ACHIEVEMNT_URL

	var headers = [
		"x-sdk-session: %s" % session_id
	]

	var err = achievement_http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if err != OK:
		errors.append("Could not request achievements: %s" % err)


func _on_achievement_request_completed(
	_result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
):
	var text := body.get_string_from_utf8()
	var json = JSON.parse_string(text)

	if json == null:
		errors.append("Invalid JSON response")
		return

	if response_code != 200:
		errors.append("HTTP %s: %s" % [response_code, text])
		return

	#if json.has("achievements"):
		#for achievement in json["achievements"]:
			#print("Achievement:", achievement["key"])
			#print("Unlocked:", achievement["unlocked"])


func unlock_achievement(key: String):
	var url = ACHIEVEMNT_URL + "/unlock"

	var headers = [
		"Content-Type: application/json",
		"x-sdk-session: %s" % session_id
	]

	var body = {
		"key": key
	}

	var json_body := JSON.stringify(body)

	var err = achievement_http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if err != OK:
		errors.append("Failed to unlock achievement: %s" % err)
#endregion
