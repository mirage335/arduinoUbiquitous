_prepare_installation() {
	mkdir -p "$globalFakeHome"
	
	
	_set_atomFakeHomeSource
	
	_relink "$atomFakeHomeSource"/.atom "$globalFakeHome"/.atom
	mkdir -p "$globalFakeHome"/.config/Atom
	_relink "$atomFakeHomeSource"/.config/Atom "$globalFakeHome"/.config/Atom
	
	
	mkdir -p "$scriptLocal"/arduino/.arduino15
	mkdir -p "$scriptLocal"/arduino/Arduino
	
	mkdir -p "$scriptLocal"/arduino/"$au_arduinoDir"
	
	_relink "$scriptLocal"/arduino/.arduino15 "$globalFakeHome"/.arduino15
	_relink "$scriptLocal"/arduino/Arduino "$globalFakeHome"/Arduino
	_relink "$scriptLocal"/arduino/"$au_arduinoDir" "$globalFakeHome"/"$au_arduinoDir"
	
	_relink ../.arduino15 "$globalFakeHome"/"$au_arduinoDir"/portable
	_relink ../Arduino "$globalFakeHome"/"$au_arduinoDir"/portable/sketchbook
}

_prepareAppHome() {
	mkdir -p "$globalFakeHome"
	mkdir -p "$instancedFakeHome"
	
	_prepare_installation
	
	
	_set_atomFakeHomeSource
	
	rsync -q -ax --exclude "/.cache" --exclude "/.git" "$atomFakeHomeSource"/.atom/. "$instancedFakeHome"/.atom/
	mkdir -p "$instancedFakeHome"/.config/Atom
	rsync -q -ax --exclude "/.cache" --exclude "/.git" "$atomFakeHomeSource"/.config/Atom/. "$instancedFakeHome"/.config/Atom/
	
	
	#rm "$instancedFakeHome"/.arduino15
	mkdir -p "$instancedFakeHome"/.arduino15
	rsync -q -ax --exclude "/.cache" --exclude "/.git" "$scriptLocal"/arduino/.arduino15/. "$instancedFakeHome"/.arduino15/
	#rm "$instancedFakeHome"/Arduino
	mkdir -p "$instancedFakeHome"/Arduino
	rsync -q -ax --exclude "/.cache" --exclude "/.git" "$scriptLocal"/arduino/Arduino/. "$instancedFakeHome"/Arduino/
	#rm "$instancedFakeHome"/"$au_arduinoDir"
	mkdir -p "$instancedFakeHome"/"$au_arduinoDir"
	rsync -q -ax --exclude "/.cache" --exclude "/.git" "$scriptLocal"/arduino/"$au_arduinoDir"/. "$instancedFakeHome"/"$au_arduinoDir"/
}

_set_arduino_installation() {
	if [[ "$setFakeHome" == "true" ]]
	then
		export au_arduinoInstallation="$HOME"/"$au_arduinoDir"
		export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
		_messagePlain_good 'aU: detected: setFakeHome, set: au_arduinoInstallation= '"$au_arduinoInstallation"
		_messagePlain_good 'aU: detected: setFakeHome, set: java: user.home'
	else
		export au_arduinoInstallation="$globalFakeHome"/"$au_arduinoDir"
		_messagePlain_warn 'aU: undetected: setFakeHome, default: au_arduinoInstallation= '"$au_arduinoInstallation"
		_messagePlain_warn 'aU: undetected: setFakeHome, default: java: user.home'
	fi
	
	export au_gdbBin="$HOME"/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1/bin/arm-none-eabi-gdb "$@"
	_messagePlain_probe 'au_gdbBin= '"$au_gdbBin"
}

