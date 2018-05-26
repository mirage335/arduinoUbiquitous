_arduino_executable() {
	local arduinoExecutable
	arduinoExecutable="$scriptAbsoluteFolder"/_local/arduino-1.8.5/arduino
	
	export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
	
	"$arduinoExecutable" "$@"
}

# WARNING: Assumes first fileparameter given to arduino is sketch .
_arduino_sketchDir() {
	local currentArg
	
	#for currentArg in "$1"
	for currentArg in "$@"
	do
		! [[ -e "$currentArg" ]] && continue
		
		local compilerInputAbsolute
		compilerInputAbsolute=$(_getAbsoluteLocation "$currentArg")
		
		local compilerInputAbsoluteDirectory
		compilerInputAbsoluteDirectory=$(_findDir "$compilerInputAbsolute")
		
		echo "$compilerInputAbsoluteDirectory"
		
		return 0
	done
	
	return 1
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
	
	local arduinoBuildPath
	
	if arduinoBuildPath=$(_arduino_sketchDir "$@")
	then
		arduinoBuildPath="$arduinoBuildPath"/_build
		
		_messagePlain_good 'aU: found: sketch= '"$arduinoBuildPath"
		
		mkdir -p "$arduinoBuildPath"
		
		_messagePlain_probe _arduino_executable --save-prefs --pref build.path="$arduinoBuildPath"
		_arduino_executable --save-prefs --pref build.path="$arduinoBuildPath"
		
		return 0
	fi
	_messagePlain_warn 'aU: undef: sketch'
	return 1
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

_arduino_upload_m0() {
	_messageNormal 'Detecting build path.'
	
	local arduinoBuildPath
	
	if arduinoBuildPath=$(_arduino_sketchDir "$@")
	then
		arduinoBuildPath="$arduinoBuildPath"/_build
		_messagePlain_good 'aU: found: sketch= '"$arduinoBuildPath"
	else
		_messagePlain_warn 'aU: undef: sketch'
		arduinoBuildPath="$PWD"/_build
	fi
	
	if ! [[ -e "$arduinoBuildPath" ]]
	then
		_messagePlain_bad 'aU: missing: sketch='"$arduinoBuildPath"
		_stop 1
	fi
	
	_messageNormal 'Detecting binary.'
	
	local arduinoBin
	
	if arduinoBin=$(find "$arduinoBuildPath" -name '*.bin' | head -n 1) && [[ -e "$arduinoBin" ]]
	then
		_messagePlain_good 'aU: found: binary= '"$arduinoBin"
	else
		_messagePlain_bad 'aU: missing: binary'"$arduinoBin"
		_stop 1
	fi
	
	#Upload over SWD debugger.
	"$scriptLocal"/h/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/bin/openocd -d2 -s "$scriptLocal"/h/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/ -f "$scriptLocal"/h/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/board/arduino_zero.cfg -c "telnet_port disabled; program {{"$arduinoBin"}} verify reset 0x00002000; shutdown"

	if [[ $? != 0 ]]	#SWD upload failed.
	then
		#Upload over serial COM.
		stty --file=/dev/ttyACM0 1200;stty stop x --file=/dev/ttyACM0;stty --file=/dev/ttyACM0 1200;stty stop x --file=/dev/ttyACM0;
		sleep 2
		"$scriptLocal"/h/arduino15/packages/arduino/tools/bossac/1.7.0/bossac -i -d --port=ttyACM0 -U true -i -e -w -v "$arduinoBin" -R
	fi
	
}

_arduino_bootloader_m0() {
	"$scriptLocal"/h/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/bin/openocd -d2 -s "$scriptLocal"/h/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/ -f "$scriptLocal"/h/.arduino15/packages/arduino-beta/hardware/samd/1.6.16-build-172/variants/arduino_mzero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {{""$scriptLocal""/h/.arduino15/packages/arduino-beta/hardware/samd/1.6.16-build-172/bootloaders/mzero/Bootloader_D21_M0_150515.hex}} verify reset; shutdown"

}

#duplicate _anchor
_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_compile
}


#####^ Core
