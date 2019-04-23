---
layout: post
title: "golangでサーバのファイルをゆっくりダウンロードするツール作ってみた"
description: ""
category: 
tags: [Golang]
old_url: http://d.hatena.ne.jp/kk_Ataka/20150430/1430390069
---

## あらすじ

golangやるやる詐欺してたので、ようやくさわってみた。

## 参考サイト

- [golang.jp - プログラミング言語Goの情報サイト](http://golang.jp/)

を中心に、いろいろググりつつ。

## バージョン

- go version go1.4.2 

## やりたいこと

- サーバに負荷がかからないようにちょっとずつ落とせる
- ネットワークに負荷がかからないようにゆっくり落とせる
- 落とし切る前に終了→再実行したら途中から落とせる

## 作ったもの

[gosyujin/yukkuri-downloader](https://github.com/gosyujin/yukkuri-downloader)

- byte-rangeリクエストを投げて(初めて知った)ちょっとずつ落とせる
    - StatusPartialContentでレスポンスくれないサーバでは一気に落としてしまう
- インターバルを指定できてゆっくり落とせる
- レジュームできる

他、

- 設定ファイル(jxon)から設定を読み込める
- コマンドライン引数から設定を読み込める(設定ファイルより強い)
- proxyは環境変数HTTP_PROXYとHTTPS_PROXYを読み込める(使わない事もできる)
- WindowsとCentOSで動かせる

ビルドして実行すると

```go
$ ./yukkuri-downloader -h
[go-tran] 2015/04/30 19:17:47 Initialize.
[go-tran] 2015/04/30 19:17:47 Read setting file: /home/kk_Ataka/go-tran.json
Usage of ./yukkuri-downloader:
  -i=0: download interval(sec)
  -no-proxy=false: NOT use proxy
  -proxy=false: use proxy
  -r=0: getRange(byte)
  -u="": download file
$ ./yukkuri-downloader -i 1 -r 1048
[go-tran] 2015/04/30 19:18:03 Initialize.
[go-tran] 2015/04/30 19:18:03 Read setting file: /home/kk_Ataka/go-tran.json
[go-tran] 2015/04/30 19:18:03   Override getRange by ARGS
[go-tran] 2015/04/30 19:18:03   Override interval by ARGS
[go-tran] 2015/04/30 19:18:03 CLEAR system proxy HTTP_PROXY and HTTPS_PROXY
[go-tran] 2015/04/30 19:18:03   HTTP_PROXY   :
[go-tran] 2015/04/30 19:18:03   HTTPS_PROXY  :
[go-tran] 2015/04/30 19:18:03   Url          :http://ftp.kddilabs.jp:80/infosystems/apache/httpd/httpd-2.4.12.tar.gz
[go-tran] 2015/04/30 19:18:03   Scheme       :http
[go-tran] 2015/04/30 19:18:03   Host         :ftp.kddilabs.jp
[go-tran] 2015/04/30 19:18:03   Port         :80
[go-tran] 2015/04/30 19:18:03   Path         :/infosystems/apache/httpd/
[go-tran] 2015/04/30 19:18:03   File         :httpd-2.4.12.tar.gz
[go-tran] 2015/04/30 19:18:03   GetRange     :1048 byte
[go-tran] 2015/04/30 19:18:03   Interval     :1 sec
[go-tran] 2015/04/30 19:18:03 Read setting file end.
9.03 KB / 6.54 MB [>---------------------------------------] 0.13 % 11.86 MB/s
$ ./yukkuri-downloader -i 10 -r 1048000
[go-tran] 2015/04/30 19:18:11 Initialize.
[go-tran] 2015/04/30 19:18:11 Read setting file: /home/kk_Ataka/go-tran.json
[go-tran] 2015/04/30 19:18:11   Override getRange by ARGS
[go-tran] 2015/04/30 19:18:11   Override interval by ARGS
[go-tran] 2015/04/30 19:18:11 CLEAR system proxy HTTP_PROXY and HTTPS_PROXY
[go-tran] 2015/04/30 19:18:11   HTTP_PROXY   :
[go-tran] 2015/04/30 19:18:11   HTTPS_PROXY  :
[go-tran] 2015/04/30 19:18:11   Url          :http://ftp.kddilabs.jp:80/infosystems/apache/httpd/httpd-2.4.12.tar.gz
[go-tran] 2015/04/30 19:18:11   Scheme       :http
[go-tran] 2015/04/30 19:18:11   Host         :ftp.kddilabs.jp
[go-tran] 2015/04/30 19:18:11   Port         :80
[go-tran] 2015/04/30 19:18:11   Path         :/infosystems/apache/httpd/
[go-tran] 2015/04/30 19:18:11   File         :httpd-2.4.12.tar.gz
[go-tran] 2015/04/30 19:18:11   GetRange     :1048000 byte
[go-tran] 2015/04/30 19:18:11   Interval     :10 sec
[go-tran] 2015/04/30 19:18:11 Read setting file end.
2.01 MB / 6.54 MB [===========>---------------------------] 30.72 % 12.27 MB/s 
```

こんな感じ。

まだ文法とかお作法とかは全然わかってない。

テストライブラリも標準で付いているようなので、そっちも調べてみたい。
