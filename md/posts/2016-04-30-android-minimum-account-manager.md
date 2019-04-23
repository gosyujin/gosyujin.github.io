---
layout: post
title: "AndroidのAccountManagerをとりあえず動かすところまで"
description: ""
category: 
tags: [Android]
old_url: http://d.hatena.ne.jp/kk_Ataka/20160430/1462026944
---

## あらすじ

- Androidでアカウントに関連する情報をアプリ内に持ちたくない
    - Android側でAccountManagerという仕組みを用意してくれている
- しかし、説明を読んでもイマイチピンとこなかった
- 実際に動きを確認できるところまでサンプル作ってみた

## 参考

- Android Security 安全なアプリケーションを作成するために 11.2章
- [Android におけるアカウント管理 – Gunosy Tech Blog](http://gunosy.github.io/2014/05/30/android-accounts.html)
- [AccountManagerを利用する - Qiita](http://qiita.com/nein37/items/25ba6e5176118fae5f13)
- [AccountManagerでアカウントを管理する - Qiita](http://qiita.com/nein37/items/9aef7e4e06e71990c6e1)

## AccountManagerの概念

![](https://cloud.githubusercontent.com/assets/588166/14935816/34843e48-0f1a-11e6-9446-d2e7a9ce8f62.png)

AndroidSecurity安全なアプリケーションを作成するために P267より抜粋

## 環境

- Android Studio 1.5.1
- Minimum SDK API 19: Android 4.4(KitKat)
- Emulator Nexus 5 API 19 Android 4.4.4, API 19

## 動くもの

- こんな感じで動く
  - ソース: [MinimumAccountManagerSample](https://github.com/gosyujin/MinimumAccountManagerSample)

![](https://raw.githubusercontent.com/gosyujin/MinimumAccountManagerSample/master/demo.gif)

## ハマり

`AccountManager` `Authenticator` ともにサンプル通り作ってみようと思ったらエラーの切り分けができなかった

- Android的に×なのか
- AccountManager的に×なのか
- 使おうとしたGoogle APIのお作法的に×なのか(多分これが一番有力)
  - Android Security(2012/2/21 第二版)のサンプルが古めのGoogle APIを使っていたため、これを最新に置き換えて〜という作業も発生していた

空の `Authenticator` を作って、とりあえず登録できる口だけ用意する事で一気通貫通す事ができた！
