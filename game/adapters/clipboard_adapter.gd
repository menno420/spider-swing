extends RefCounted
class_name ClipboardAdapter
## Platform boundary for explicit, user-triggered local text export.


func copy_text(text: String) -> bool:
	if text.is_empty() or DisplayServer.get_name() == "headless":
		return false
	DisplayServer.clipboard_set(text)
	# Clipboard APIs provide no cross-platform acknowledgement. `true` means the
	# platform call was made, not that Android paste behaviour was device-proved.
	return true
