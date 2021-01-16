#!/bin/sh

paudiourl=$(cat /tmp/tmp.XM.url)
paudioname=$(cat /tmp/tmp.XM.name)
paudionum=99
rpaudionum=99
paudiopath=$(cat /tmp/tmp.XM.path)
tmpcounthead=1

urlprefix="https://www.ximalaya.com/revision/play/v1/audio?id="
urlsuffix="&ptype=1"

if [ ! -d "/autodl" ]; then
	mkdir /autodl
	chmod 777 /autodl
	if [ ! -d "/autodl/$paudiopath" ];then
		ln -s $paudiopath /autodl
	fi
elif [ ! -d "/autodl/$paudiopath" ];then
		ln -s $paudiopath /autodl
fi

cd /$paudiopath

curl -s --retry 3 --retry-delay 2 --connect-timeout 10 -m 20 -H ""user-agent": "Mozilla/5.0"" $paudiourl > /tmp/tmpXM.xmlyhttp
sleep 2
xmlyhttp=$(cat /tmp/tmpXM.xmlyhttp)  

for i in `echo "$xmlyhttp" | sed 's/</\n/g'`
do  
    echo $i >> /tmp/tmpXM.xmlyhttp1
done

cat /tmp/tmpXM.xmlyhttp1 | grep isPaid > /tmp/tmpXM.xmlyhttp2

xmlyhttp2=$(cat /tmp/tmpXM.xmlyhttp2)
for i in `echo "$xmlyhttp2" | sed 's/{\"index\":/\n/g'`
do  
    echo $i >> /tmp/tmpXM.xmlyhttp3
done

cat /tmp/tmpXM.xmlyhttp3 | grep trackId > /tmp/tmpXM.xmlyhttp4
cat /tmp/tmpXM.xmlyhttp4 | grep '^[0-9]' | cut -d ',' -f 2 | cut -d ':' -f 2 > /tmp/tmpXM.xmlyhttp5
cat /tmp/tmpXM.xmlyhttp5 > /tmp/tmpXM.xmlyhttp5d

cat /tmp/tmpXM.xmlyhttp5d | while read LINE
do
	xmlytrackId=$(echo $LINE)
	adurlprefix=$urlprefix
	adurlsuffix=$urlsuffix
	tmpgetaudiourl="${adurlprefix}${xmlytrackId}${adurlsuffix}"
	curl -s --retry 3 --retry-delay 2 --connect-timeout 10 -m 20 -v $tmpgetaudiourl > /tmp/tmpXM.xmlyhttp6
	sleep 1
	tmpaudio=$(cat /tmp/tmpXM.xmlyhttp6)
	echo ${tmpaudio#*src\":\"} > /tmp/tmpXM.xmlyhttp7
	tmpaudio=$(cat /tmp/tmpXM.xmlyhttp7)
	echo ${tmpaudio%\",\"albumIsSample*} > /tmp/tmpXM.xmlyhttp7
	audiofile=$(cat /tmp/tmpXM.xmlyhttp7)
	wget-ssl -q -c $audiofile -O $paudionum.m4a
	sleep 3
	paudionum=$(echo `expr $paudionum - 1`)
done

cat /tmp/tmpXM.xmlyhttp3 | grep trackId > /tmp/tmpXM.xmlyhttp0num
cat /tmp/tmpXM.xmlyhttp0num | grep '^[0-9]' | cut -d ',' -f 1 > /tmp/tmpXM.xmlyhttp1num
sed '1!G;h;$!d' /tmp/tmpXM.xmlyhttp1num > /tmp/tmpXM.xmlyhttp2num

ls -al | grep "^-" > /tmp/tmpXM.filelist

cat /tmp/tmpXM.filelist | while read LINE
do
	xmlyfilename=$(echo $LINE)
	xtmpcounthead=$tmpcounthead
	xmlyturenum=$(tail -n $xtmpcounthead /tmp/tmpXM.xmlyhttp2num | head -n 1)
	if [ $xmlyturenum -le 9 ];then
		nxmlyturenum=000$xmlyturenum
		mv -f /$paudiopath/$rpaudionum.m4a /$paudiopath/$paudioname$nxmlyturenum.m4a
		tmpcounthead=$(echo `expr $tmpcounthead + 1`)
		rpaudionum=$(echo `expr $rpaudionum - 1`)
	elif [ $xmlyturenum -le 99 ];then
		nnxmlyturenum=00$xmlyturenum
		mv -f /$paudiopath/$rpaudionum.m4a /$paudiopath/$paudioname$nnxmlyturenum.m4a
		tmpcounthead=$(echo `expr $tmpcounthead + 1`)
		rpaudionum=$(echo `expr $rpaudionum - 1`)
	elif [ $xmlyturenum -le 999 ];then
		nnnxmlyturenum=0$xmlyturenum
		mv -f /$paudiopath/$rpaudionum.m4a /$paudiopath/$paudioname$nnnxmlyturenum.m4a
		tmpcounthead=$(echo `expr $tmpcounthead + 1`)
		rpaudionum=$(echo `expr $rpaudionum - 1`)
	else
		mv -f /$paudiopath/$rpaudionum.m4a /$paudiopath/$paudioname$xmlyturenum.m4a
		tmpcounthead=$(echo `expr $tmpcounthead + 1`)
		rpaudionum=$(echo `expr $rpaudionum - 1`)
	fi
done

if [ ! -d "/$paudiopath/$paudioname" ]; then
mkdir $paudioname
fi

mv -f *.m4a $paudioname

rm /tmp/tmpXM.*

