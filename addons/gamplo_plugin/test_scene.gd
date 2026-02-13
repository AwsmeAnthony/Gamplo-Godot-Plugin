extends CanvasLayer

@onready var error_label: RichTextLabel = $ErrorLabel
@onready var username: Label = $username
@onready var http_request: HTTPRequest = $HTTPRequest

func _process(_delta: float) -> void:
	error_label.text = str(Gamplo.errors)

	if Gamplo.gamplo_data == {} or username.text != "":
		return
	
	await get_tree().create_timer(0.1).timeout
	username.text = Gamplo.gamplo_data["player"]["displayName"]
	var _error = http_request.request(Gamplo.gamplo_data["player"]["image"])
	Gamplo.unlock_achievement("test")
