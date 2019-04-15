---
layout: post
title: "Rails3のログ出力にANSIカラーコードを使用しない設定"
description: ""
category: 
tags: [Ruby, Rails, Redmine]
---

## あらすじ

WindowsでRails(Redmine)を実行した時のログが超見づらいのはなんで？

こんな風になる。helloと表示されるはずの場合。

```console
 [31mhello[0m
```

何とかしたい。

## 環境

- Windows 7
- Rails 3.2

## 参考サイト

### ANSIカラーというコードを使用されている

- [RubyでANSIカラーシーケンスを学ぼう！](http://melborne.github.io/2010/11/07/Ruby-ANSI/)
- [謎のC言語ブログ: ANSI標準エスケープシーケンス](http://hatenaclang.blogspot.jp/2011/03/ansi.html)

### この現象自体を止めるには

- [Ruby - Rails3でログの色分けを止める - Qiita [キータ]](http://qiita.com/nekoruri/items/3dc559949b1ece85962a)
- [設定ファイル(config) - Railsドキュメント](http://railsdoc.com/config#%E3%83%AD%E3%82%B0%E3%82%92%E5%87%BA%E5%8A%9B%E3%81%99%E3%82%8B%E3%81%A8%E3%81%8D%E3%81%AB%E3%82%AB%E3%83%A9%E3%83%BC%E3%81%AB%E3%81%99%E3%82%8B%E3%81%8B%28config.colorize_logging%29)

### Windows(コマンドプロンプト)でもANSIカラー(未実施)

- [WindowsのコマンドプロンプトでRailsのログをカラー表示する - yyamasakの日記 - Rubyist](http://rubyist.g.hatena.ne.jp/yyamasak/20100106)
- [Windows ansi.sys](http://homepage2.nifty.com/LM/kurogam/w2k-ansi.htm)
- [WindowsのコマンドプロンプトでもANSIカラーを使いたい「wac」｜オープンソース・ソフトウェア、ITニュースを毎日紹介するエンジニア、デザイナー向けブログ](http://www.moongift.jp/2011/01/20110102-2/)

## ANSIカラー

- ターミナルにおいて、文字に色を付けるためのエスケープシーケンスみたい
- ソースコード上には `print "\e[31mhello\e[0m"` こう記載されている
  - `\e[xxm` がコード
    - `31` は文字色を赤に
    - `0` は終われ
  - コードによって文字色、背景色、装飾をいじることができる

で、Rail3はこれに対応しているので、UnixとかMacとかだとログが色分けされ美しく表示されるようになっている。(あとCygwinでもいけるっぽい)

そういえば、さくらVPS上(CentOS)でRailsを実行している時は奇麗だったんだよな思い出してみれば。

## 無効化するには

Windowsでも色つけができる(参考サイト参照)ようだが、めんどいので無効化する方向で。

`REDMINE/config/application.rb` に以下の記述を追加。

```ruby
   config.colorize_logging = false
```

特定環境のみとかの設定もできるが、とりあえずオールオフで。
