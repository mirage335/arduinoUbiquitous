_arduino_executable() {
	local arduinoExecutable
	arduinoExecutable="$scriptAbsoluteFolder"/_local/arduino-1.8.5/arduino
	
	export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
	
	"$arduinoExecutable" "$@"
}


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

# WARNING: Assumes first fileparameter given to arduino is sketch .
_arduino_configure_compile() {
	_messagePlain_nominal 'aU: set: build.path'
	
	local currentArg
	
	#for currentArg in "$1"
	for currentArg in "$@"
	do
		! [[ -e "$currentArg" ]] && continue
		
		
		_messagePlain_good 'aU: found: sketch= '"$currentArg"
		
		local compilerInputAbsolute
		compilerInputAbsolute=$(getAbsoluteLocation "$currentArg")
		
		local compilerInputAbsoluteDirectory
		compilerInputAbsoluteDirectory=$(_findDir "$compilerInputAbsolute")
		
		mkdir -p "$compilerInputAbsoluteDirectory"/_build
		
		_messagePlain_probe _arduino_executable --save-prefs --pref build.path="$compilerInputAbsoluteDirectory"/_build
		_arduino_executable --save-prefs --pref build.path="$compilerInputAbsoluteDirectory"/_build
		
		return 0
	done
	
	_messagePlain_warn 'aU: undef: sketch' && return 1
}

_arduino_configure() {
	_arduino_configure_compile "$@"
	
	_messagePlain_nominal 'aU: set: sketchbook.path'
	_arduino_executable --save-prefs --pref sketchbook.path="$HOME"/Arduino
}



#command
_arduino_command() {
	_messageNormal "aU: Configure."
	_arduino_configure "$@"
	
	_messageNormal "aU: Launch."
	_arduino_executable "$@"
	
	_messageNormal "aU: Deconfigure."
	_arduino_deconfigure "$@"
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
	export sharedHostProjectDir=/
	export sharedGuestProjectDir=/
	_virtUser "$@"
	
	if ! _check_prog
	then
		_messageNormal 'Launch: _v'${FUNCNAME[0]}
		_v${FUNCNAME[0]} "${processedArgs[@]}"
		return
	fi
	_arduino_user "${processedArgs[@]}" && return 0

	#_messageNormal 'Launch: _v'${FUNCNAME[0]}
	#_v${FUNCNAME[0]} "${processedArgs[@]}"
}

_arduino_compile() {
	_arduino "$@" --verify
}

#duplicate _anchor
_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_compile
}


#####^ Core
