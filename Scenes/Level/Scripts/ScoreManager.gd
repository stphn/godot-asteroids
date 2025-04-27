extends Node
class_name ScoreManager

var score: int = 0

signal score_changed(new_score)

func add_points(points: int) -> void:
    score += points
    score_changed.emit(score)

func reset_score() -> void:
    score = 0
    score_changed.emit(score)