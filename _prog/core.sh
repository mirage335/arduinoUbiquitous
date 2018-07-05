



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
}

_validate_arduino_sketchDir() {
	local au_basename_test
	
	! [[ -e "$au_arduinoSketch" ]] && return 1
	! [[ -e "$au_arduinoSketchDir" ]] && return 1
	! [[ -d "$au_arduinoSketchDir" ]] && return 1
	
	au_basename_test=$(basename "$au_arduinoSketchDir")
	! [[ -e "$au_arduinoSketchDir"/"$au_basename_test".ino ]] && return 1
	
	[[ "$au_arduinoSketch" != "$au_arduinoSketchDir"/"$au_basename_test".ino ]] && return 1
	
	return 0
}

# WARNING: Scope directory as first parameter is only supported method. All other methods are for convenience only, may be disabled, and must not be relied on.
_set_arduino_sketchDir() {
	local au_basename_test
	
	if [[ -d "$1" ]] && [[ -e "$1" ]]
	then
		_reset_arduino_sketchDir
		au_basename_test=
		export au_arduinoSketchDir=$(_getAbsoluteLocation "$1")
		au_basename_test=$(basename "$au_arduinoSketchDir")
		export au_arduinoSketch="$au_arduinoSketchDir"/"$au_basename_test".ino
		
		_validate_arduino_sketchDir && return 0
		
		#Fallback. Fatal error, tool.
		_messagePlain_bad 'missing: au_arduinoSketch'
		return 1
	fi
	
	if [[ "$1" == *".ino" ]]
	then
		_reset_arduino_sketchDir
		au_basename_test=
		export au_arduinoSketch=$(_getAbsoluteLocation "$1")
		export au_arduinoSketchDir=$(_getAbsoluteFolder "$1")
		_validate_arduino_sketchDir && return 0
		
		#Fallback. Fatal error, tool.
		_messagePlain_bad 'mismatch: au_arduinoSketch, au_arduinoSketchDir'
		return 1
	fi
	
	_reset_arduino_sketchDir
	au_basename_test=
	export au_arduinoSketchDir=$(_getAbsoluteLocation "$PWD")
	au_basename_test=$(basename "$au_arduinoSketchDir")
	export au_arduinoSketch="$au_arduinoSketchDir"/"$au_basename_test".ino
	_validate_arduino_sketchDir && return 0
	
	#Fallback. Fatal error, tool.
	_messagePlain_bad 'missing: ./"$au_arduinoSketch"'
	return 1
}

_set_arduino_compile() {
	export au_arduinoBuildOut="$au_arduinoSketchDir"/_build
}

_set_arduino_var() {
	_set_arduino_sketchDir "$@"
	_set_arduino_compile
	_messagePlain_probe 'au_arduinoSketch= '"$au_arduinoSketch"
	_messagePlain_probe 'au_arduinoSketchDir= '"$au_arduinoSketchDir"
}

#Example, override with "core.sh" .
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





#au_arduinoFirmware
#au_arduinoFirmware_bin
#au_arduinoFirmware_elf

#au_arduinoFirmware


#setFakeHome

#au_arduinoInstallation

CZXWXcRMTo8EmM8i4d
}

#Example, override with "core.sh" .
_scope_attach() {
	_messagePlain_nominal '_scope_attach: init'
	
	export afs_nofs=true
	
	_set_arduino_var "$@"
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	_messagePlain_nominal '_scope_attach: deploy'
	
	_scope_here > "$ub_scope"/.devenv
	_scope_readme_here > "$ub_scope"/README
	
	_scope_command_write _arduinoide
	
	_scope_command_write _compile
	_scope_command_write _upload
	_scope_command_write _run
	
	_scope_command_write _gdb
	
	_scope_command_write _ddd
	_scope_command_write _interface_debug_atom
	_scope_command_write _atom
	_scope_command_write _interface_debug_eclipse
	_scope_command_write _eclipse
}

_arduino_scope() {
	export ub_scope_name='arduino'
	"$scriptAbsoluteLocation" _scope_sequence "$@"
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

#Redundant under scope.
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
	
	_messagePlain_probe "$arduinoExecutable" "$@"
	_messagePlain_probe "$arduinoExecutable" "${processedArgs[@]}"
	"$arduinoExecutable" "${processedArgs[@]}"
}

#Arduino may ignore "--pref" parameters, possibly due to bugs present in some versions. Consequently, it is possible some stored preferences may interfere with normal script operation. As a precaution, these are deleted.
_arduino_deconfigure_procedure() {
	local arduinoPreferences
	
	arduinoPreferences="$1"
	
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
	
	_set_arduino_var "$@"
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_prepare_arduino_installation
	export arduinoExecutable="$au_arduinoDir"/arduino
	#export arduinoExecutable=
	
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	_arduino_executable "$@"
	
	_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

#edit, fakeHome
_arduino_edit() {
	_start
	
	_set_arduino_var "$@"
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
	
	_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

_arduinoide() {
	_arduino_edit "$@"
}


# ATTENTION: Overload with ops! (well no, actually probably not any reason to do so here)
_arduino_compile_procedure() {
	_messagePlain_nominal 'Compile.'
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	_set_arduino_userShortHome
	
	mkdir -p "$shortTmp"/_build
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable --save-prefs --pref build.path="$shortTmp"/_build
	
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable --verify "$au_arduinoSketch"
	
	mkdir -p "$au_arduinoSketchDir"/_build
	cp "$shortTmp"/_build/*.bin "$au_arduinoSketchDir"/_build/
	cp "$shortTmp"/_build/*.hex "$au_arduinoSketchDir"/_build/
	cp "$shortTmp"/_build/*.elf "$au_arduinoSketchDir"/_build/
}

_arduino_compile_sequence() {
	_start
	
	_set_arduino_var "$@"
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
	_arduino_compile_procedure "$@"
	
	_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

_arduino_compile() {
	_arduino_compile_sequence "$@"
}

_compile() {
	_arduino_compile_procedure "$@"
}









_refresh_anchors_task() {
	true
}

#duplicate _anchor
_refresh_anchors() {
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
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_gdb
}


