---
layout: post
title: "Android StudioでAndroid Lint"
description: ""
category: 
tags: [Android]
old_url: http://d.hatena.ne.jp/kk_Ataka/20170531/1497081501
---

## あらすじ

Android Lintを使ってみる。

## 参考

- [Android Lint - Android Studio Project Site](http://tools.android.com/tips/lint)
- [Android Lint Checks - Android Studio Project Site](http://tools.android.com/tips/lint-checks)
- [Android Tips #11 ADT revision 17のLintの機能追加について ｜ Developers.IO](http://dev.classmethod.jp/smartphone/android-tips-11-lint-r17/)

## Android Lintって

- ADT 16から導入されたツール
- ソースに潜在するバグをチェックしてくれる
    - Missing translations (and unused translations)
    - Layout performance problems (all the issues the old layoutopt tool used to find, and more)
    - Unused resources
    - Inconsistent array sizes (when arrays are defined in multiple configurations)
    - Accessibility and internationalization problems (hardcoded strings, missing contentDescription, etc)
    - Icon problems (like missing densities, duplicate icons, wrong sizes, etc)
    - Usability problems (like not specifying an input type on a text field)
    - Manifest errors

## 使用例

コマンドラインから使う事ができる。

```
$ /Users/USER/Library/Android/sdk/tools/lint --version
lint: version 24.4.1
```

Android Studioから使いたい。

`Analyze` -> `Inspect Code` で実行できる。

```
Running Android Lint...
```
