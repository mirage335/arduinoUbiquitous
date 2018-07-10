_set_share_abstractfs() {
	_set_share_abstractfs_reset
	
	#export sharedHostProjectDir="$abstractfs_base"
	export sharedHostProjectDir=$(_getAbsoluteFolder "$abstractfs_base")
	export sharedGuestProjectDir="$abstractfs"
	
	#Blank default. Resolves to lowest directory shared by "$PWD" and "$@" .
	#export sharedHostProjectDir="$sharedHostProjectDirDefault"
}

_set_arduino_userShortHome() {
	export actualFakeHome="$shortFakeHome"
	export fakeHomeEditLib="false"
	export keepFakeHome="true"
}

_set_arduino_editShortHome() {
	export actualFakeHome="$shortFakeHome"
	export fakeHomeEditLib="true"
	export keepFakeHome="true"
}

# WARNING: No production use expected.
_set_arduino_userFakeHome() {
	export actualFakeHome="$instancedFakeHome"
	export fakeHomeEditLib="false"
	export keepFakeHome="true"
}

# WARNING: No production use expected.
_set_arduino_editFakeHome() {
	export actualFakeHome="$globalFakeHome"
	export fakeHomeEditLib="false"
	export keepFakeHome="true"
}

_prepare_arduino_installation() {
	mkdir -p "$au_arduinoLocal"/.arduino15
	mkdir -p "$au_arduinoLocal"/Arduino
	
	mkdir -p "$au_arduinoDir"
	
	mkdir -p "$au_arduinoDir"/portable
	mkdir -p "$au_arduinoDir"/portable/sketchbook
	
	_relink ../.arduino15 "$au_arduinoDir"/portable
	_relink ../Arduino "$au_arduinoDir"/portable/sketchbook
	
	#Default not to create "project.afs" file, unless "$afs_nofs" explicitly set to "false".
	[[ "$afs_nofs" != "false" ]] && export afs_nofs=true
	[[ -e "$au_arduinoSketchDir" ]] && _abstractfs true "$au_arduinoSketchDir"
}

_install_fakeHome_arduino() {
	_prepare_arduino_installation
	
	_link_fakeHome "$au_arduinoDir" "$au_arduinoVersion"
	
	_link_fakeHome "$au_arduinoLocal"/.arduino15 .arduino15
	_link_fakeHome "$au_arduinoLocal"/Arduino Arduino
}

_install_fakeHome_app() {
	_install_fakeHome_arduino
}

_reset_arduino_sketchDir() {
	export au_arduinoSketch=
	export au_arduinoSketchDir=
	export au_basename=
}

_validate_arduino_sketchDir() {
	local au_basename_test
	
	! [[ -e "$au_arduinoSketch" ]] && return 1
	! [[ -e "$au_arduinoSketchDir" ]] && return 1
	! [[ -d "$au_arduinoSketchDir" ]] && return 1
	
	au_basename_test=$(basename "$au_arduinoSketchDir")
	! [[ -e "$au_arduinoSketchDir"/"$au_basename_test".ino ]] && return 1
	! [[ -e "$au_arduinoSketchDir"/"$au_basename".ino ]] && return 1
	
	[[ "$au_arduinoSketch" != "$au_arduinoSketchDir"/"$au_basename_test".ino ]] && return 1
	[[ "$au_arduinoSketch" != "$au_arduinoSketchDir"/"$au_basename".ino ]] && return 1
	
	return 0
}

