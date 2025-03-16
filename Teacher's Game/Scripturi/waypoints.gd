extends Node

var occupied_waypoints = {}  # Dicționar care marchează waypoint-urile ocupate

func occupy_waypoint(waypoint: Vector2, npc: Node2D):
	occupied_waypoints[waypoint] = npc  # NPC-ul marchează waypoint-ul ca ocupat

func release_waypoint(waypoint: Vector2):
	occupied_waypoints.erase(waypoint)  # Eliberează waypoint-ul

func is_waypoint_occupied(waypoint: Vector2) -> bool:
	return waypoint in occupied_waypoints
