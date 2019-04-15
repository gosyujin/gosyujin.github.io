---
layout: post
title: "golangでニコ動の動画をパトロールするツール「nicony」を作った"
description: ""
category: 
tags: [Golang]
---

## あらすじ

年末年始にかけてgolangをまたさわってみた。半年以上触ってないと全部忘れてる。

## 作ったもの

![](https://raw.githubusercontent.com/gosyujin/nicony/master/img/logo.png)

- [gosyujin/nicony](https://github.com/gosyujin/nicony)

### デモ

![](https://raw.githubusercontent.com/gosyujin/nicony/master/img/demo.gif)

## できること/やりたいこと

- ニコレポページに上がる動画一覧をチェックして、コメントと動画をパトロールできる
- id指定で単一動画でも同じ事ができる
- マイリストID指定でマイリストの動画を順番にパトロールしたい

## 学んだこと

- コマンドオプションのパース(`flag`パッケージ)
- 標準以外のロガー(`seelog` [cihub/seelog](https://github.com/cihub/seelog))
    - ログレベル分け、ローテートとかできるやつを探してみた
- ファイル操作など(`os`, `path`パッケージ)
- 構造体フィールドタグ([Goのencoding/xmlを使いこなす - Qiita](http://qiita.com/ono_matope/items/70080cc33b75152c5c2a#%E6%A7%8B%E9%80%A0%E4%BD%93%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AB%E3%83%89%E3%82%BF%E3%82%B0))
- goqueryでWebページのスクレイピング([Big Sky :: Go言語で jQuery ライクな操作が出来る goquery を試した。](http://mattn.kaoriya.net/software/lang/go/20120914184828.htm))
- ニコニコAPIの仕様を少し

## あとやりたいこと

- 我流で書きまくってるから、goのお作法を知ったらそっちに寄せる
- テスト作る

とりあえず(30分位で作った)ロゴがあるとテンション上がる。ロゴ駆動開発。
