#!/bin/bash

# *** So, backstory:
#	There are a few (underpublicized) databases maintained by Mac OS X which may inadvertently reveal information and habits  about you, the user. 
#	If you want to make your system less able to reveal this information and habits, one approach would be to purge these databases semi-regularly.
#	To that end, you may want to use this script and install it as a cron job. 
#	No warranties or promises; use at your own risk. 
#	
#	The end.

# *** Purge quarantined files list; stores a record of (likely nearly) every file you've ever downloaded to your Mac. Yes. Really.
# 	For more, see: http://www.zoharbabin.com/hey-mac-i-dont-appreciate-you-spying-on-me-hidden-downloads-log-in-os-x/
# 
/usr/bin/sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'
/usr/bin/sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'vacuum'

# *** Same thing for notifications, as they also store information generated by applications which, in some cases, aren't even still running. 
#	But, I like iCal notifictions, so I make an exception for them. 
# 	1. find GUID-named database
dbPath=`find ~/Library/Application\ Support/NotificationCenter -name *.db -print -quit` 

# 	2. Figure out which id iCal has
iCal=`/usr/bin/sqlite3 "$dbPath" 'select app_id from app_info where bundleid = "com.apple.iCal"'`

#`/usr/bin/sqlite3 "$dbPath" 'delete from notifications where app_id <> "$iCal"'`
# ^^^ not sure why, but this variant never worked right, and always deleted everything from the notifications table, whereas the below worked perfectly.
eval "/usr/bin/sqlite3 \""$dbPath"\" 'delete from notifications where app_id <> "  $iCal  "'"

# 	3. Now make UI for notifications refresh itself
killall usernoted; killall NotificationCenter
