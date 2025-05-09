_compile_bash_deps_prog() {
	true
}

#Default is to include all, or run a specified configuration. For this reason, it will be more typical to override this entire function, rather than append any additional code.
# WARNING Find current version of this function at "build/bash/compile_bash.sh"
# _compile_bash_deps() {
# 	[[ "$1" == "lean" ]] && return 0
# 	
# 	false
# }

_vars_compile_bash_prog() {
	#export configDir="$scriptAbsoluteFolder"/_config
	
	#export progDir="$scriptAbsoluteFolder"/_prog
	#export progScript="$scriptAbsoluteFolder"/ubiquitous_bash.sh
	#[[ "$1" != "" ]] && export progScript="$scriptAbsoluteFolder"/"$1"
	
	true
}

_compile_bash_header_prog() {	
	export includeScriptList
	true
}

_compile_bash_header_program_prog() {	
	export includeScriptList
	true
}

_compile_bash_essential_utilities_prog() {	
	export includeScriptList
	true
}

_compile_bash_utilities_virtualization_prog() {	
	export includeScriptList
	true
}

_compile_bash_utilities_prog() {	
	export includeScriptList
	true
}

_compile_bash_shortcuts_prog() {	
	export includeScriptList
	true
}

_compile_bash_shortcuts_setup_prog() {	
	export includeScriptList
	true
}

_compile_bash_bundled_prog() {	
	export includeScriptList
	true
}

_compile_bash_vars_basic_prog() {	
	export includeScriptList
	true
}

_compile_bash_vars_global_prog() {	
	export includeScriptList
	true
}

_compile_bash_vars_spec_prog() {	
	export includeScriptList
	true
}

_compile_bash_vars_shortcuts_prog() {	
	export includeScriptList
	true
}

_compile_bash_vars_virtualization_prog() {	
	export includeScriptList
	true
}

_compile_bash_vars_bundled_prog() {	
	export includeScriptList
	true
}

_compile_bash_buildin_prog() {	
	export includeScriptList
	true
}

_compile_bash_environment_prog() {	
	export includeScriptList
	true
}

_compile_bash_installation_prog() {	
	export includeScriptList
	true
}

_compile_bash_program_prog() {	
	export includeScriptList
	
	includeScriptList+=( core_arduino____installation.sh )
	includeScriptList+=( core_arduino____installation_default.sh )
	
	
	includeScriptList+=( core_arduino_env.sh )
	includeScriptList+=( core_arduino_bin_.sh )
	includeScriptList+=( core_arduino.sh )
	
	includeScriptList+=( core_arduino_scope.sh )
	
	includeScriptList+=( core_arduino_app.sh )
	includeScriptList+=( core_arduino_app_scope.sh )
	
	
	includeScriptList+=( core_arduino____device_zero.sh )
	includeScriptList+=( core_arduino____device_teensy3.6.sh )
	includeScriptList+=( core_arduino____device_mega2560.sh )
	#includeScriptList+=( core_arduino____device_default.sh )
	
	
	includeScriptList+=( core_arduino__build_ops.sh )
	includeScriptList+=( core_arduino__build_ops_default.sh )
	
	
	includeScriptList+=( core_arduino__build__debug_gdb.sh )
	includeScriptList+=( core_arduino__build__debug_ddd.sh )
	#includeScriptList+=( core_arduino__build__debug_atom.sh )
	#includeScriptList+=( core_arduino__build__debug_eclipse.sh )
	
	
	includeScriptList+=( core_arduino___build_compile.sh )
	includeScriptList+=( core_arduino___build_upload.sh )
	includeScriptList+=( core_arduino___build_run.sh )
	includeScriptList+=( core_arduino___build_bootloader.sh )
	
	
	includeScriptList+=( core_arduino____device_default.sh )
	
	
	#includeScriptList+=( core.sh )
	includeScriptList+=( core_default.sh )
	
	
	includeScriptList+=( installation_prog_arduino.sh )
	
	includeScriptList+=( _special.sh )
	
	includeScriptList+=( knowledge.sh )
}

_compile_bash_config_prog() {	
	export includeScriptList
	true
}

_compile_bash_selfHost_prog() {	
	export includeScriptList
	true
}

_compile_bash_overrides_prog() {	
	export includeScriptList
	true
}

_compile_bash_entry_prog() {	
	export includeScriptList
	true
}
