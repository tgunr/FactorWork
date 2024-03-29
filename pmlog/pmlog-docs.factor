! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings ;

IN: pmlog

HELP: PMLOG
{ $values
  { "msg" "string to send to syslog" }
  { "file" "string with path to file and line number" }
  { "word" "word being logged" }
  { "level" "log level" }    
}
{ $description "Sends message along with the file, line number and word to syslogd using the log level." } ;

HELP: PMLOG-Level-String
{ $values
    { "level" integer }
    { "string" string }
}
{ $description "Returns the string used for the log level" } ;

HELP: PMLOGLEVEL-TEST
{ $description "Testing word to send a msg with each production log level. Results should be visible in your syslog." } ;

HELP: PMLOGWITHLEVEL
{ $values
  { "msg" "string to send to syslog" }
  { "level" "log level" }    
}
{ $description "Sends message to syslogd using the specified log level." } ;

HELP: PMLOG_ALERT
{ $values { "msg" "string to send to syslog" } }
  { $description "Sends message to syslogd using the ALERT log level." } ;

HELP: PMLOG_CRITICAL
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the CRITICAL log level." } ;

HELP: PMLOG_DEBUG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG log level." } ;

HELP: PMLOG_EMERG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the EMERGENCY log level." } ;

HELP: PMLOG_ERR
  { $values
    { "msg" "string to send to syslog" }
    { "error" integer }
  } 
  { $description "Conditionally test the error value and sends test message to syslogd regardless of log level." } ;

HELP: PMLOG_ERROR
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the ERROR log level." } ;

HELP: PMLOG_HERE
  { $description "Sends test message to syslogd regardless of log level. Commonly used to just verify code is reached" } ;

HELP: PMLOG_INFO
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the INFO log level." } ;

HELP: PMLOG_NOTE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends note message to syslogd regardless of log level." } ;

HELP: PMLOG_NOTICE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the NOTICE log level." } ;

HELP: PMLOG_PopVerbose
{ $description "Returns log level to previous level" } ;

HELP: PMLOG_PushVerbose
{ $values
    { "level" integer }    
}
{ $description "Saves the current log level and establishes a new log level. Use this to control log level in loops where you may not wish to view reams of information" }
;

HELP: PMLOG_SetVerbose
{ $values
    { "level" integer }    
}
{ $description "Set the current log level." } ;

HELP: PMLOG_TEST
{ $values { "msg" "string to send to syslog" } }
{ $description "Test message to syslogd regardless of log level." } ;

HELP: PMLOG_VALUE
{ $values
  { "msg" "string to send to syslog" }
  { "value" integer }
}
  { $description "Test message along with a value to syslogd regardless of log level." } ;

HELP: PMLOG_WARNING
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the WARNING log level." } ;

HELP: PMLogLevelAlert
{ $values
        { "value" integer }
}
{ $description "Value for the ALERT log level" } ;

HELP: PMLogLevelCritical
{ $values
        { "value" integer }
}
{ $description "Value for the CRITICAL log level" } ;

HELP: PMLogLevelDebug
{ $values
        { "value" integer }
}
{ $description "Value for the DEBUG log level" } ;

HELP: PMLogLevelEmerg
{ $values
        { "value" integer }
}
{ $description "Value for the EMERGENCY log level" } ;

HELP: PMLogLevelError
{ $values
        { "value" integer }
}
{ $description "Value for the ERROR log level" } ;

HELP: PMLogLevelInfo
{ $values
        { "value" integer }
}
{ $description "Value for the INFO log level" } ;

HELP: PMLogLevelNone
{ $values
        { "value" integer }
}
{ $description "Value for no log level" } ;

HELP: PMLogLevelNotice
{ $values
        { "value" integer }
}
{ $description "Value for the NOTICE log level" } ;

HELP: PMLogLevelTest
{ $values
        { "value" integer }
}
{ $description "Value for the testing log level, log level is ignored." } ;

HELP: PMLogLevelWarning
{ $values
        { "value" integer }
}
{ $description "Value for the WARNING log level" } ;

HELP: PMTEST
{ $description "Sends log message regardless of logging level. Use this during testing and remove before releasing code." } ;

HELP: pmLogLevel
{ $var-description "Current logging level" }
{ $see-also
  pmLogLevel
  pmLogStack
  pmLogLevelIndex
  PMLOG_SetVerbose
  PMLOG_PushVerbose
  PMLOG_PopVerbose
}
;

HELP: pmLogLevelIndex
{ $var-description "Holds the current index value into the log level stack" }
{ $see-also
  pmLogLevel
  pmLogStack
  pmLogLevelIndex
  PMLOG_SetVerbose
  PMLOG_PushVerbose
  PMLOG_PopVerbose
}
  ;

HELP: pmLogStack
{ $var-description "Holds an array of log levels." }
{ $see-also
  pmLogLevel
  pmLogStack
  pmLogLevelIndex
  PMLOG_SetVerbose
  PMLOG_PushVerbose
  PMLOG_PopVerbose
}
;

ARTICLE: "pmlog" "PMLOG: A vocabulary for creating syslog entries"
"This vocabulary defines words to create syslog entries. The vocabulary behaves basically as you would expect. If the priority level of the message to send to syslogd is less than the global log level value it will be sent, otherwise discarded." $nl

"Message verbosity increases with the log level being invoked with EMERGENCY being the lowest level and highest priority and DEBUG is the highest level and lowest priority" $nl

"This permits leaving logging words in production code to issue messages of interest. The default log level is ERROR. Messages with priority greater than ERROR will not be sent unless the global level is raised." $nl

"During testing several words exist which will issue message regardless of the global level. It is expected you will remove such words before shipping the code"
$nl

"Global Control"
{ $subsections
  pmLogLevel
  PMLOG_SetVerbose
  PMLOG_PushVerbose
  PMLOG_PopVerbose
}

"Log Levels"
{ $subsections
  PMLogLevelNone      
  PMLogLevelEmerg     
  PMLogLevelAlert     
  PMLogLevelCritical  
  PMLogLevelError     
  PMLogLevelWarning   
  PMLogLevelNotice    
  PMLogLevelInfo      
  PMLogLevelDebug     
  PMLogLevelDebug1    
  PMLogLevelDebug2    
  PMLogLevelTest      
}

"Logging Words"
{ $subsections
  PMLOG_TEST
  PMLOG_EMERG
  PMLOG_ALERT
  PMLOG_CRITICAL
  PMLOG_ERROR
  PMLOG_WARNING
  PMLOG_NOTICE
  PMLOG_INFO
  PMLOG_DEBUG
}

"Test Words"
{ $subsections
  PMLOGWITHLEVEL
  PMLOG_ERR
  PMLOG_VALUE
  PMLOG_NOTE
  PMLOG_HERE
}


{ $vocab-link "pmlog" }
;

ABOUT: "pmlog"
