---
layout: post
title: "jekyllrb-ja キックオフを実施しました"
description: ""
category: 
tags: [Jekyll, Translate]
---
{% include JB/setup %}

## あらすじ

Jekyllドキュメントの初版翻訳が終わりまして。

初版はえいや！でやれば進むもので、大変なのはそれを継続させていく事。

今後の進め方とかどこかで一回詰めたいな〜と思っていたら@yandodさんに集まる場所を提供していただきました！(![Engine Yard Blog](http://www.engineyard.co.jp/blog/)がJekyllなのだ)

Engine Yardさんありがとうございます！

詳細は以下。

### 日時

- 7/18 19:30-21:00

### 場所

- 株式会社 Engine Yard

### 参加者(名前順)

- @chezou
- @gosyujin
- @harupong
- @melborne
- @tmkoikee
- @yandod

自己紹介をしたら業務でJekyllを使いこんでいる人、ガチで翻訳している人などなど経歴がハンパなかった…。

### やったこと

- v2.0の進め方
  - ブランチ戦略
  - 本家への追従の仕方
  - 翻訳ワークフロー

## v2.0の進め方

### ブランチ戦略

- ドキュメントなので特に分ける必要はないのではないか
  - progitでもテストがこけなければメンテナが即マージ、表示崩れなどを発見したら適宜直す方針
- とりあえずmasterブランチ一本で
- masterブランチに対してhttps://teatro.io/ 使ってみよう
  - masterで適用してみてダメそうだったらdevelopブランチきってみよう
- writerの権限わける
- プルリクをマージする基準を決めたい
  - LGTMされてx時間たって何もなかったらマージするなど
  - このあたりの操作は最終的にはbot(hubot)に任せたい

### 本家への追従の仕方

- Engine Yardではオリジナルをpullしてきてmergeしている
- @melborne さんのgh-diffのデモが大好評
   - 差分からIssueをたてる機能もあり、cron等で定期的に実行すれば「Issue=翻訳残」とわかりやすい
     - rakeタスク化して誰でも実行できるようにしたい
- gh-diffを使用した運用フロー案
   1. Contributerの誰かがdiffをとって `.diff` を保存し、 Issue化
   2. Issueを見て対象ファイルを翻訳
   3. PR
   4. OKならマージ
   5. `.diff` を消す
        - `.diff` を消すタイミングもrakeで自動化したい

### 翻訳ワークフロー

- gh-diffのおかげで、「Issue見て翻訳対象探す、やるよって言う、トピックブランチきる、.diffファイル見ながら翻訳する、PRする」と簡略された
- 新規の人向けにCONTRIBUTING.md作る

### おまけ 用語集(Glossary)の話

- Wikiではなく、csv化してリポジトリで持とうか
- そうする事でチェックもできるかも
   - Chef本では禁則事項チェックをシェルでやってる https://gist.github.com/yandod/adcd176012df92694bf9
