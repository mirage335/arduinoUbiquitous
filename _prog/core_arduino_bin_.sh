_arduino_swd_openocd() {
	_messagePlain_probe_quoteAdd "$au_openocdStaticBin" -d2 -s "$au_openocdStaticScript" "$@" &
	"$au_openocdStaticBin" -d2 -s "$au_openocdStaticScript" "$@" &
	export au_openocdPID="$!"
}



_arduino_executable() {
	! [[ -e "$arduinoExecutable" ]] && export arduinoExecutable="$HOME"/"$au_arduinoVersion"/arduino
	! [[ -e "$arduinoExecutable" ]] && export arduinoExecutable="$au_arduinoDir"/arduino
	
	export sharedHostProjectDir=/
	export sharedGuestProjectDir=/
	_virtUser "$@"
	
	#Do not create "project.afs". Create elsewhere if desired.
	#export afs_nofs=true
	
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

_arduino_method() {
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
}

#assumes portable directories have been setup
# WARNING: No production use.
_arduino_method_config() {
	export arduinoExecutable="$au_arduinoDir"/arduino
	#export arduinoExecutable=
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	_arduino_executable "$@"
}



#Arduino may ignore "--pref" parameters, possibly due to bugs present in some versions. Consequently, it is possible some stored preferences may interfere with normal script operation. As a precaution, these are deleted.
_arduino_deconfigure_procedure() {
	local arduinoPreferences
	
	arduinoPreferences="$1"
	[[ "$arduinoPreferences" == '' ]] && arduinoPreferences="$HOME"/.arduino15/preferences.txt
	
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

_arduino_deconfigure_method() {
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_deconfigure_procedure "$@"
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_deconfigure_procedure "$au_arduinoLocal"/.arduino15/preferences.txt "$@"
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt "$@"
}



# WARNING: No production use.
# WARNING: May interfere with user global Arduino IDE installation.
# DANGER: May be obsolete and broken.
#Example.
_arduino_deconfigure_sequence() {
	_start
	
	# User global home folder.
	_arduino_deconfigure_procedure "$HOME"/.arduino15/preferences.txt
	
	_arduino_deconfigure_method
	_arduino_deconfigure_method "$au_arduinoLocal"/.arduino15/preferences.txt
	_arduino_deconfigure_method "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

# WARNING: No production use.
#Example.
#End-user.
_arduino_deconfigure() {
	"$scriptAbsoluteLocation" _arduino_deconfigure_sequence "$@"
}




