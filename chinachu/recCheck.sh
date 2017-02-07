#!/bin/sh

# author katsuwo.
#sonic-laboの屋号でフリーランスプログラマーしてます。お仕事お待ちしてます。
#http://sonic-labo.com/


#recorded objectを得る IPは各自の環境に合わせて変更の事
query=`curl -s http://chinachu:10772/api/recorded.json`

#logFile
time=`date +%s`
logExt=".log"

#下記の例は/mnt/HDD2/log以下にログファイルを作成。保存ディレクトリに書き込み許可を忘れずに(※)

#node実行  nodeの実行パスは各自の環境に合わせて変更の事。chinachuの実行パス以下の.naveに在ります(※)
/home/chinachu/chinachu/.nave/node recCheck.js "${query}" "${2}" 2>&1 \
/usr/local/bin/slack_notification.sh -c dtv -i tv -n Surtr
