---
layout: post
title: "軽量マークアップ言語の歴史をゆるく調べた #sphinxjp"
description: ""
category:
tags: [Markdown, reST, Wiki]
old_url: http://d.hatena.ne.jp/kk_Ataka/20150713/1436751705
---

## はじめに

reSTの成り立ちが気になったので、[Sphinx+翻訳 Hack-a-thon 2015.07 - connpass](http://sphinxjp.connpass.com/event/17072/)を利用して調べてみた。

reST以外にも軽量マークアップ言語MarkdownとWikiもいくつかピックアップ。

- reStructuredText
    - structuredText(reSTの系譜を辿って見つけた)
    - setext(reSTの系譜を辿って見つけた)
- Markdown
    - CommonMark(Markdownの現状を辿って見つけた)
- Wiki
    - YukiWiki(代表的っぽい、かつデッドリンクじゃなかった和製Wiki)
    - MediaWiki(Wikipediaで使われている)
- はてな記法(国産)

このあたり。

## 調べた人

MarkdownとreStructuredTextとWikiの一利用者。

なので、込み入った話(時代背景とかその当時のMLとか)は全然知らない。

## まとめ

### 年表

それぞれができた年。

年  |月 |出来事(md, rst, wiki)     |それ以外の出来事   |html的な出来事
----|---|--------------------------|-------------------|---------------
1991|   |                          |                   |html1.0
1992|Aug？|setextリリース          |                   |
1993|   |                          |                   |
1994|   |                          |                   |W3C発足
1995|Mar|Wikiリリース              |Javadocリリース    |
    |   |                          |                   |html2.0
1996|   |                          |                   |xml草案
1997|Oct|                          |Doxygenリリース    |
    |   |                          |                   |html3.1
1998|   |                          |                   |html4.01, xml1.0
1999|Jul|STXリリース？(Zope 1.10.3)|                   |
2000|Jul|YukiWikiリリース          |                   |
2001|Jun|reSTリリース              |                   |
    |Dec|                          |RDocリリース       |
2002|Apl|reSTがDocutilsに統合      |                   |
    |Sep|                          |AsciiDocリリース   |
2003|Jan|はてな記法リリース？      |                   |
    |Dec|MediaWikiリリース         |                   |
2004|Aug|Markdownリリース          |                   |
2005|   |                          |                   |
2006|   |                          |Pandocリリース     |
2007|   |                          |                   |
2008|Jan|                          |                   |html5初期草案
    |Mar|                          |Sphinxリリース     |
2009|   |                          |                   |
2010|   |                          |                   |
2011|   |                          |                   |html5最終草案
2012|   |                          |                   |
2013|   |                          |                   |
2014|Aug|CommonMarkリリース        |                   |
    |Oct|                          |                   |html5勧告
2015|   |                          |                   |
2016|   |                          |                   |html5.1勧告予定

※ 「それ以外の出来事」はこの辺のサイトから参照しました。[Comparison of documentation generators](https://en.wikipedia.org/wiki/Comparison_of_documentation_generators)

### 考察

- setextはhtml誕生から見てもかなり早い時期にできている
- 一方Markdownは今回調べた中では一番後発だったのが(個人的には)意外だった
- 1999年～2004年、軽量マークアップ言語が数多く生まれている
    - この時期何かあったんだろうか？ドキュメント革命？
- 2004年以降はWikiやMarkdownのクローンや再実装がおそらく盛んであるはず
    - PHP Markdown Extra/GitHub Flavored MarkdownとかxxxWikiとか
    - 拡張ライブラリの歴史を調べると、2004年以降も埋まりそう

### 地味に苦労した点、、

- 昔の言語の情報を取得するのはかなり難しい(デッドリンクとか)
    - CHANGELOGが途中で途切れてるのが何故かわからなかったり
        - プロジェクト一新したから？
        - それともこのバージョンがInitial Releaseなの？
    - Wikipedia情報が唯一の情報源だったり
- グーグル力が低くて検索ワードが思いつかん…それぞれの記法の使い方がヒットする

以下、それぞれ調べたこと。

## reST

### setext(structure-enhanced text)

基本情報        | 詳細
----------------|-------------
Developed       | Ian Feldman or Tony Sanders
Initial Release | 1992/08/16～？
Official        | [setext Documents Mirror](http://docutils.sourceforge.net/mirror/setext.html)、跡地しかない？

- reSTのご先祖様
- Ian Feldmanのメール(1992/08/16)
    - setext_concepts_Aug92.etx.txtの翻訳 [setext Japanese Document](http://www.piedey.co.jp/xetext/sedocs.html)

> Enclosed is an advance sheet that will remain in effect until the first public release of the setext format package (originally planned for around March 1st, 1992, now delayed). 
>
> via: [setext_concepts_Aug92.etx.txt](http://docutils.sourceforge.net/mirror/setext/setext_concepts_Aug92.etx.txt)

- 1992/01/06にTidBITSの新しいフォーマットとして紹介されている
    - [TidBITS: TidBITS in new format](http://tidbits.com/article/3282)
    - 今も使われているのだろうか？
- TidBITS以外のニューズレターにも使われていたみたい
    - 福井県立大学の田中先生がこれを閲覧できるアプリを作ってた [こんなスタックを作ってた](http://mtlab.ecn.fpu.ac.jp/mac/my_hypercard_stacks.html)
- 電子出版用のフォーマットとして期待されていた？
    - [setext and xetext page - 株式会社ピーデー](http://www.piedey.co.jp/xetext/index.html)
- ソースコードが見つからない…

### StructuredText

基本情報        | 詳細
----------------|-------------
Developed       | Zope(Jim Fulton)？
Initial Release | 1999/07/19(Zope 1.10.3)
Official        | [Zope](http://www.zope.com)に含まれている

- reSTのご先祖様
- 現在確認できた最古のソースは1.10.3 1999/07/19([Zope.org - Zope](http://old.zope.org/Products/Zope/swpackage_releases))
    - その中のCHANGES.txtに1.9 alpha 1の記述ありだが日付までは書いてない…

```html
Zope 1.9 alpha 1

      This was the inital Zope test release.StructuredText.py
```

- [Zope.org - An Introduction to Structured Text](http://old.zope.org/Documentation/Articles/STX/)
- どうも1996年あたりから存在するらしいが、ソースコード、またはCHANGELOGから追えなかった。その当時Zope使っていた人なら知っているかも
- 現在のlatest versionは[4.1.0(2014/12/29)](https://pypi.python.org/pypi/zope.structuredtext/4.1.0)のようなんだけどまだ使われているのだろうか？
    - 4.1.0に「support for Python 3.4」の文字が
    - [StructuredText 2.11.1 : Python Package Index](https://pypi.python.org/pypi/StructuredText/2.11.1) こっちはZope2とやり取りする用？

### reStructuredText

基本情報        | 詳細
----------------|-------------
Developed       | David Goodger
Initial Release | 2001/06/02(reST 0.1)
Official        | [reStructuredText](http://docutils.sourceforge.net/rst.html)

- reSTと略す
- [StructuredText](http://dev.zope.org/Members/jim/StructuredTextWiki/FrontPage/)と、[setext](http://docutils.sourceforge.net/mirror/setext.html)の再実装である(revision and reinterpretation)
- reSTのやりたいことやゴールは下記のページで本人David Goodgerがアツく語っている
    - [An Introduction to reStructuredText](http://docutils.sourceforge.net/docs/ref/rst/introduction.html)
    - [reStructuredText 入門 — Docutils documentation in Japanese 0.12 ドキュメント](http://docutils.sphinx-users.jp/docutils/docs/ref/rst/introduction.html)
- Doc-SIGにその当時のやり取りも残っているので、ここを読んでみるのもよさそう
    - [[Doc-SIG] An Introduction to reStructuredText](https://mail.python.org/pipermail/doc-sig/2001-June/001858.html)

#### プロジェクトの推移

- [Docutils](http://docutils.sourceforge.net/)パッケージに含まれている軽量マークアップ言語
    - reST 0.1-0.4までは単独プロジェクトだった(2001/06/02-2002/04/18)
    - 統合されたのはDocutilsのv0.1から(2002/04/02)

以下はreST 0.4のChangelog。

```html
Release 0.4 (2002-04-18)
========================

This is the final release of reStructuredText as an independent
package.  Development is being transferred to the Docutils_ project
immediately.
```

- 元々単独プロジェクトだったものが[Docutilsのv0.1](http://docutils.sourceforge.net/HISTORY.html#release-0-1-2002-04-20)でDocstringと統合されている(2002/04/20)

> merged from the now inactive reStructuredText and Docstring Processing System projects

- [reStructuredText](http://structuredtext.sourceforge.net/)跡と、[旧ページ](http://structuredtext.sourceforge.net/index-old.html)

> Date: 2002-04-21
>
> The reStructuredText project has moved! It is now part of the Docutils project; you should be redirected to the new location momentarily. Click here to go to the Docutils project home page immediately.
> You may also visit the inactive reStructuredText home page.

- [Docstring Processing System](http://docstring.sourceforge.net/)跡と、[旧ページ](http://docstring.sourceforge.net/index-old.html)

> Date: 2002-04-21
>
> The Docstring Processing System project has moved and been renamed! It is now called "Docutils"; you should be redirected to the new location momentarily. Click here to go to the Docutils project home page immediately.
> You may also visit the inactive Docstring Processing System home page.

- [setext Documents Mirror](http://docutils.sourceforge.net/mirror/setext.html)跡

> Here are local copies of some setext documents, made available to document the prehistory of the Docutils project (and especially the reStructuredText markup). The source for the original setext (structure-enhanced text) documents was http://www.bsdi.com/setext/, but it seems to have disappeared from the Web.
> The files in the "setext mirror" are all the files relating to setext that I have (including a tarball of the lot). I have not been able to locate the originators of setext, Ian Feldman or Tony Sanders. If you know how to contact them, or if you know of an official repository for the setext documents, please inform me.
> David Goodger, 2002-03-25

## Markdown

### Markdown

基本情報        | 詳細
----------------|-------------
Developed       | John Gruber
Initial Release | 2004/08/28(1.0 Markdown.plより)
Official        | [Daring Fireball: Markdown](http://daringfireball.net/projects/markdown/)

- 多分この辺りが製作者が一番始めにMarkdownに言及した記事かな
    - [Daring Fireball: Introducing Markdown](http://daringfireball.net/2004/03/introducing_markdown)
    - [Daring Fireball: Dive Into Markdown](http://daringfireball.net/2004/03/dive_into_markdown)
    - [Daring Fireball: Markdown Web Dingus](http://daringfireball.net/projects/markdown/dingus) テキスト変換ページ
- reSTを参考にしているらしい(高橋さんの資料より)
- v1.0.1(2004/12/07)で **更新終了**

#### 更新終了後について

- John Gruberはこれ以上の新機能追加や仕様の標準化には消極的で、利用者によって多くの拡張Markdownが作られた。
    - PHP Markdown ExtraやGitHub Flavored Markdownなど
- Jeff AtwoodとJohn MacFarlaneが先頭になってMarkdown標準化のプロジェクトが推し進められた
    - ことはJeff Atwoodの[2009年の記事](http://blog.codinghorror.com/responsible-open-source-code-parenting/)から始まる…
- **なんやかんやあって** CommonMarkが発足した
    - このあたりのいきさつはWEB+DB PRESS Vol.83に書いてあるので割愛

### CommonMark

基本情報        | 詳細
----------------|-------------
Developed       | Jeff Atwood, John MacFarlane他多数
Initial Release | 2014/08/14([jgm/CommonMark@650ad87](https://github.com/jgm/CommonMark/commit/650ad87f35f4405a2ca8270d2b2835daa442e5f1))
Official        | [CommonMark](http://commonmark.org/)

- 上記のようないきさつの末、発足
- 発足後も結構もめたらしい
    - 当初はstandard markdownと名前をつけていたがJohn Gruberに勝手にMarkdownの名前使うなと言われて改名したり
- Markdownを使ったプロダクトやサービスを使っている企業の人が参加している

> John MacFarlane（Pandoc作者、カリフォルニア大学バークレー校）
>
> David Greenspan（EtherPad作者、Meteor）
>
> Vicent Mart（i Sundown、Redcarpet作者、GitHub）
>
> Neil Williams（Snudown（reddit 拡張が入ったSundown）作者、Reddit）
>
> Benjamin Dumke-von der Ehe（pagedown 作者、Stack Overflow）
>
> Jeff Atwood（Civilized Discourse Construction Kit）
>
> via: WEB+DB PRESS Vol.83より抜粋

- John Gruberは参加していない(許可は取っている)
- 今後、標準となるか

## Wiki

### Wiki

基本情報        | 詳細
----------------|-------------
Developed       | Ward Cunningham
Initial Release | 1995/03/25 or 1995/05/01
Official        | [Front Page - http://c2.com/cgi/wiki](http://c2.com/cgi/wiki?)

- Wikiの親玉
- すべてのWikiシステムはこれが親と言えそう
- 作成者はWard Cunningham...ウォードカニンガム…あ！名前聞いたことあるわ！この人が作ったのか

### YukiWiki

基本情報        | 詳細
----------------|-------------
Developed       | 結城浩
Initial Release | 2000/07/15(readme.txtより)
Official        | [YukiWiki](http://www.hyuki.com/yukiwiki/)

- いわゆるWikiクローンのひとつ。結城先生作。2000年に作成されている

> Cunningham & CunninghamのWikiWikiWebの仕様を参考にして作られ、 多くの人からのフィードバックを受けてゆっくり成長しています。

- PukiWikiもYukiWikiクローン

> YukiWiki を PHP に移植する形で開発された wiki クローン。

### MediaWiki

基本情報        | 詳細
----------------|-------------
Developed       | Magnus Manskeら
Initial Release | 2003/12/08(1.1)
Official        | [MediaWiki](http://www.mediawiki.org/wiki/MediaWiki)

- Wikipediaのために作られWikipediaで使用されている
    - 2015年現在一番記事数が多いWikiシステムだとか
- 1.1よりも前にPhase3というバージョンが2003/04/14にリリースされている
    - Wikipedia(英語版)の設立は2001/01/15
    - この空白の期間はどうしていたんだろう？

## その他

### はてな記法

基本情報        | 詳細
----------------|-------------
Developed       | はてな(近藤淳也？)
Initial Release | 2003/01？
Official        | [はてなダイアリー - 写真・画像・動画付き日記を無料で](http://d.hatena.ne.jp/)

- はてなのサービス内で使用できる記法

> 「はてな記法」とは、はてなダイアリーを書く上で便利な機能を、かんたんな記述で実現することができる記述法のことです。
>
> はてな記法を使うと、HTMLの知識がなくても、見出しやリストといった、ブログを書く上で便利な表現を簡単に行うことができます。
>
> via: [はてな記法ってなに？ - はてなダイアリーのヘルプ](http://hatenadiary.g.hatena.ne.jp/keyword/%E3%81%AF%E3%81%A6%E3%81%AA%E8%A8%98%E6%B3%95%E3%81%A3%E3%81%A6%E3%81%AA%E3%81%AB%EF%BC%9F)

- はてなダイアリーと同じくらいにリリースされている？？
    - 近藤さんの日記(2003/01/21)
        - [日記統合 - jkondoのはてなブログ](http://jkondo.hatenablog.com/entry/20030121)
    - 2003/01にはてなダイアリーのβがリリース
        - [教科書にのらない!はてなの歴史 - はてな10周年! #hatena10th - はてな](https://www.hatena.ne.jp/company/hatena10th/history)
    - 記法の説明っぽい最古の記事は2003/03/01にある("記法"で日記内検索した)
        - [BLOCKQUOTE省略記法 - はてなダイアリー日記](http://d.hatena.ne.jp/hatenadiary/20030301/1046490045)
    - "はてな記法"だと2005/06の記事が引っかかる
        - [RSSフィードの仕様変更について - はてなダイアリー日記](http://d.hatena.ne.jp/hatenadiary/20050613/1118636067)
- はてな記法がリリースされた厳密な時期はわからない…
    - [2003/05のはてなダイアリーヘルプ](http://web.archive.org/web/20030515161156/http://d.hatena.ne.jp/help#editrule)
    - [2004/04のはてなダイアリーヘルプ](http://web.archive.org/web/20040404023316/http://d.hatena.ne.jp/help#editrule)
        - "はてな記法"というワードはないが、書き方はそれに近い(というか同じ)
- β版リリース時に独自記法は存在したが、"はてな記法"と命名されるまでにタイムラグがある？
    - 2004/11にはあった？ [無印吉澤 - はてな記法ジャンキー](http://muziyoshiz.jp/20041119.html)

ギリギリMarkdownよりはやいのかな？

## 終わりに

この文章はMarkdownで書かれています。

## おまけ: 参考サイト

### Markdown系

- もっと知りたい！Markdown! 高橋 征義(WEB+DB PRESS Vol.83)
- [Markdownもはじめよう - Slideshare](http://www.slideshare.net/takahashim/sphinx-markdown)

### reST系

- [reStructuredText - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/ReStructuredText)
- [reStructuredText入門 — Python製ドキュメンテーションビルダー、Sphinxの日本ユーザ会](http://sphinx-users.jp/articles/expertpython/restructuredtext.html)
- [AdventCalendar - Docutils と Ruby で快適ドキュメント生活 - Qiita](http://qiita.com/wtnabe@github/items/ceea10a287eaaf420df7)
- [An Introduction to reStructuredText](http://docutils.sourceforge.net/docs/ref/rst/introduction.html)
- [reStructuredText 入門 — Docutils documentation in Japanese 0.12 ドキュメント](http://docutils.sphinx-users.jp/docutils/docs/ref/rst/introduction.html)
- [setext - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/setext)
- [sf's setext Home Page](http://www.age.ne.jp/x/sf/SETEXT/)
- [SGML vs setext](http://www.w3.org/MarkUp/html-test/setext/setext+sgml_01.html) Ian Feldmanのメール
- [renya.com - 電子書籍のデータ形式と対応ビュワー](http://www.renya.com/textware/format.htm)

### Wiki系

- [ウィキ - Wikipedia](http://ja.wikipedia.org/wiki/%E3%82%A6%E3%82%A3%E3%82%AD)
    - [WikiWikiWeb - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/WikiWikiWeb)
    - [ウォード・カニンガム - Wikipedia](http://ja.wikipedia.org/wiki/%E3%82%A6%E3%82%A9%E3%83%BC%E3%83%89%E3%83%BB%E3%82%AB%E3%83%8B%E3%83%B3%E3%82%AC%E3%83%A0)
    - [Wikiを生み出したエンジニア、ウォード・カニンガムとは？ | IT系のインターンシップならエンジニアインターン](http://engineer-intern.jp/archives/34927)
- [Wiki History](http://c2.com/cgi/wiki?WikiHistory)
- [日本発の wiki クローンリスト](http://www.yamdas.org/column/technique/clonelist.html)
- [YukiWiki](http://www.hyuki.com/yukiwiki/)
    - [WikiWikiWeb - WikiWikiWebとは何か](http://www.hyuki.com/yukiwiki/wiki.cgi?WikiWikiWeb)
- [MediaWiki - Wikipedia](https://ja.wikipedia.org/wiki/MediaWiki)
- [MediaWiki version history - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/MediaWiki_version_history)

### その他

- [ブラウザとＨＴＭＬの歴史＜インターネット個人利用＜歴史＜木暮仁](http://kogures.com/hitoshi/history/browser/index.html)
- [いまさら振り返る HTML の歴史 - Aizu Advent Calendar 2012 - Qiita](http://qiita.com/sh19910711/items/0292e03f97a35f84e7e6)