# WARNING: Scope directory as first parameter is only supported method. All other methods are for convenience only, may be disabled, and must not be relied on.
_set_arduino_sketchDir() {
	if [[ -d "$1" ]] && [[ -e "$1" ]]
	then
		_reset_arduino_sketchDir
		export au_arduinoSketchDir=$(_getAbsoluteLocation "$1")
		export au_basename=$(basename "$au_arduinoSketchDir")
		export au_arduinoSketch="$au_arduinoSketchDir"/"$au_basename".ino
		
		_validate_arduino_sketchDir && return 0
		
		#Fallback. Fatal error, tool.
		_messagePlain_bad 'missing: au_arduinoSketch'
		return 1
	fi
	
	if [[ "$1" == *".ino" ]] && [[ -e "$1" ]]
	then
		_reset_arduino_sketchDir
		export au_arduinoSketch=$(_getAbsoluteLocation "$1")
		export au_arduinoSketchDir=$(_getAbsoluteFolder "$1")
		export au_basename=$(basename "$au_arduinoSketchDir")
		_validate_arduino_sketchDir && return 0
		
		#Fallback. Fatal error, tool.
		_messagePlain_bad 'mismatch: au_arduinoSketch, au_arduinoSketchDir'
		return 1
	fi
	
	_reset_arduino_sketchDir
	export au_arduinoSketchDir=$(_getAbsoluteLocation "$PWD")
	au_basename=$(basename "$au_arduinoSketchDir")
	export au_arduinoSketch="$au_arduinoSketchDir"/"$au_basename".ino
	_validate_arduino_sketchDir && return 0
	
	#Fallback. Fatal error, tool.
	_messagePlain_bad 'missing: ./"$au_arduinoSketch"'
	return 1
}

_check_arduino_debug() {
	_checkPort_local "$au_remotePort" && return 1
	return 0
}

_set_arduino_var() {
	if ! _set_arduino_sketchDir "$@"
	then
		return 1
	fi
	
	export au_arduinoBuildOut="$au_arduinoSketchDir"/_build
	
	_checkPort_local "$au_remotePort" && export au_remotePort=$(_findPort)
	[[ "$au_remotePort" == "" ]] && export au_remotePort=$(_findPort)
	! _check_arduino_debug && return 1
	
	#Consistent name for ELF binary file, to be used by any debuggers which are infeasible to update with heurestically determined filename strings.
	#export au_arduinoFirmware_sym="$au_arduinoBuildOut"/"$au_basename".ino.elf
	export au_arduinoFirmware_sym="$shortTmp"/_build/"$au_basename".ino.elf
	
	
	_messagePlain_probe 'au_arduinoSketch= '"$au_arduinoSketch"
	_messagePlain_probe 'au_arduinoSketchDir= '"$au_arduinoSketchDir"
	
	_messagePlain_probe 'au_arduinoFirmware_bin= '"$au_arduinoFirmware_bin"
	_messagePlain_probe 'au_arduinoFirmware_elf= '"$au_arduinoFirmware_elf"
	
	_messagePlain_probe 'au_remotePort= '"$au_remotePort"
	
	_messagePlain_probe 'au_arduinoFirmware_sym= '"$au_arduinoFirmware_sym"
	
	return 0
}

_scope_var_here_prog() {
	cat << CZXWXcRMTo8EmM8i4d

#Global Variables and Defaults
export au_arduinoLocal="$scriptLocal"/arduino

export au_arduinoVersion=arduino-1.8.5
export au_arduinoDir="$au_arduinoLocal"/"$au_arduinoVersion"

export au_gdbBin="$au_arduinoLocal"/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1/bin/arm-none-eabi-gdb

export au_openocdStatic="$scriptLib"/openocd-static
export au_openocdStaticUB="$au_openocdStatic"/ubiquitous_bash.sh
export au_openocdStaticBin="$au_openocdStatic"/build/bin/openocd
export au_openocdStaticScript="$au_openocdStatic"/build/share/openocd/scripts


#Sketch
export au_arduinoSketch="$au_arduinoSketch"
export au_arduinoSketchDir="$au_arduinoSketchDir"
export au_arduinoBuildOut="$au_arduinoBuildOut"

#Debug
export au_remotePort="$au_remotePort"
export au_arduinoFirmware_sym="$au_arduinoFirmware_sym"

CZXWXcRMTo8EmM8i4d
}

