


# 
# _arduino_example_blink() {
# 	_arduino_run "$scriptLib"/Blink
# }
# 
# 
# 
# _task_scope_arduinoide_blink() {
# 	_scope_arduinoide "$scriptLib"/Blink "$@"
# }
# 
# 
# # ATTENTION: Add to ops!
_refresh_anchors_task() {
	true
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_task_arduino_compile_blink
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_task_scope_arduinoide_blink
}

# # ATTENTION: Add to ops!
_refresh_anchors_arduino_rewrite() {
	true
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_rewrite
}

_refresh_anchors_arduino() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_arduinoide_user
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_arduinoide_edit
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope_arduino
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope_arduino_arduinoide
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_compile
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_upload
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_run
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debug_ddd
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debugrun_ddd
	
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debug_gdb
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debugrun_gdb
	
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debug_atom
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debugrun_atom
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_interface_debug_atom
	
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debug_eclipse
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_debugrun_eclipse
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_interface_debug_eclipse
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_bootloader
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_bootloader_zero
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_bootloader_m0
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_bootloader_mkr1000
	
	
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_arduino_example_blink
	
	#_tryExec '_arduino_example_blink'
	#_tryExec '_task_scope_arduinoide_blink'
	
	_tryExec '_refresh_anchors_task'
	
	_tryExec '_refresh_anchors_arduino_rewrite'
	
	
	##### - BEGIN - Critical PATH Inclusions
	# WARNING Hardcoded "ub_import_param" required, do NOT overwrite automatically!
	
	
	# WARNING: Part of a system considered too unstable for production or end-user . May not be maintained.
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_interface_debug_atom
	
	##### - END - Critical PATH Inclusions
}


_refresh_anchors_specific_arduino() {
	_refresh_anchors_specific_single_procedure _scope_konsole
	
	_refresh_anchors_specific_single_procedure _scope_arduino_arduinoide
	
	_refresh_anchors_specific_single_procedure _arduino_compile
	_refresh_anchors_specific_single_procedure _arduino_upload
	_refresh_anchors_specific_single_procedure _arduino_debug_ddd
	
	_refresh_anchors_specific_single_procedure _arduino_bootloader
}

_refresh_anchors_user_arduino() {
	_refresh_anchors_user_single_procedure _scope_konsole
	
	_refresh_anchors_user_single_procedure _scope_arduino_arduinoide
	
	_refresh_anchors_user_single_procedure _arduino_compile
	_refresh_anchors_user_single_procedure _arduino_upload
	_refresh_anchors_user_single_procedure _arduino_debug_ddd
	
	#_refresh_anchors_user_single_procedure _arduino_bootloader
}

_associate_anchors_request() {
	if type "_refresh_anchors_user" > /dev/null 2>&1
	then
		_tryExec "_refresh_anchors_user"
		#return
	fi
	
	_messagePlain_request 'association: dir'
	echo _scope_konsole"$ub_anchor_suffix"
	
	_messagePlain_request 'association: dir'
	echo _scope_arduino_arduinoide"$ub_anchor_suffix"
	
	
	_messagePlain_request 'association: dir, *.ino'
	echo _arduino_compile"$ub_anchor_suffix"
	
	_messagePlain_request 'association: dir, *.ino'
	echo _arduino_upload"$ub_anchor_suffix"
	
	_messagePlain_request 'association: dir, *.ino'
	echo _arduino_debug_ddd"$ub_anchor_suffix"
}






