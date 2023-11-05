@tool
class_name MonsterCreepSpot extends Node3D

@export var location: Location
enum Location {
	FrontDoor,
	BackGarageDoor,
	BedRoom2Window,
	BackPorch,
	BedRoom1Window,
	DriveWayClose,
	DriveWayFar,
	ColDeSacMiddle,
	ColDeSacNear,
	ColDeSacFar,
	RoofCenter,
	RoofFront,
	RoofBack,
	RoofBedRoom1Side,
	RoofBathRoomSide,
	HouseLeftCenter,
	HouseLeftFront,
	HouseLeftBack,
	HouseRightCenter,
	HouseRightFront,
	HouseRightBack,
	HouseFront,
	HouseBack,
}
@export var enter_house_position: Node3D

func _ready() -> void:
	if Engine.is_editor_hint():
		var creeper_scene := load("res://Entities/creature_w_1_creeper_breathing.tscn")
		var creeper = creeper_scene.instantiate()
		creeper.rotation.y = 180
		creeper.scale *= 0.2
		#creeper.modulate.a = 0.5
		add_child(creeper)
	else:
		add_to_group(MonsterCreepSpot.get_group_name(location))

static func get_next_location_random(location: Location) -> Location:
	var candidates: Array[Location] = MonsterCreepSpot.connected_regions(location)
	assert(len(candidates) > 0)
	return candidates[randi() % len(candidates)]

static func can_begin_attack(location: Location) -> bool:
	match location:
		Location.FrontDoor: return true
		# maybe it can enter the garage?
		Location.BackGarageDoor: return true
		Location.BackPorch: return true
		Location.BedRoom1Window: return true
		Location.BedRoom2Window: return true
		_: pass
	
	return false

static func get_group_name(loc: Location) -> String:
	return "monster_location_" + Location.keys()[loc]

static func is_on_roof(loc: Location) -> bool:
	match loc:
		Location.RoofCenter: return true
		Location.RoofFront: return true
		Location.RoofBack: return true
		Location.RoofBedRoom1Side: return true
		Location.RoofBathRoomSide: return true
		Location.BedRoom1Window: return true
		Location.BedRoom2Window: return true
		_: return false
	return false

static func is_on_same_level(loc1: Location, loc2: Location) -> bool:
	return MonsterCreepSpot.is_on_roof(loc1) == MonsterCreepSpot.is_on_roof(loc2)

static func is_by_glass(loc: Location) -> bool:
	match loc:
		Location.BedRoom1Window: return true
		Location.BedRoom2Window: return true
		Location.BackPorch: return true
		_: pass
	return false

static func is_by_door(loc: Location) -> bool:
	match loc:
		Location.FrontDoor: return true
		Location.BackGarageDoor: return true
		_: pass
	return false

static func connected_regions(loc: Location) -> Array[Location]:
	match loc:
		Location.ColDeSacFar:
			return [Location.ColDeSacMiddle]
		Location.ColDeSacMiddle:
			return [Location.ColDeSacNear]
		Location.ColDeSacNear:
			return [Location.ColDeSacMiddle, Location.DriveWayFar]
		Location.DriveWayFar:
			return [Location.ColDeSacNear, Location.DriveWayClose]
		Location.DriveWayClose:
			return [Location.DriveWayFar, Location.HouseLeftFront, Location.FrontDoor, Location.HouseFront, Location.RoofFront, Location.BedRoom1Window]
		Location.HouseLeftFront:
			return [Location.HouseLeftCenter, Location.DriveWayClose, Location.BedRoom1Window]
		Location.HouseLeftCenter:
			return [Location.HouseLeftFront, Location.HouseLeftBack, Location.RoofBedRoom1Side]
		Location.HouseLeftBack:
			return [Location.HouseLeftCenter, Location.BackGarageDoor]
		Location.BackGarageDoor:
			return [Location.HouseLeftBack, Location.HouseBack, Location.BackPorch, Location.BedRoom2Window]
		Location.HouseBack:
			return [Location.BackGarageDoor, Location.HouseRightBack, Location.BackPorch]
		Location.BackPorch:
			return [Location.HouseBack, Location.HouseRightBack, Location.BedRoom2Window]
		Location.HouseRightBack:
			return [Location.HouseRightCenter, Location.HouseBack, Location.BedRoom2Window, Location.BackPorch]
		Location.HouseRightCenter:
			return [Location.HouseRightBack, Location.HouseRightFront, Location.RoofBathRoomSide]
		Location.HouseRightFront:
			return [Location.HouseRightCenter, Location.HouseFront]
		Location.HouseFront:
			return [Location.HouseRightFront, Location.DriveWayClose, Location.DriveWayFar, Location.RoofFront]
		Location.RoofFront:
			return [Location.DriveWayClose, Location.BedRoom1Window, Location.RoofCenter, Location.RoofBathRoomSide, Location.RoofBedRoom1Side, Location.HouseFront]
		Location.BedRoom1Window:
			return [Location.DriveWayClose, Location.RoofFront, Location.RoofBedRoom1Side, Location.RoofCenter]
		Location.BedRoom2Window:
			return [Location.BackGarageDoor, Location.RoofBack, Location.RoofBathRoomSide, Location.HouseRightBack]
		Location.RoofBedRoom1Side:
			return [Location.BedRoom1Window, Location.RoofCenter, Location.RoofCenter, Location.HouseLeftCenter, Location.HouseLeftFront, Location.HouseLeftBack]
		Location.RoofCenter:
			return [Location.RoofBack, Location.RoofBathRoomSide, Location.RoofBedRoom1Side, Location.RoofFront]
		Location.RoofBack:
			return [Location.RoofCenter, Location.RoofBathRoomSide, Location.BedRoom2Window, Location.BackGarageDoor, Location.HouseRightBack]
		Location.RoofBathRoomSide:
			return [Location.RoofCenter, Location.RoofBack, Location.RoofFront, Location.HouseRightCenter, Location.HouseRightFront]
		Location.FrontDoor:
			return [Location.DriveWayClose, Location.HouseFront, Location.BedRoom1Window, Location.RoofFront]
		Location.BackPorch:
			return [Location.HouseBack, Location.HouseBack, Location.BedRoom2Window, Location.HouseRightBack, Location.BackGarageDoor]
		Location.BackGarageDoor:
			return [Location.HouseBack, Location.HouseLeftBack, Location.BackPorch, Location.RoofBack]
		_:
			print(str(loc) + " Unhandled " + Location.keys()[loc])
			assert(false, "wat")
			return []

# 1 indicates a position where the monster can attack
static func safety_rating(loc: Location) -> int:
	match loc:
		Location.FrontDoor: return 1
		Location.BackGarageDoor: return 1
		Location.BedRoom2Window: return 1
		Location.BackPorch: return 1
		Location.BedRoom1Window: return 1
		Location.DriveWayClose: return 2
		Location.DriveWayFar: return 3
		Location.ColDeSacMiddle: return 2 
		Location.ColDeSacNear: return 3
		Location.ColDeSacFar: return 4
		Location.RoofCenter: return 4
		Location.RoofFront: return 3
		Location.RoofBack: return 3
		Location.RoofBedRoom1Side: return 3
		Location.RoofBathRoomSide: return 3
		Location.HouseLeftCenter: return 4
		Location.HouseLeftFront: return 3
		Location.HouseLeftBack: return 3
		Location.HouseRightCenter: return 4
		Location.HouseRightFront: return 3
		Location.HouseRightBack: return 3
		Location.HouseFront: return 2
		Location.HouseBack: return 2
		_: return 3
