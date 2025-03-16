extends Node

var occupied_waypoints = {}

func occupy_waypoint(waypoint: Vector2, npc: Node2D):
	occupied_waypoints[waypoint] = npc  

func release_waypoint(waypoint: Vector2):
	occupied_waypoints.erase(waypoint)  

func is_waypoint_occupied(waypoint: Vector2) -> bool:
	return waypoint in occupied_waypoints
