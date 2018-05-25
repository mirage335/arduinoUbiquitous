#Arduino may ignore "--pref" parameters, possibly due to bugs present in some versions. Consequently, it is possible some stored perferences may interfere with normal script operation. As a precaution, these are deleted.
_arduino_deconfigure_sequence() {
	_start
	
	local arduinoPreferences
	arduinoPreferences="$HOME"/.arduino15/preferences.txt
	
	mv "$arduinoPreferences" "$safeTmp"/preferences.txt
	
	grep -v '^sketchbook\.path' "$safeTmp"/preferences.txt > "$safeTmp"/intermediate
	mv "$safeTmp"/intermediate "$safeTmp"/preferences.txt
	
	grep -v '^last\.' "$safeTmp"/preferences.txt > "$safeTmp"/intermediate
	mv "$safeTmp"/intermediate "$safeTmp"/preferences.txt
	
	grep -v '^recent\.' "$safeTmp"/preferences.txt > "$safeTmp"/intermediate
	mv "$safeTmp"/intermediate "$safeTmp"/preferences.txt
	
	mv "$safeTmp"/preferences.txt "$arduinoPreferences"
	
	_stop
}

_arduino_deconfigure() {
	"$scriptAbsoluteLocation" _arduino_deconfigure_sequence "$@"
}

#command
_arduino_command() {
	export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
	
	local arduinoExecutable
	arduinoExecutable="$scriptAbsoluteFolder"/_local/arduino-1.8.5/arduino
	
	"$arduinoExecutable" --save-prefs --pref sketchbook.path="$HOME"/Arduino "$@"
	
	"$arduinoExecutable" "$@"
	
	_arduino_deconfigure
}

#edit
_arduino_edit() {
	"$scriptAbsoluteLocation" _editFakeHome "$scriptAbsoluteLocation" _arduino_command "$@"
}

#user
_arduino_user() {
	"$scriptAbsoluteLocation" _userFakeHome "$scriptAbsoluteLocation" _arduino_command "$@"
}

#virtualized
_v_arduino() {
	_userQemu "$scriptAbsoluteLocation" _arduino_user "$@"
}

#default
_arduino() {
	if ! _check_prog
	then
		_messageNormal 'Launch: _v'${FUNCNAME[0]}
		_v${FUNCNAME[0]} "$@"
		return
	fi
	_arduino_user "$@" && return 0

	#_messageNormal 'Launch: _v'${FUNCNAME[0]}
	#_v${FUNCNAME[0]} "$@"
}

#duplicate _anchor
_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino
}


#####^ Core
