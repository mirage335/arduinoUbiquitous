#Redundant within scope. Required by any subshell operations (eg. _compile).
_import_ops_arduino_sketch() {
	if [[ -e "$au_arduinoSketchDir"/ops ]]
	then
		_messagePlain_nominal 'aU: found: sketch ops'
		. "$au_arduinoSketchDir"/ops
	fi
	
	if [[ -e "$au_arduinoSketchDir"/ops.sh ]]
	then
		_messagePlain_nominal 'aU: found: sketch ops'
		. "$au_arduinoSketchDir"/ops.sh
	fi
	
	! [[ -e "$au_arduinoSketchDir"/ops ]] && ! [[ -e "$au_arduinoSketchDir"/ops.sh ]] && _messagePlain_warn 'aU: missing: sketch ops' && return 1
	
	#_messagePlain_warn 'aU: missing: sketch ops'
	#return 1
	
	return 0
}



