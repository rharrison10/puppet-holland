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
let comma     = del  /,[ \t]*/  ","

let entry_list (kw:regexp) (sep:lens) (sto:regexp) (list_sep:lens) (comment:lens) =
  let list = counter "elem"
    . Build.opt_list [ seq "elem" . store sto ] list_sep
  in Build.key_value_line_comment kw sep (Sep.opt_space . list) comment

(************************************************************************
 *                        ENTRY
 * holland.conf uses standard INI File entries and comma separated lists
 *************************************************************************)
let backupsets_entry = entry_list "backupsets" sep Rx.word comma comment
let plugindirs_entry = entry_list "plugin_dirs" sep Rx.neg1 comma comment
let common_entry   = IniFile.indented_entry ( "backup_directory" |
                                              "umask" |
                                              "path" |
                                              "filename" |
                                              "level"
                                            ) sep comment

(************************************************************************
 *                        RECORD
 * holland.conf uses standard INI File records
 *************************************************************************)
let title   = IniFile.indented_title IniFile.record_re
let record  = IniFile.record title (common_entry|backupsets_entry|plugindirs_entry)


(************************************************************************
 *                        LENS & FILTER
 * holland.conf uses standard INI File records
 *************************************************************************)
let lns     = IniFile.lns record comment

let filter = (incl "/etc/holland/holland.conf")

let xfm = transform lns filter
