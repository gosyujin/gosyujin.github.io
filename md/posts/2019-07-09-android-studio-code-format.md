---
layout: post
title: "Android Studioのコードフォーマットをプロジェクトで統一する"
description: ""
category: 
tags: [Android]
---

## あらすじ

- プロジェクト内のAndroid Studioコードフォーマットがあっていないとコミットに余計な変更が入る
- 設定を一つずつ見ていって合わせても良いが、設定ファイルなどを共有することで解決できないだろうか

今回は以下の2点だけ統一したかった。が、他にも色々統一できる。

1. コードスタイル
    - メソッドのかっこの位置とか、スペースとか
2. 新規作成で生成されるクラスのテンプレート
    - コメントとか消したい

## 環境

- Android Studio 2.1 Preview 4

## 解決策

### 設定方法

設定的にはPreferenceから以下の部分を変更してやれば良い。

1. コードスタイル
    - `Preferences -> Editor -> Code Style -> それぞれの言語`
2. 新規作成で生成されるクラスのテンプレート
    - `Preferences -> Editor -> File and Code Templates -> Files, Includes, Code, Otherのそれぞれのファイル`

### 共有方法

これをプロジェクトで共有するには以下の2点を行う必要がある

1. Schemaを `Project` に
2. `.idea` ディレクトリ下の設定ファイルをバージョン管理できるように(直接授受してもいいけど)

> 複数人でプロジェクトを共有する場合，自分以外の人に自分が設定したコードスタイルを渡すことができません。
> 
> そこで登場するのがデフォルトで登録済みの「Project」コードスタイルです。このコードスタイルのみ，設定情報が「<PROJECT_HOME>\.idea\codeStyleSettings.xml」に保存されます。このファイルをバージョン管理システムに登録して共有することでコードスタイルも共有されます

という事なので、コードスタイルは `.idea/codeStyleSettings.xml` をバージョン管理し、各メンバーがCode StyleのSchemaを `Project` にすればスタイル共有できる。

テンプレートは、変更した時点で `.idea/fileTemplates/<変更したFile, Includeなど>/<ファイル>` が生成されるのでこれをバージョン管理し、各メンバーがFile and Code TemplatesのSchemaを `Project` にすれば共有できる。

## 参考

- [第33回　バージョン管理 ─プロジェクト管理ファイルについて［前編］：Android Studio最速入門～効率的にコーディングするための使い方｜gihyo.jp … 技術評論社](http://gihyo.jp/dev/serial/01/android_studio/0033)
- [第34回　バージョン管理 ─プロジェクト管理ファイルについて［中編］：Android Studio最速入門～効率的にコーディングするための使い方｜gihyo.jp … 技術評論社](http://gihyo.jp/dev/serial/01/android_studio/0034)
- [第35回　バージョン管理 ─プロジェクト管理ファイルについて［後編］：Android Studio最速入門～効率的にコーディングするための使い方｜gihyo.jp … 技術評論社](http://gihyo.jp/dev/serial/01/android_studio/0035)
- [第41回　コードフォーマット：Android Studio最速入門～効率的にコーディングするための使い方｜gihyo.jp … 技術評論社](http://gihyo.jp/dev/serial/01/android_studio/0041)

