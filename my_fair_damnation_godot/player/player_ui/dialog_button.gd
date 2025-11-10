extends Button
class_name DialogButton

var player_conversation : PlayerConversationController
var dialog : Dialog


func set_up_conversation_button(_player_conversation, _dialog) -> void:
	player_conversation = _player_conversation
	dialog = _dialog
	text = dialog.player_dialog_option


func _on_pressed() -> void:
	player_conversation.open_dialog(dialog)
