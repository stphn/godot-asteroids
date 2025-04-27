extends Node


@onready var sfx_pool: Node = $SFXPool

var sounds: Dictionary

func _ready() -> void:
    sounds = {
        "fire": load("res://Sounds/fire.wav"),
        "explosion": load("res://Sounds/explosion.wav"),
        "soundscape": load("res://Sounds/soundscape.wav"),
    }

func play_sfx(sound_name: String, pitch_randomize: bool = true) -> void:
    if not sounds.has(sound_name):
        push_warning("Sound '%s' not found in AudioManager." % sound_name)
        return

    var sfx = AudioStreamPlayer.new()  # create a new sound player
    sfx.stream = sounds[sound_name]
    sfx.pitch_scale = randf_range(0.95, 1.05) if pitch_randomize else 1.0
    sfx_pool.add_child(sfx)
    sfx.play()

    # When sound finishes, auto-remove it from memory
    sfx.finished.connect(sfx.queue_free)
