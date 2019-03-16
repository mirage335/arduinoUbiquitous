
#virtualized
_v_arduino() {
	_userQemu "$scriptAbsoluteLocation" _scope_arduinoide "$@"
}

#default
_arduino() {
	if ! _check_prog
	then
		_messageNormal 'Launch: _v'${FUNCNAME[0]}
		_v${FUNCNAME[0]} "$@"
		return
	fi
	_scope_arduinoide "$@" && return 0

	#_messageNormal 'Launch: _v'${FUNCNAME[0]}
	#_v${FUNCNAME[0]} "$@"
}

#Intended to be used as an ops override.
_ops_arduino_sketch() {
	true
}

#Redundant within scope. Required by any subshell operations (eg. _compile).
_import_ops_sketch() {
	if [[ -e "$au_arduinoSketchDir"/ops ]]
	then
		_messagePlain_nominal 'aU: found: sketch ops'
		. "$au_arduinoSketchDir"/ops
		return 1
	fi
	
	_messagePlain_warn 'aU: missing: sketch ops'
	return 0
}

_arduino_executable() {
	! [[ -e "$arduinoExecutable" ]] && export arduinoExecutable="$HOME"/"$au_arduinoVersion"/arduino
	! [[ -e "$arduinoExecutable" ]] && export arduinoExecutable="$au_arduinoDir"/arduino
	
	export sharedHostProjectDir=/
	export sharedGuestProjectDir=/
	_virtUser "$@"
	
	#Do not create "project.afs". Create elsewhere if desired.
	export afs_nofs=true
	
	#_JAVA_OPTIONS "user.home" updated by _fakeHome
	[[ "$setFakeHome" != "true" ]] && _messagePlain_warn 'aU: undetected: setFakeHome: unset: java: user.home'
	if [[ "$setFakeHome" == "true" ]]
	then
		if ! _safeEcho_newline "$_JAVA_OPTIONS" | grep "$HOME" > /dev/null 2>&1
		then
			_messagePlain_good 'aU: detected: setFakeHome: set: java: user.home'
			export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
		else
			_messagePlain_good 'aU: detected: setFakeHome: detected: java: user.home'
		fi
	fi
	
	_messagePlain_probe 'localPWD= '"$localPWD"
	_messagePlain_probe 'abstractfs_base= '"$abstractfs_base"
	#_messagePlain_probe _abstractfs "$arduinoExecutable" "$@"
	_messagePlain_probe _abstractfs "$arduinoExecutable" "${processedArgs[@]}"
	_abstractfs "$arduinoExecutable" "${processedArgs[@]}"
}

# ATTENTION: Overload with ops!
_arduino_method() {
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
}

#Arduino may ignore "--pref" parameters, possibly due to bugs present in some versions. Consequently, it is possible some stored preferences may interfere with normal script operation. As a precaution, these are deleted.
_arduino_deconfigure_procedure() {
	local arduinoPreferences
	
	arduinoPreferences="$1"
	
	#! [[ -e "$arduinoPreferences" ]] && arduinoPreferences="$HOME"/.arduino15/preferences.txt
	! [[ -e "$arduinoPreferences" ]] && _messagePlain_bad 'aU: missing: preferences' && return 1
	
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
	
	[[ -e "$safeTmp"/preferences.txt ]] && _messagePlain_bad 'aU: fail: mv preferences' && return 1
	
	grep '^sketchbook\.path' "$arduinoPreferences" >/dev/null 2>&1 && _messagePlain_bad 'aU: fail: deconfigure: sketchbook.path' && return 1
	grep '^last\.' "$arduinoPreferences" >/dev/null 2>&1 && _messagePlain_bad 'aU: fail: deconfigure: last' && return 1
	grep '^recent\.' "$arduinoPreferences" >/dev/null 2>&1 && _messagePlain_bad 'aU: fail: deconfigure: recent' && return 1
	grep '^build\.path' "$arduinoPreferences" >/dev/null 2>&1 && _messagePlain_bad 'aU: fail: deconfigure: build.path' && return 1
	
	return 0
}

_arduino_deconfigure_method_procedure() {
	_arduino_deconfigure_procedure "$HOME"/.arduino15/preferences.txt
}

# ATTENTION: Overload with ops!
_arduino_deconfigure_method() {
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_deconfigure_method_procedure "$@"
}

