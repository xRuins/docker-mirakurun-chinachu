var fs = require('fs');
var child_process = require('child_process').execSync;


//ログファイルに録画した番組情報を出力
console.error("-----------------番組情報-------------------\n");
console.error(process.argv[3] + '\n');
console.error("--------------------------------------------\n");

//引数チェック
//if (process.argv.length <4) return;

//エンコ済みファイル倉庫（最後に"/"必須(※)
var encodedDir = "/usr/local/chinachu/recorded/";

//録画した番組のオブジェクトを得る
var finishedObj = JSON.parse(process.argv[3]);

//録画履歴のオブジェクトを得る
var recordedObj = JSON.parse(process.argv[2]);

//過去の録画情報と今回の録画情報を比較する
for(var i in recordedObj) {

	//タイトルと詳細が一致した場合
	if (recordedObj.title == finishedObj.title &&
		recordedObj.detail == finishedObj.detail){

		//何もせず終了
		console.error("this movie is already encoded.\nNothing to do.");

		//元ファイルを削除して終了
//		fs.unlinkSync(finishedObj.recorded);
//		console.error("this movie is already encoded.\nDelete source file.");

		return;
	}
}

//------------------------
//エンコる
//------------------------
var recOpt = "-vcodec libx265 -b:v 16384k";

//var ffmpeg = __dirname + "/usr/bin/ffmpeg";				//←通常の優先度でエンコする
var ffmpeg = "nice -n 15 " + __dirname + "/usr/local/chinachu/usr/bin/ffmpeg"; //←システム全体の負荷を考慮し、エンコの優先度を落とす

//ffmpegの入力ファイルオプション
var optIn = ' -i ' + '"' + finishedObj.recorded + '"';

//出力ファイルの拡張子(先頭に"."必須)
var outExt = ".mp4";

//"/mnt/HDD2/ts/[151111-1355][GR25][PT2-T1]情報ライブ　ミヤネ屋.ts",
// ↓ こんなんにする
//”[151111-1355][GR25][PT2-T1]情報ライブ　ミヤネ屋"
var slashPos = finishedObj.recorded.lastIndexOf("/");
var tmpOutFile = finishedObj.recorded.slice(slashPos+1,finishedObj.recorded.length - 3);

//”[151111-1355][GR25][PT2-T1]情報ライブ　ミヤネ屋"
// ↓ こんなんにする
//”エンコ済みファイル倉庫パス/[151111-1355][GR25][PT2-T1]情報ライブ　ミヤネ屋.mp4"
var outFile = " " + '"' + encodedDir + tmpOutFile + outExt + '"';

//コーデック指定オプション(先頭に" "(空白)必須)
var codecOpt = " -vcodec libx264";

//エンコ実行文字列
var execString = ffmpeg + optIn + codecOpt + recOpt + outFile;

console.error("------------ffmpeg execute string-----------\n");
console.error(execString + '\n');
console.error("--------------------------------------------\n");

//ffmpeg起動
child_process(execString, function(err, stdout, stderr){

	//子プロセスでエラー時に記録
	var logText = "Error:" + err + "\n" + "stdout:" + stdout + "\n" + "stderr:" + stderr + "\n";
	console.error("--------------ffmpeg error------------------\n");
    console.error(logText + '\n');
	console.error("--------------------------------------------\n");
});
