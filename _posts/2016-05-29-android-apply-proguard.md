---
layout: post
title: "ProGuardでAndroidアプリを難読化していく手順(暫定)"
description: ""
category: 
tags: [Android]
---

## あらすじ

- Androidアプリの難読化作業を最後にまとめて実施しようとしたら思いがけずハマった
- しかし「こうすれば全部OK」という定石はなく、ライブラリの情報を読み、実際にアプリを実行していくしか方法がなさそう？
- ベストプラクティスなどあれば教えて下さい…

## 参考

- [ProGuard設定まとめ - Qiita](http://qiita.com/tsuyosh/items/9dd3c6b9dc11b5f640be)
- [Proguardメモ - Qiita](http://qiita.com/teracy/items/f42448a186ee2319a3c1#rxjava)
- [ProGuardのメモ - Qiita](http://qiita.com/niusounds/items/d58a0c1e99c9db0260f8)
- [android - AndroidStudio disable "Expected resource of type string" - Stack Overflow](http://stackoverflow.com/questions/35009832/androidstudio-disable-expected-resource-of-type-string)

## 手順

最後に一気にやろうとすると、とにかくまずビルドが通らない。

まっさらなプロジェクトを用意して一つずつライブラリを入れてくのが良さそう。

### BUILD SUCCESSFULになるまで

- まっさらなプロジェクト(以下、確認用プロジェクト)を作る
  - その状態でProGuardを適用するように設定変更する
  - リリースビルド( `gradlew assembleRelease` など)が成功する事を確認する
- 本プロジェクトで使用しているライブラリ( `build.gradle` に定義されているものなど)を確認用プロジェクトに追加していく
  - 一つ追加してはビルドが失敗しない事を確認する
  - 失敗した場合はエラーメッセージを確認する
  - 恐らく追加したライブラリに関連するエラーが出ているはずなので、該当ライブラリREADME/GitHub IssueにProGuardに関する記載があるか確認する
  - 記載があった場合、ProGuard設定を追加し再度ビルドする
  - …以上の手順を全ライブラリに対して行う
- 並行して、ビルド成功した場合は本プロジェクトにProGuard設定を転記していっても良いかも

### BUILD SUCCESSFULになったあと

難読化の影響で **処理呼び出し時にコケる** 、というパターンもある。これは実際にapkを叩いてみるまでわからない模様。

- PCとAndroid端末をUSBで接続する
- リリース用apkをインストールする( `adb install` など)
- `adb logcat` でログを確認できるようにしておく
- 実機でコケる操作を行う
- logcatからエラーを確認する
  - コケているライブラリのREADME/GitHub IssueにProGuardに関する記載があるか確認する

…という感じの繰り返しで確認していく。

### ライブラリ追加時

ライブラリを新たに追加する場合は毎回

- BUILD FAILEDにならない事を確認する
- 実機確認で追加ライブラリを使用している処理を実行する

しかない？