#Example. No direct production use.
_arduino_deconfigure_sequence() {
	_start
	
	_arduino_deconfigure_procedure "$HOME"/.arduino15/preferences.txt
	_arduino_deconfigure_procedure "$au_arduinoLocal"/.arduino15/preferences.txt
	_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

#End-user. No direct production use.
_arduino_deconfigure() {
	"$scriptAbsoluteLocation" _arduino_deconfigure_sequence "$@"
}

#config, assumes portable directories have been setup
# WARNING: No production use.
_arduino_config() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		true
		#_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_prepare_arduino_installation
	
	export arduinoExecutable="$au_arduinoDir"/arduino
	#export arduinoExecutable=
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	_arduino_executable "$@"
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	#_arduino_deconfigure_method
	_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

#edit, fakeHome
_arduinoide_edit() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		true
		#_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_prepare_arduino_installation
	
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_arduino_deconfigure_method
	#_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}
_arduino_edit() {
	_arduinoide_edit "$@"
}

_arduinoide_user() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		true
		#_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_arduino_deconfigure_method
	#_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}
_arduino_user() {
	_arduinoide_user "$@"
}

_arduinoide() {
	"$scriptAbsoluteLocation" _arduino_edit "$@"
}


###
### variant set/prepare kept at "_variant.sh"
###

_set_arduino_compile() {
	true
}

# ATTENTION: Overload with ops! (well no, actually probably not any reason to do so here)
_arduino_compile_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Compile.'
	
	#Current directory is generally irrelevant to arduino, and if different from sketchDir, may cause problems.
	cd "$au_arduinoSketchDir"
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	_set_arduino_userShortHome
	
	mkdir -p "$shortTmp"/_build
	_arduino_method --save-prefs --pref build.path="$shortTmp"/_build
	
	_set_arduino_userShortHome
	_prepare_arduino_board "$@"
	
	_set_arduino_userShortHome
	_arduino_method --verify "$au_arduinoSketch"
	
	mkdir -p "$au_arduinoBuildOut"
	cp "$shortTmp"/_build/*.bin "$au_arduinoBuildOut"/
	cp "$shortTmp"/_build/*.hex "$au_arduinoBuildOut"/
	cp "$shortTmp"/_build/*.elf "$au_arduinoBuildOut"/
	
	cd "$localFunctionEntryPWD"
}

_arduino_compile_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	#_arduino_method "$@"
	#_arduino_executable "$@"
	_arduino_compile_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_compile() {
	"$scriptAbsoluteLocation" _arduino_compile_sequence "$@"
}

_compile() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_compile_procedure "$@"
	_messagePlain_good 'End.'
}

###
### variant bootloader kept at "_variant.sh"
###

_arduino_bootloader_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_bootloader_procedure "$@"
	
	_stop
}


_arduino_bootloader() {
	"$scriptAbsoluteLocation" _arduino_bootloader_sequence "$@"
	_messagePlain_probe "done: _arduino_bootloader"
}

_bootloader() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_bootloader_procedure "$@"
	_messagePlain_good 'End.'
}

_check_arduino_firmware() {
	! [[ -e "$au_arduinoFirmware_bin" ]] && return 1
	! [[ -e "$au_arduinoFirmware_elf" ]] && return 1
	! [[ -e "$au_arduinoFirmware" ]] && return 1
	! [[ -d "$au_arduinoFirmware" ]] && return 1
	return 0
}

_set_arduino_firmware() {
	export au_arduinoFirmware_bin=$(find "$shortTmp"/_build -maxdepth 1 -name '*.bin' 2> /dev/null | head -n 1)
	! [[ -e "$au_arduinoFirmware_bin" ]] && export au_arduinoFirmware_bin=$(find "$au_arduinoBuildOut" -maxdepth 1 -name '*.bin' 2> /dev/null | head -n 1)
	
	export au_arduinoFirmware_elf=$(find "$shortTmp"/_build -maxdepth 1 -name '*.elf' 2> /dev/null | head -n 1)
	! [[ -e "$au_arduinoFirmware_elf" ]] && export au_arduinoFirmware_elf=$(find "$au_arduinoBuildOut" -maxdepth 1 -name '*.elf' 2> /dev/null | head -n 1)
	
	if [[ -e "$au_arduinoFirmware_elf" ]]
	then
		export au_arduinoFirmware=$(_getAbsoluteFolder "$au_arduinoFirmware_elf")
	fi
	
	if [[ -e "$au_arduinoFirmware_bin" ]]
	then
		export au_arduinoFirmware=$(_getAbsoluteFolder "$au_arduinoFirmware_bin")
	fi
	
	! _check_arduino_firmware && return 1
}

_arduino_upload_swd_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Upload.'
	
	_set_arduino_firmware
	
	! [[ -e "$au_arduinoFirmware_bin" ]] && _messagePlain_bad 'fail: missing: firmware' > /dev/tty 2>&1 && return 1
	
	local swdUploadStatus
	
	#Upload over SWD debugger.
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_upload_swd_openocd_device
	swdUploadStatus=$?
	export au_remotePort="$au_remotePort_orig"
	
	if [[ "$swdUploadStatus" != 0 ]]	#SWD upload failed.
	then
		_arduino_upload_serial_bossac_device
	fi
	
	_arduino_serial_wait
	
	cd "$localFunctionEntryPWD"
}

# TODO: Placeholder for AVR.
_arduino_upload_avrisp_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Upload.'
	
	_set_arduino_firmware
	
	! [[ -e "$au_arduinoFirmware_bin" ]] && _messagePlain_bad 'fail: missing: firmware' > /dev/tty 2>&1 && return 1
	
	local avrispUploadStatus
	
	#Upload over SWD debugger.
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	
	# TODO
	false
	#_arduino_upload_swd_openocd_device
	
	avrispUploadStatus=$?
	export au_remotePort="$au_remotePort_orig"
	
	if [[ "$avrispUploadStatus" != 0 ]]	#AVRISP upload failed.
	then
		
		# TODO
		false
		#_arduino_upload_serial_bossac_device
		
	fi
	
	_arduino_serial_wait
	
	cd "$localFunctionEntryPWD"
}


###
### variant upload kept at "_variant.sh"
###


_arduino_upload_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	#_arduino_method "$@"
	#_arduino_executable "$@"
	_arduino_upload_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_upload() {
	"$scriptAbsoluteLocation" _arduino_upload_sequence "$@"
}

_upload() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_upload_procedure "$@"
	_messagePlain_good 'End.'
}

# ATTENTION Overload with ops!
_arduino_run_procedure() {
	_arduino_compile_procedure "$@"
	_arduino_upload_procedure "$@"
}

_arduino_run_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	#_arduino_method "$@"
	#_arduino_executable "$@"
	_arduino_run_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_run() {
	"$scriptAbsoluteLocation" _arduino_run_sequence "$@"
}

_run() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_run_procedure "$@"
	_messagePlain_good 'End.'
}