# WARNING: Assumes first fileparameter given to arduino is sketch .
_prepare_arduino_compile() {
	_messagePlain_nominal 'aU: set: sketch'
	
	[[ "$1" == "" ]] && _messagePlain_warn 'aU: undef: sketch' && return 1
	
	export au_arduinoSketchDir=$(_arduino_sketchDir "$@")
	export au_arduinoBuildPath="$au_arduinoSketchDir"/build
	
	! [[ -e "$au_arduinoSketchDir" ]] && _messagePlain_warn 'aU: undef: sketch' && return 1
	_messagePlain_good 'aU: found: sketch= '"$au_arduinoSketchDir"
	
	#Looks for an ops file in same directory as sketch.
	! [[ -e "$au_arduinoSketchDir"/ops ]] && _messagePlain_warn 'aU: undef: sketch ops'
	[[ -e "$au_arduinoSketchDir"/ops ]] && _messagePlain_nominal 'aU: found: sketch ops' && . "$au_arduinoSketchDir"/ops
	
	return 0
}

#Ultimately sets several global variables and preferences.
#au_arduinoInstallation
#au_arduinoSketchDir
#au_arduinoBuildPath (save binaries, do NOT build here!)
_prepare_arduino() {
	_gather_params "$@"
	_messagePlain_probe 'globalArgs= '"${globalArgs[@]}"
	
	_set_arduino_installation "$@"
	
	_prepare_installation "$@"
	
	_prepare_arduino_compile "$@"
	
	_ops_arduino_sketch "$@"
	
	_prepare_arduino_board "$@"
	
	_messagePlain_nominal 'aU: set: sketchbook.path'
	if [[ "$setFakeHome" == "true" ]]
	then
		_messagePlain_good 'aU: detected: setFakeHome, set: sketchbook.path: home, rm: portable '
		_arduino_executable --save-prefs --pref sketchbook.path="$HOME"/Arduino
		rm "$HOME"/"$au_arduinoDir"/portable/sketchbook
		rm "$HOME"/"$au_arduinoDir"/portable
	else
		 _messagePlain_warn 'aU: undetected: setFakeHome, set: sketchbook.path: portable'
		 _arduino_executable --save-prefs --pref sketchbook.path="$au_arduinoInstallation"/portable/sketchbook && return 0
	fi
}

# ATTENTION Overload with ops!
_prepare_arduino_board() {
	_set_arduino_board_zero_native
}

_set_arduino_board_zero_native() {
	_messagePlain_nominal 'aU: set: board'
	_arduino_executable --save-prefs --pref programmer=arduino:sam_ice
	_arduino_executable --save-prefs --pref target_platform=samd
	_arduino_executable --save-prefs --pref board=arduino_zero_native
}

#Intended to be used as an ops override.
_ops_arduino_sketch() {
	true
}

# DANGER Not recommended!
_make_clean() {
	[[ "$1" == "" ]] && return 1
	! [[ -e "$1" ]] && return 1
	
	local arduinoBuildPathRM
	local arduinoSketchDirRM
	
	if arduinoSketchDirRM=$(_arduino_sketchDir "$@")
	then
		arduinoBuildPathRM="$arduinoSketchDirRM"/_build
		_messagePlain_warn 'rm -rf '"$arduinoBuildPathRM"
		# DANGER Do NOT change this carelessly!
		[[ -e "$arduinoBuildPathRM" ]] && _safeBackup "$arduinoBuildPathRM" && rm -rf "$arduinoBuildPathRM"
	fi
}

# WARNING: Assumes first fileparameter given to arduino is sketch .
_arduino_sketchDir() {
	local currentArg
	
	#for currentArg in "$1"
	for currentArg in "$@"
	do
		! [[ -e "$currentArg" ]] && continue
		[[ "$currentArg" == *'ubiquitous_bash.sh' ]] && continue
		
		local compilerInputAbsolute
		compilerInputAbsolute=$(_getAbsoluteLocation "$currentArg")
		
		local compilerInputAbsoluteDirectory
		compilerInputAbsoluteDirectory=$(_findDir "$compilerInputAbsolute")
		
		echo "$compilerInputAbsoluteDirectory"
		
		return 0
	done
	
	return 1
}