_scope_attach() {
	_messagePlain_nominal '_scope_attach: init'
	
	if ! _set_arduino_var "$@"
	then
		_messagePlain_bad 'fail: _set_arduino_var'
		_stop 1
	fi
	
	[[ "$au_arduinoSketchDir" != "$ub_specimen" ]] && _messagePlain_bad 'fail: mismatch: au_arduinoSketchDir, ub_specimen' && _stop 1
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	_messagePlain_nominal '_scope_attach: deploy'
	
	_scope_here > "$ub_scope"/.devenv
	_scope_readme_here > "$ub_scope"/README
	
	_scope_command_write _scope_konsole_procedure
	_scope_command_write _scope_dolphin_procedure
	_scope_command_write _scope_eclipse_procedure
	_scope_command_write _scope_atom_procedure
	
	_scope_command_write _arduinoide
	
	_scope_command_write _bootloader
	
	_scope_command_write _compile
	_scope_command_write _upload
	_scope_command_write _run
	
	_scope_command_write _debug_gdb
	_scope_command_write _debug_ddd
	
	_scope_command_write _interface_debug_atom
	_scope_command_write _interface_debug_eclipse
}

_arduino_scope() {
	export ub_scope_name='arduino'
	_scope "$@"
}

#virtualized
_v_arduino() {
	_userQemu "$scriptAbsoluteLocation" _arduino_scope "$@"
}

#default
_arduino() {
	if ! _check_prog
	then
		_messageNormal 'Launch: _v'${FUNCNAME[0]}
		_v${FUNCNAME[0]} "$@"
		return
	fi
	_arduino_scope "$@" && return 0

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
	#_arduino_deconfigure_method
	_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

#edit, fakeHome
_arduino_edit() {
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
	_arduino_deconfigure_method
	#_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

_arduinoide() {
	"$scriptAbsoluteLocation" _arduino_edit "$@"
}

_set_arduino_board_zero_native() {
	_messagePlain_nominal 'aU: set: board'
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_platform=samd --pref board=arduino_zero_native
}

# ATTENTION: Overload with ops!
_prepare_arduino_board() {
	#_messagePlain_nominal 'aU: set: board'
	#_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_platform=samd --pref board=arduino_zero_native
	_set_arduino_board_zero_native
}

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
	_messagePlain_good 'Done.'
}

# WARNING: No production use. Obsolete hardware, upstream bugs in development tools. Recommend programming as zero.
_arduino_bootloader_m0() {
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_swd_openocd_zero -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/mzero/Bootloader_D21_M0_150515.hex} verify reset; shutdown"
	wait "$au_openocdPID"
	export au_remotePort="$au_remotePort_orig"
}

_arduino_bootloader_zero() {
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_swd_openocd_zero -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/zero/samd21_sam_ba.bin} verify reset; shutdown"
	wait "$au_openocdPID"
	export au_remotePort="$au_remotePort_orig"
}

# ATTENTION: Overload with ops!
_arduino_bootloader() {
	_arduino_bootloader_zero "$@"
	_messagePlain_probe "done: _arduino_bootloader"
}

_bootloader() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_bootloader "$@"
	_messagePlain_good 'Done.'
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

_arduino_upload_procedure_zero() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Upload.'
	
	_set_arduino_firmware
	
	! [[ -e "$au_arduinoFirmware_bin" ]] && _messagePlain_bad 'fail: missing: firmware' > /dev/tty 2>&1 && return 1
	
	local swdUploadStatus
	
	#Upload over SWD debugger.
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_upload_swd_openocd_zero
	swdUploadStatus=$?
	export au_remotePort="$au_remotePort_orig"
	
	if [[ "$swdUploadStatus" != 0 ]]	#SWD upload failed.
	then
		_arduino_serial_bossac_device
	fi
	
	sleep 1
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	sleep 3
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	sleep 9
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	return 1
	
	cd "$localFunctionEntryPWD"
}

# ATTENTION Overload with ops!
_arduino_upload_procedure() {
	_arduino_upload_procedure_zero "$@"
}

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
	_messagePlain_good 'Done.'
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
	_messagePlain_good 'Done.'
}










_arduino_blink() {
	_arduino_run "$scriptLib"/Blink
}

_refresh_anchors_task() {
	true
}

#duplicate _anchor
_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope_konsole
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope_eclipse
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduinoide
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_compile
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_upload
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_run
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_bootloader
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debug
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_blink
	
	_tryExec "_refresh_anchors_task"
	
	#Critical PATH Inclusions
	# WARNING Hardcoded "ub_import_param" required, do NOT overwrite automatically!
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_interface_debug_atom
}


