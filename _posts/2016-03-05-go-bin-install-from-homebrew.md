---
layout: post
title: "Golangで作ったスクリプトをbrew install&brew updateできるようにする"
description: ""
category: 
tags: [Golang, Homebrew]
---

## あらすじ

Golangでスクリプトを作ったので、バイナリにして`homebrew`でインストール/アップデートできるようにしてみた。

細かく色々できるけど、とりあえず今回は最小で。

## 参考

- [HomeBrewで自作ツールを配布する | SOTA](http://deeeet.com/writing/2014/05/20/brew-tap/)
- [Go言語でつくったツールをHomebrewで配布する · THINKING MEGANE](http://blog.monochromegane.com/blog/2014/05/19/homebrew-formula-for-golang/)
- Mackerel
    - [mackerelio/homebrew-mackerel-agent](https://github.com/mackerelio/homebrew-mackerel-agent)
    - [mackerelio/mackerel-agent](https://github.com/mackerelio/mackerel-agent)

## 環境

- MacOS X El Capitan 10.11.3
- go version go1.5.3 darwin/amd64
- ruby 2.1.4p265

## 要件

- GitHubに上げたスクリプトを`brew install xxx`でインストールできるようにしたい
- でもたまには`go get github.com/xxx`でもインストールしたい

## ブツ

まずはブツを作った。

- [gosyujin/bulkrenamer](https://github.com/gosyujin/bulkrenamer)

引数にディレクトリ与えたら、最下層のファイルを直前のディレクトリ名にリネームするっ的なスクリプト。こちらは特に意識する必要はない。

なんとなく動くようになったら、`go build`して作ったファイルを[GitHubのReleases](https://github.com/gosyujin/bulkrenamer/releases)から`v0.1`として追加した。(割愛/今回は配布先のPCにgoコマンドがない前提なので、実行ファイルをそのまま配る)

- 実行ファイルのUrlを覚えておく
    - `https://github.com/gosyujin/bulkrenamer/releases/download/v0.1/bulkrenamer`
- sha1のハッシュ値を取っておく

## Homebrew用設定

### Formulaの作成

- [gosyujin/homebrew-bulkrenamer](https://github.com/gosyujin/homebrew-bulkrenamer)

`brew create`で作れるみたいだけど、とりあえず手打ち。

リポジトリの名前は`homebrew-APPNAME`とするルール。今回はbulkrenamerなので`homebrew-bulkrenamer`リポジトリを作った。

ファイルは`APPNAME.rb`。今回は`bulkrenamer.rb`

```ruby
class Bulkrenamer < Formula
  desc "BulkRenamer"
  homepage "https://github.com/gosyujin/bulkrenamer"
  head "https://github.com/gosyujin/homebrew-bulkrenamer.git"
  version "v0.1"
  url "#{homepage}/releases/download/#{version}/bulkrenamer"
  sha1 "5e3ac6469395aae60a00c61f45b5343207cca330"

  def install
    bin.install Dir['bulkrenamer']
  end
end
```

sha1で比較とか他にも色々できるが、ひとまず

- `url`はツールの場所
- `version`はFormulaのバージョン。バージョンアップ時に使う

だけ。

## インストールとアップデート

### Homebrewでインストール

`tap`して`install`でいける！

```sh
$ brew tap gosyujin/bulkrenamer
==> Tapping gosyujin/bulkrenamer
Cloning into '/usr/local/Library/Taps/gosyujin/homebrew-bulkrenamer'...
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
Checking connectivity... done.
Tapped 1 formula (25 files, 16.8K)
$ brew install bulkrenamer
==> Installing bulkrenamer from gosyujin/bulkrenamer
==> Downloading https://github.com/gosyujin/bulkrenamer/releases/download/v0.1/bulkrenamer
==> Downloading from https://github-cloud.s3.amazonaws.com/releases/52855923/178f416a-dfc8-11e5-9f9c-fc48ca5e1c98?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISTNZFOVBIJM
(略)
🍺  /usr/local/Cellar/bulkrenamer/v0.1: 2 files, 7M, built in 8 seconds
$ bulkrenamer -v
BulkRenamer ver.0.1
```

### Homebrewでアップデート

[homebrew-bulkrenamer](https://github.com/gosyujin/homebrew-bulkrenamer)を更新して`brew update`してもらう。

今回は配布ファイル変えずにバージョンだけ上げてみた。

- v0.2になっているのは一回試した後だから
- 本来の流れ的にはブツ(bulkrenamer)を更新してreleasesに新しいバージョンを登録後、この操作を行う

<script src="https://gist.github.com/gosyujin/5c5ee96c7cc405405749.js"></script>

`brew update`

```sh
$ brew update
Updated Homebrew from 468adbc to 215cb53.
Updated 3 taps (caskroom/cask, caskroom/versions, gosyujin/bulkrenamer).
 ==> New Formulae
dropbox-uploader         gnu-complexity
 ==> Updated Formulae
cromwell                 mitmproxy
dcd                      nss
dmd                      planck
gosyujin/bulkrenamer/bulkrenamer ✔               rust
libpagemaker
```

`brew outdated`で更新があるツールの確認。

```sh
$ brew outdated
gosyujin/bulkrenamer/bulkrenamer (v0.1, v0.2 < v0.3)
go (1.5.3 < 1.6)
openssl (1.0.2f < 1.0.2g)
```

`brew upgrade`

```sh
$ brew upgrade bulkrenamer
==> Upgrading 1 outdated package, with result:
gosyujin/bulkrenamer/bulkrenamer v0.3
==> Upgrading gosyujin/bulkrenamer/bulkrenamer
==> Downloading https://github.com/gosyujin/bulkrenamer/releases/download/v0.3/bulkrenamer
==> Downloading from https://github-cloud.s3.amazonaws.com/releases/52855923/c0686154-e21b-11e5-92d2-6d76b5ceb265?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISTNZFOVBIJM
(略)
🍺  /usr/local/Cellar/bulkrenamer/v0.3: 2 files, 7M, built in 8 seconds
```
