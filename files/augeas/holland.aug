(* Holland module for Augeas
 Author: Russell Harrison <rharrison@fedoraproject.org>

 holland.conf is almost a standard INI File.
*)

module Holland =
  autoload xfm

(************************************************************************
 * INI File settings
 *
 * holland.conf only supports "# as comment and "=" as separator
 * some values may be comma separated lists
 *************************************************************************)
let comment    = IniFile.comment "#" "#"
let sep        = IniFile.sep "=" "="
let comma      = del /[ \t]*,[ \t]*/ ", "

(************************************************************************
 *                        LISTS
 * Setup the comma seperated lists
 *************************************************************************)
let set_list  = Build.opt_list ([ label "set" . store Rx.word ]) comma
let path_list = Build.opt_list ([ label "path" . store Rx.neg1 ]) comma

(************************************************************************
 *                        ENTRY
 * holland.conf uses standard INI File entries and comma separated lists
 *************************************************************************)
let backupsets_entry =
  Build.key_value_line_comment "backupsets" sep ( Sep.opt_space
                                                . set_list
                                                ) comment
let plugindirs_entry =
  Build.key_value_line_comment "plugin_dirs" sep ( Sep.opt_space
                                                 . path_list
                                                 ) comment
let common_entry   = IniFile.indented_entry ( "backup_directory"
                                            | "umask"
                                            | "path"
                                            | "filename"
                                            | "level"
                                            ) sep comment

(************************************************************************
 *                        RECORD
 *************************************************************************)
let title   = IniFile.indented_title IniFile.record_re
let record  = IniFile.record title ( common_entry
                                   | backupsets_entry
                                   | plugindirs_entry
                                   )


(************************************************************************
 *                        LENS & FILTER
 *************************************************************************)
let lns    = IniFile.lns record comment
let filter = (incl "/etc/holland/holland.conf")
let xfm    = transform lns filter