#Arduino may ignore "--pref" parameters, possibly due to bugs present in some versions. Consequently, it is possible some stored preferences may interfere with normal script operation. As a precaution, these are deleted.
_arduino_deconfigure_commands() {
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
	
	grep -v '^build\.path' "$safeTmp"/preferences.txt > "$safeTmp"/intermediate
	mv "$safeTmp"/intermediate "$safeTmp"/preferences.txt
	
	mv "$safeTmp"/preferences.txt "$arduinoPreferences"
}

_arduino_deconfigure_sequence() {
	_start
	
	_arduino_deconfigure_commands "$@"
	
	_stop
}

_arduino_deconfigure() {
	"$scriptAbsoluteLocation" _arduino_deconfigure_sequence "$@"
}

_launch_env() {
	_start
	
	_messageNormal "aU: Configure."
	_prepare_arduino "$@"
	
	[[ -e "$au_arduinoSketchDir"/ops ]] && _messagePlain_nominal 'aU: found: sketch ops' && . "$au_arduinoSketchDir"/ops
	_messageNormal "aU: Launch."
	"$@"
	
	_messageNormal "aU: Deconfigure."
	_arduino_deconfigure_commands "$@"
}

_arduino_executable() {
	local arduinoExecutable
	arduinoExecutable="$au_arduinoInstallation"/arduino
	
	export sharedHostProjectDir=/
	export sharedGuestProjectDir=/
	_virtUser "$@"
	
	_messagePlain_probe "$arduinoExecutable" "${processedArgs[@]}"
	"$arduinoExecutable" "${processedArgs[@]}"
}

_arduino_swd_openocd() {
	_messagePlain_probe "$au_openocdStaticBin" -d2 -s "$au_openocdStaticScript" "$@"
	"$au_openocdStaticBin" -d2 -s "$au_openocdStaticScript" "$@"
}

_arduino_swd_openocd_zero() {
	_arduino_swd_openocd -f "$scriptLib"/ArduinoCore-samd/variants/arduino_zero/openocd_scripts/arduino_zero.cfg "$@"
}

#Requires bootloader.
_arduino_upload_swd_openocd_zero() {
	_arduino_swd_openocd_zero -c "telnet_port disabled; program {""$1""} verify reset 0x00002000; shutdown"
}

#Upload over serial COM. Crude, hardcoded serial port expected. Consider adding code to upload to specific Arduinos if needed. Recommend "ops" file overload.
_arduino_upload_serial_bossac() {
	local arduinoSerialPort
	
	arduinoSerialPort=/dev/ttyACM0
	! [[ -e "$arduinoSerialPort" ]] && arduinoSerialPort=/dev/ttyACM1
	! [[ -e "$arduinoSerialPort" ]] && arduinoSerialPort=/dev/ttyACM2
	! [[ -e "$arduinoSerialPort" ]] && arduinoSerialPort=/dev/ttyUSB0
	! [[ -e "$arduinoSerialPort" ]] && arduinoSerialPort=/dev/ttyUSB1
	! [[ -e "$arduinoSerialPort" ]] && arduinoSerialPort=/dev/ttyUSB2
	! [[ -e "$arduinoSerialPort" ]] && return 1
	
	stty --file="$arduinoSerialPort" 1200;stty stop x --file="$arduinoSerialPort";stty --file="$arduinoSerialPort" 1200;stty stop x --file="$arduinoSerialPort";
	sleep 2
	"$globalFakeHome"/.arduino15/packages/arduino/tools/bossac/1.7.0/bossac -i -d --port=ttyACM0 -U true -i -e -w -v "$1" -R
}


#edit
_arduino_edit() {
	_editFakeHome "$scriptAbsoluteLocation" _launch_env _arduino_executable "$@"
}

