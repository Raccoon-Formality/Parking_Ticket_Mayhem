extends CPUParticles


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var money = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$money.text = "+$" + str(format_number(money))


func _on_Timer_timeout():
	queue_free()

func format_number(number: int) -> String:
	# Handle negative numbers by adding the "minus" sign in advance, as we discard it
	# when looping over the number.
	var formatted_number := "-" if sign(number) == -1 else ""
	var index := 0
	var number_string := str(abs(number))
	
	for digit in number_string:
		formatted_number += digit
		
		var counter := number_string.length() - index
		
		# Don't add a comma at the end of the number, but add a comma every 3 digits
		# (taking into account the number's length).
		if counter >= 2 and counter % 3 == 1:
			formatted_number += ","
			
		index += 1
	
	return formatted_number
