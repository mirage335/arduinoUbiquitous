#all2=""

#command
_arduino_command() {
	"$scriptAbsoluteFolder"/_local/arduino-1.8.5/arduino "$@"
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
