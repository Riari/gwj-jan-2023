extends Control

var warning_sound_playback_position = 0.0

func play_click():
	$Click.play()

func play_warning_alarm():
	$WarningAlarm.play(warning_sound_playback_position)

func stop_warning_alarm():
	warning_sound_playback_position = $WarningAlarm.get_playback_position()
	$WarningAlarm.stop()