#user
_arduino_user() {
	_userShortHome "$scriptAbsoluteLocation" _launch_env _arduino_executable "$@"
}

#config, assumes portable directories have been setup
_arduino_config() {
	"$scriptAbsoluteLocation" _launch_env _arduino_executable "$@"
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

# ATTENTION Overload with ops! (well no, actually probably not any reason to do so here)
_arduino_compile_commands() {
	_messagePlain_nominal 'Compile.'
	
	mkdir -p "$shortTmp"/build
	_arduino_executable --save-prefs --pref build.path="$shortTmp"/build
	
	_arduino_executable --verify "$@"
	
	mkdir -p "$au_arduinoBuildPath"
	cp "$shortTmp"/build/*.bin "$au_arduinoBuildPath"/
	cp "$shortTmp"/build/*.hex "$au_arduinoBuildPath"/
	cp "$shortTmp"/build/*.elf "$au_arduinoBuildPath"/
}

_arduino_compile() {
	#_make_clean "$@" # DANGER Not recommended!
	
	_userShortHome "$scriptAbsoluteLocation" _launch_env _arduino_compile_commands "$@"
}


_arduino_upload_zero_commands() {
	_messagePlain_nominal 'Upload.'
	
	local arduinoBin
	
	arduinoBin="$1"
	! [[ -e "$arduinoBin" ]] && arduinoBin=$(find "$au_arduinoBuildPath" -maxdepth 1 -name '*.bin' | head -n 1)
	! [[ -e "$arduinoBin" ]] && _messagePlain_bad 'missing: arduinoBin= '"$arduinoBin" && return 1 
	
	#Upload over SWD debugger.
	_arduino_upload_swd_openocd_zero "$arduinoBin"
	
	if [[ $? != 0 ]]	#SWD upload failed.
	then
		_arduino_upload_serial_bossac "$arduinoBin"
	fi
	
	sleep 1
	! [[ -e "/dev/ttyACM0" ]] && ! [[ -e "/dev/ttyACM1" ]] && ! [[ -e "/dev/ttyACM2" ]] && ! [[ -e "/dev/ttyUSB0" ]] && ! [[ -e "/dev/ttyUSB1" ]] && ! [[ -e "/dev/ttyUSB2" ]] && sleep 3
	! [[ -e "/dev/ttyACM0" ]] && ! [[ -e "/dev/ttyACM1" ]] && ! [[ -e "/dev/ttyACM2" ]] && ! [[ -e "/dev/ttyUSB0" ]] && ! [[ -e "/dev/ttyUSB1" ]] && ! [[ -e "/dev/ttyUSB2" ]] && sleep 9
}

# ATTENTION Overload with ops!
_arduino_upload_commands() {
	_arduino_upload_zero_commands "$@"
}

#Applicable to other Arduino SAMD21 variants.
_arduino_upload() {
	_userShortHome "$scriptAbsoluteLocation" _launch_env _arduino_upload_commands "$@"
}

_arduino_run_commands() {
	_arduino_compile_commands "$@"
	_arduino_upload_commands $(find "$shortTmp"/build -maxdepth 1 -name '*.bin' | head -n 1)
}

#Applicable to other Arduino SAMD21 variants.
_arduino_run() {
	_userShortHome "$scriptAbsoluteLocation" _launch_env _arduino_run_commands "$@"
}

_here_gdbinit() {
cat << CZXWXcRMTo8EmM8i4d
#####Config
#search path
#	/arduino/sketch

#####Startup

file $1

#set substitute-path /arduino/_build/sketch /arduino/sketch
#set substitute-path /arduino/sketch/sketch.ino /arduino/sketch/sketch.ino.cpp

#####Remote

target extended-remote localhost:3333

monitor reset halt

monitor reset init


CZXWXcRMTo8EmM8i4d
}


#Applicable to other Arduino SAMD21 variants.
_arduino_debug_zero_commands() {
	_messagePlain_nominal 'Debug.'
	
	local arduinoBin
	
	arduinoBin="$1"
	! [[ -e "$arduinoBin" ]] && arduinoBin=$(find "$au_arduinoBuildPath" -maxdepth 1 -name '*.bin' | head -n 1)
	! [[ -e "$arduinoBin" ]] && _messagePlain_bad 'missing: arduinoBin= '"$arduinoBin" && return 1 
	
	local arduinoBuild
	
	arduinoBuild="$2"
	! [[ -e "$arduinoBuild" ]] && arduinoBuild="$shortTmp"/build
	! [[ -e "$arduinoBuild" ]] && _messagePlain_bad 'missing: arduinoBuild= '"$arduinoBuild" && return 1 
	
	_arduino_swd_openocd_zero &
	
	_here_gdbinit "$arduinoBin" > "$safeTmp"/.gdbinit
	
	_messagePlain_probe ddd --debugger "$au_gdbBin" -d "$2" -x "$safeTmp"/.gdbinit
	ddd --debugger "$au_gdbBin" -d "$2" -x "$safeTmp"/.gdbinit
	
	pkill openocd # TODO Replace, _killDaemon.
}

# ATTENTION Overload with ops!
_arduino_debug_commands() {
	_arduino_debug_zero_commands "$@"
}

_arduino_debug_actions() {
	_arduino_run_commands "$@"
	_arduino_debug_commands $(find "$shortTmp"/build -maxdepth 1 -name '*.elf' | head -n 1) "$shortTmp"/build
}

_arduino_debug() {
	_userShortHome "$scriptAbsoluteLocation" _launch_env _arduino_debug_actions "$@"
}






# ATTENTION By now, everything is already within a fakeHome subshell. AIDE will possess same fakeHome environment, exported variables, ane exported functions. However, "$scriptAbsoluteLocation" was invoked by _launch_env, creating a new session. Login shells may lose, or reimport, unexported functions.
_aide_commands() {
	
	_messagePlain_probe "$sessionid"
	. "$scriptAbsoluteLocation" --parent _echo true
	_messagePlain_probe "$sessionid"
	
	_gather_params "$@"
	_messagePlain_probe 'globalArgs= '"${globalArgs[@]}"
	
	export -f _arduino_run_actions
	
	#export keepFakeHome="false"
	atom --foreground "$@"
}

#"AppIDE", not "AtomIDE", or "ArduinoIDE".
_aide() {
	_userShortHome "$scriptAbsoluteLocation" _launch_env _aide_commands "$@"
}


_arduino_bootloader_m0() {
	"$globalFakeHome"/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/bin/openocd -d2 -s "$globalFakeHome"/.arduino15/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/ -f "$scriptLib"/ArduinoCore-samd/variants/arduino_mzero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {{""$scriptLib""/ArduinoCore-samd/bootloaders/mzero/Bootloader_D21_M0_150515.hex}} verify reset; shutdown"
}

_arduino_bootloader_zero() {
	"$globalFakeHome"/"$au_arduinoDir"/portable/packages/arduino/tools/openocd/0.9.0-arduino6-static/bin/openocd -d2 -s "$globalFakeHome"/"$au_arduinoDir"/portable/packages/arduino/tools/openocd/0.9.0-arduino6-static/share/openocd/scripts/ -f "$scriptLib"/ArduinoCore-samd/variants/arduino_zero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {{""$scriptLib""/ArduinoCore-samd/bootloaders/zero/samd21_sam_ba.bin}} verify reset; shutdown"
}

_arduino_bootloader() {
	_arduino_bootloader_zero "$@"
}


_arduino_blink() {
	_arduino_run "$scriptLib"/Blink/Blink.ino
}


#duplicate _anchor
_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_compile
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_upload
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_run
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_bootloader
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debug
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_aide
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_blink
}


#####^ Core
