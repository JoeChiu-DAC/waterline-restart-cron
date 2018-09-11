#!/bin/bash

now() {
	date +"[%Y-%m-%d %H:%M:%S]"
}

CMD=/opt/waterlinedata/bin/waterline
LOG='/tmp/daily-waterline'-`date +"%Y%m%d"`.log
STARTLOG='/tmp/start-waterline'-`date +"%Y%m%d"`.log
service=waterline

echo -ne $(now)"\r" >> $LOG
$CMD serviceStop >> $LOG
echo $(now) >> $STARTLOG
$CMD serviceStart >> $STARTLOG

if (( $(ps -ef | grep -v grep | grep -v "su $service" | grep $service | wc -l) > 2 ))
then
	CONTENT="$(now) $service is restarted!"
else
	CONTENT="$(now) $service cannot be restarted! check the log file: $STARTLOG"
fi

echo $CONTENT >> $LOG

/usr/sbin/sendmail -t <<MSGMAIL
To: dacsupport@treasury.nsw.gov.au
From: waterline service <root@$HOSTNAME>
Subject: noreply: waterline service daily restart
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8

$CONTENT

Time Diff:
System: 06:00:00	12:00:00	20:00:00
Sydney: 16:00:00	22:00:00	06:00:00
MSGMAIL


