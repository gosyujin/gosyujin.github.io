---
layout: post
title: "Sphinxワークショップ@関西で事例紹介とハンズオンTAをしてきた #sphinxjp"
description: ""
category: 
tags: [Sphinx, イベント]
---

## あらすじ

さる10/31に開催された [Sphinxワークショップ@関西](https://japanunixsociety.doorkeeper.jp/events/32899) にて事例紹介とハンズオンTAをしてきた。

ので振り返りメモ。PyConJPのkptは活かされたのか。

## スライド

<iframe src="//www.slideshare.net/slideshow/embed_code/key/FH0j2dSC45Yqko" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/kk_Ataka/jus-sphinx-sphinx-54608065" title="JUS関西 Sphinxワークショップ@関西 Sphinx事例紹介" target="_blank">JUS関西 Sphinxワークショップ@関西 Sphinx事例紹介</a> </strong> from <strong><a href="//www.slideshare.net/kk_Ataka" target="_blank">kk_Ataka</a></strong> </div>

<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/hashtag/sphinxjp?src=hash">#sphinxjp</a> ワークショップ@関西で、 <a href="https://twitter.com/kk_Ataka">@kk_Ataka</a> の事例紹介中 <a href="https://t.co/LWPFjZLKyf">pic.twitter.com/LWPFjZLKyf</a></p>&mdash; Takayuki Shimizukawa (@shimizukawa) <a href="https://twitter.com/shimizukawa/status/660324791375671297">2015, 10月 31</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## 振り返りKPT

### Keep

1. 会場には遅刻せず余裕を持って到着できた
1. 質問への対応、割とスムーズだった(と思う/アツい自画自賛)
    - PyConJPの経験が活きたな！
1. Sphinx Tシャツ持っていった

### Problem

1. MacのDisplayPort忘れた
    - 持ち物チェックリストに追加しよう
1. 移動時間をちゃんと見積もるべし
    - 帰り際のドタバタ。危うく帰れなくなる所だった(一応、みんな無事に帰れた)

<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr">やばい新幹線ぎりぎりかも</p>&mdash; ごしゅじん (@kk_Ataka) <a href="https://twitter.com/kk_Ataka/status/660429078990688256">2015, 10月 31</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr">新大阪着いた瞬間セブンセンシズに目覚めないとまずい</p>&mdash; ごしゅじん (@kk_Ataka) <a href="https://twitter.com/kk_Ataka/status/660429780626505729">2015, 10月 31</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/kk_Ataka">@kk_Ataka</a> 新幹線逃した！</p>&mdash; Takayuki Shimizukawa (@shimizukawa) <a href="https://twitter.com/shimizukawa/status/660435286854209536">2015, 10月 31</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

### Try

- 歴史的経緯も気にしてみよう
    - 質問であったのが、「Sphinxのhtmlテーマのデフォルトはなんで `default` じゃないの？( `alabaster` なの？)」というもの
        - Sphinx 1.3からデフォルトテーマは `alabaster` になった
        - あわせてデフォルトテーマ `default` は `classic` に名称変更されたが、互換性維持のために残っている
        - Sphinx 1.3でテーマを `default` に設定して `make html` すると `alabaster` 使いなよと警告が出る
        - [Sphinxの更新履歴 — Sphinx 1.3.2 ドキュメント](http://docs.sphinx-users.jp/changes.html)によると1.3b3でそうなった様子

```
$ make html
(略)
WARNING: 'default' html theme has been renamed to 'classic'. Please change your html_theme setting either to the new 'alabaster' default theme, or to 'classic' to keep using the old default.
(略)
```

## その他の感想

- 今回のワークショップ参加者の方は「Officeつらくてなんとか改善したい」派が多かった印象
- 「ポーギーに話す」の正式名称および出典がわかった

<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr">「自分の考えてる事を熊ちゃんに話して整理する」って手法、ググり方がわからなくて正式名称にたどり着けなかったんだけど今日清水川さんに正式名称教えてもらえた <a href="https://twitter.com/hashtag/sphinxjp?src=hash">#sphinxjp</a> - ポーギーに話す <a href="https://t.co/Y6I8yvo9NQ">https://t.co/Y6I8yvo9NQ</a></p>&mdash; ごしゅじん (@kk_Ataka) <a href="https://twitter.com/kk_Ataka/status/660419061218545664">2015, 10月 31</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

> その中にMITでは学生が教官を患わせる前に一度テディベアに説明しなければならないという話が載っている。

大学も熊もあってた。ただ、熊は熊でもテディベアだった。

ちなみに、今までググってたキーワード群を「熊」->「テディベア」に変えると(「大学 熊 話す」を「大学 テディベア 話す」)、上記のサイトが1ページ目に上がってきたのでもう半歩足りなかったみたい。

ググるにも発想力とアドリブが求められる。ハマると全然引っかからない
