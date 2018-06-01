_arduino_executable() {
	local arduinoExecutable
	#arduinoExecutable="$scriptAbsoluteFolder"/_local/arduino-1.8.5/arduino
	arduinoExecutable="$au_arduinoInstallation"/arduino
	
	[[ "$setFakeHome" != "true" ]] && _messagePlain_warn 'aU: undetected: setFakeHome, unset: java: user.home'
	[[ "$setFakeHome" == "true" ]] && _messagePlain_good 'aU: detected: setFakeHome, update: arduinoExecutable, set: java: user.home' && arduinoExecutable="$HOME"/"$au_arduinoDir"/arduino && export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
	
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
	
	[[ "$setFakeHome" != "true" ]] && _messagePlain_warn 'aU: undetected: setFakeHome, preferences: portable' && arduinoPreferences="$au_arduinoInstallation"/portable/preferences.txt
	[[ "$setFakeHome" == "true" ]] && _messagePlain_good 'aU: detected: setFakeHome, set: preferences: home' && arduinoPreferences="$HOME"/.arduino15/preferences.txt
	
	! [[ -e "$arduinoPreferences" ]] && arduinoPreferences="$HOME"/.arduino15/preferences.txt
	
	
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

_arduino_set_board_zero_native() {
	_messagePlain_nominal 'aU: set: board'
	_arduino_executable --save-prefs --pref target_platform=samd
	_arduino_executable --save-prefs --pref board=arduino_zero_native
}

#Intended to be used as "ops" override.
_arduino_prepare_board() {
	true
}

#Intended to be used as an ops override.
_arduino_sketch_ops() {
	true
}

# WARNING: Assumes first fileparameter given to arduino is sketch .
_arduino_prepare_compile() {
	_messagePlain_nominal 'aU: set: build.path'
	
	local arduinoBuildPath
	local arduinoSketchDir
	
	if arduinoSketchDir=$(_arduino_sketchDir "$@")
	then
		arduinoBuildPath="$arduinoSketchDir"/_build
		
		_messagePlain_good 'aU: found: sketch= '"$arduinoBuildPath"
		
		mkdir -p "$arduinoBuildPath"
		
		_messagePlain_probe _arduino_executable --save-prefs --pref build.path="$arduinoBuildPath"
		_arduino_executable --save-prefs --pref build.path="$arduinoBuildPath"
		
		#Looks for an ops file in same directory as sketch.
		[[ -e "$arduinoSketchDir"/ops ]] && _messagePlain_nominal 'aU: found: sketch ops' && . "$arduinoSketchDir"/ops
		
		return 0
	fi
	_messagePlain_warn 'aU: undef: sketch'
	return 1
}

_arduino_prepare() {
	_arduino_prepare_compile "$@"
	
	_arduino_sketch_ops "$@"
	
	_arduino_prepare_board "$@"
	
	_messagePlain_nominal 'aU: set: sketchbook.path'
	
	[[ "$setFakeHome" != "true" ]] && _messagePlain_warn 'aU: undetected: setFakeHome, set: sketchbook.path: portable' && _arduino_executable --save-prefs --pref sketchbook.path="$au_arduinoInstallation"/portable/sketchbook && return 0
	[[ "$setFakeHome" == "true" ]] && _messagePlain_good 'aU: detected: setFakeHome, set: sketchbook.path: home' && _arduino_executable --save-prefs --pref sketchbook.path="$HOME"/Arduino
}



#command
_arduino_command() {
	_messageNormal "aU: Configure."
	_arduino_prepare "$@"
	
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

#config, assumes portable directories have been setup
_arduino_config() {
	"$scriptAbsoluteLocation" _arduino_command "$@"
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

#Applicable to other arduino variants.
_arduino_upload_zero() {
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
	"$globalFakeHome"/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/bin/openocd -d2 -s "$globalFakeHome"/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/ -f "$globalFakeHome"/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/board/arduino_zero.cfg -c "telnet_port disabled; program {{"$arduinoBin"}} verify reset 0x00002000; shutdown"

	if [[ $? != 0 ]]	#SWD upload failed.
	then
		#Upload over serial COM.
		stty --file=/dev/ttyACM0 1200;stty stop x --file=/dev/ttyACM0;stty --file=/dev/ttyACM0 1200;stty stop x --file=/dev/ttyACM0;
		sleep 2
		"$globalFakeHome"/arduino15/packages/arduino/tools/bossac/1.7.0/bossac -i -d --port=ttyACM0 -U true -i -e -w -v "$arduinoBin" -R
	fi
}

_arduino_upload() {
	_arduino_upload_zero "$@"
}

_arduino_bootloader_m0() {
	"$globalFakeHome"/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/bin/openocd -d2 -s "$globalFakeHome"/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/ -f "$globalFakeHome"/.arduino15/packages/arduino-beta/hardware/samd/1.6.16-build-172/variants/arduino_mzero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {{""$scriptLocal""/h/.arduino15/packages/arduino-beta/hardware/samd/1.6.16-build-172/bootloaders/mzero/Bootloader_D21_M0_150515.hex}} verify reset; shutdown"
}

_arduino_bootloader_zero() {
	"$globalFakeHome"/arduino-1.8.5/portable/packages/arduino/tools/openocd/0.9.0-arduino6-static/bin/openocd -d2 -s "$globalFakeHome"/arduino-1.8.5/portable/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/ -f "$globalFakeHome"/arduino-1.8.5/portable/packages/arduino-beta/hardware/samd/1.6.16-build-172/variants/arduino_zero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {{""$globalFakeHome""/arduino-1.8.5/portable/packages/arduino-beta/hardware/samd/1.6.16-build-172/bootloaders/zero/samd21_sam_ba.bin}} verify reset; shutdown"
}

_arduino_bootloader() {
	_arduino_bootloader_zero "$@"
}



#duplicate _anchor
_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_compile
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_upload
}


#####^ Core
