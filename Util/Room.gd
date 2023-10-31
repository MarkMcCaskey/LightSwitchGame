class_name Room extends Node

enum RoomName { None, Foyer, Porch, Garage, Kitchen, BedRoom1 }

static func room_name_to_light_group(rn: RoomName) -> String:
	match rn:
		RoomName.Foyer:
			return "foyer_lights"
		RoomName.Porch:
			return "porch_lights"
		RoomName.Garage:
			return "garage_lights"
		RoomName.Kitchen:
			return "kitchen_lights"
		RoomName.BedRoom1:
			return "bedroom1_lights"
		_:
			print("Missing room!")
			print_stack()
			assert(false, "Must have a room!")
			return "none"
