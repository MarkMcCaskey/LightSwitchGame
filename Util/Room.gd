class_name Room extends Node

enum RoomName { None, Foyer, Porch, Garage, Kitchen, BedRoom1, BedRoom2, BedRoom3 }

static func room_name_to_name(rn: RoomName) -> String:
	match rn:
		RoomName.Foyer:
			return "foyer"
		RoomName.Porch:
			return "porch"
		RoomName.Garage:
			return "garage"
		RoomName.Kitchen:
			return "kitchen"
		RoomName.BedRoom1:
			return "bedroom1"
		RoomName.BedRoom2:
			return "bedroom2"
		RoomName.BedRoom3:
			return "bedroom3"
		_:
			print("Missing room!")
			print_stack()
			assert(false, "Must have a room!")
			return "none"
			
static func room_name_to_light_group(rn: RoomName) -> String:
	return Room.room_name_to_name(rn) + "_lights"

static func room_name_to_spawn_group(rn: RoomName) -> String:
	return Room.room_name_to_name(rn) + "_spawners"
