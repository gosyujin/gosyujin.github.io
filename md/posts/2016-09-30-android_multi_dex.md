---
layout: post
title: "Androidのapkの総メソッド数を調べてMulti-dexを導入するか否かを判断する"
description: ""
category: 
tags: [Android]
---

## あらすじ

- Androidではapkのメソッド総数が65536を超える場合、ビルド/インストール時にエラーが発生する
  - Multi-dexを導入して対応しなければならないらしい
- しかし、メソッド総数はどう判断すればよい？

## 参考

- [mihaip/dex-method-counts: Command-line tool to count per-package methods in Android .dex files](https://github.com/mihaip/dex-method-counts)
- [Multi-dex Support を使おう - Qiita](http://qiita.com/KeithYokoma/items/385a94988beb2d7d8043)
- [Androidでメソッド数が65536を超えた時の対処方法 - Qiita](http://qiita.com/konifar/items/d98c78facbaae63badca)
- [[Android] アプリのメソッド数を知るには ｜ Ys' Library ｜ プログラミング・ガジェット徒然日記](http://yslibr4ry.blogspot.jp/2014/11/android-dex-method-counts.html)


## 手順

- dex-method-countsを使用する

```sh
git clone https://github.com/mihaip/dex-method-counts.git
cd dex-method-counts/
./gradlew assemble
./dex-method-counts hogehoge-debug.apk 
```

```
Processing hogehoge-debug.apk
Read in x method IDs.
Read in xxx method IDs.
<root>: xxx
    android: x
        app: x
        content: x
            res: x
        net: x
        os: x
        util: x
        widget: x
    com: x
        android: x
            tools: x
                fd: x
                    common: x
                    runtime: x
    dalvik: x
        system: x
    java: xxx
        io: x
        lang: x
            ref: x
            reflect: x
        math: x
        security: x
        util: x
            logging: x
            zip: x
Overall method count: xxx
```
