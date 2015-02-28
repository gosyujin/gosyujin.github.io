---
layout: post
title: "rubyXLを使ってExcelを操作したい"
description: ""
category: 
tags: [Ruby]
---
{% include JB/setup %}

## あらすじ

ExcelファイルをRubyで操作したい。

以前WIN32OLEから直接触ってみたけど、ライブラリを使って簡単に触ってみたい。

## 環境

- Windows 7
- Ruby 2.1.5
    - rubyXL 3.3.4
- Microsoft Office 2010

## 参考

- [Ruby - RailsでExcelを扱うGemまとめ - Qiita](http://qiita.com/Kta-M/items/02a2c41c5624f75498aa)
- [RubyでExcelファイルを扱うライブラリの比較 - Qiita](http://qiita.com/damassima/items/1b791ba90459ef0534fe)
- [[Ruby]RubyでExcelをつかう[Rails] - Qiita](http://qiita.com/satoken0417/items/bf302cc47e9bd69aaa73)
- [RubyからExcelを操作する方法について ｜ Futurismo](http://futurismo.biz/archives/2330) ※WIN32OLE使用

意外とある。

が、開きたいファイル、保存したいファイルが何なのか(xlsなのかxlsxなのか)によって使うライブラリを選定する必要あり。

xlsx読めない！とかxlsで書きこめない！とかある。

## やりたいこと

1. 共有サーバの中にあるExcelファイルを開く
1. 特定のセル(B3みたいな)に値が入っているか確認する
    - 入っていれば次の処理へ
    - 入っていなければn個下のセル(B6みたいな)に値が入っているか確認する…の繰り返し
1. 空いているセルに値を挿入
1. 保存して終わり

よくありがちな「定期的に台帳の一番下に定型文を挿入したい」系の話。

## ソース

Gistにあげた。

<script src="https://gist.github.com/gosyujin/57a40e47ca0bc57673a2.js"></script>

今回はrubyXLというライブラリを使ってみた。

わりと簡単に書けて、やりたいこと(開く、値読む、値書く、保存する)がすぐできたのでこれで。

これで便利。(^ー^)
