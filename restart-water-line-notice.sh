#!/bin/bash

now() {
	date -d "+10 hours" +"[%Y-%m-%d %H:%M:%S]"
}
readtime() {
	date -d "+10 hours" +"%a %b %d %H:%M:%S %Y"
}
mth() {
	date +"%Y%m"
}

CMD=/opt/waterlinedata/bin/waterline
LOG='/tmp/daily-waterline'-$(mth).log
STARTLOG='/tmp/start-waterline'-$(mth).log
ERRLOG='/tmp/error-waterline'-$(mth).log
service=waterline

echo -ne $(now)"\r" >> $LOG
$CMD serviceStop >> $LOG

echo $(now) >> $STARTLOG
$CMD serviceStart >> $STARTLOG 2>> $ERRLOG

if (( $(ps -ef | grep -v grep | grep -v "su $service" | grep $service | wc -l) > 2 ))
then
	CONTENT="$service service restarted successfully."
else
	CONTENT="$service service cannot restart! Please check the log for more information: $STARTLOG"
fi

echo "$(now) $CONTENT" >> $LOG

/usr/sbin/sendmail -t <<MSGMAIL
To: dacsupport@treasury.nsw.gov.au
From: waterline service <root@$HOSTNAME>
Subject: noreply: waterline service daily restart at $(readtime)
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8

$CONTENT

This mail is generated by $HOSTNAME, please don't reply.
MSGMAIL


