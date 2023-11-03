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

func _ready() -> void:
	if Engine.is_editor_hint():
		var creeper_scene := load("res://Entities/creature_w_1_creeper_breathing.tscn")
		var creeper = creeper_scene.instantiate()
		creeper.scale *= 0.2
		#creeper.modulate.a = 0.5
		add_child(creeper)

static func connected_regions(location: Location) -> Array[Location]:
	match location:
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
		_: return []
		
