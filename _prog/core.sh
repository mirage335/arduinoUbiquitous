


_refresh_anchors_specific() {
	#_refresh_anchors_specific_single_procedure _true
	
	_refresh_anchors_specific_arduino
}

_refresh_anchors_user() {
	#_refresh_anchors_user_single_procedure _true
	
	_refresh_anchors_user_arduino
}

#duplicate _anchor
_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope_konsole
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope_dolphin
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope_eclipse
	
	_refresh_anchors_arduino "$@"
	
	_tryExec "_refresh_anchors_task"
	
	return 0
}


