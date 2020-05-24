
##### specglobalvars #####

#Default not to create "project.afs" file, unless "$afs_nofs" explicitly set to "false".
[[ "$afs_nofs" != "false" ]] && export afs_nofs=true



##### specglobalvars_arduino #####
# ATTENTION: TODO: Defaults. Should be set by a function and included by such functions as '_declare_arduino_device_zero'. Other boards (ie. Teensyduino) may need to override partially.

export au_arduinoLocal="$scriptLocal"/arduino

_declare_arduino_installation_default





##### specglobalvars_arduino_device zero #####





