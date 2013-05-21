---
layout: post
title: "GitHub PagesでJekyllプラグインを使えるようにするには…"
description: ""
category: 
tags: [Jekyll, Git]
---
{% include JB/setup %}

## あらすじ

Jekyll＠GitHub Pagesの場合、Liquidで(自分で)作ったプラグインは使えないという事が判明した。(ローカルで起動した場合/safeモードじゃない場合は関係ない)

- [俺の最強ブログシステムも火を噴いてたぜ - Webtech Walker](http://webtech-walker.com/archive/2012/09/fired-myblog.html)

これを回避するには

- GitHub Pages をやめる(レンタルサーバを借りてデプロイ)
- GitHub Pages に **静的ファイル** としてhtml自体をデプロイ

する方法がありそう。今回はGitHub Pagesを使い続けたいので後者で頑張ってみる。

## 参考サイト

- [github:help](https://help.github.com/categories/20/articles)

## そもそもGitHub Pagesとはなんぞや

> ### User & Organization Pages
> 
> User & Organization Pages はPagesファイル専用のスペシャルリポジトリとして生きている。このリポジトリはaccount nameを使用する。例えば、defunkt/defunkt.github.com
> 
> - このリポジトリは `username/username.github.com` というnaming schemeを使わなければならない
> - `master` ブランチからのコンテンツはビルドとパブリッシュに使用される
>
> - ...
> 
> ### Project Pages
> 
> Project Pages は同じリポジトリからプロジェクトとして維持される。これらのページはUser PageとOrg Pagesほとんど正確に同じである。いくつかのわずかな違いはある。
> 
> - `gh-pages` ブランチはビルドとパブリッシュに使用される
> - カスタムドメインを使っていないなら、Project PagesはUser Pageのサブパスの下で使われる。 `username.github.com/projectname`
> - ...

### ということは

まず、GitHub Pagesは2種類ある。

1. **ユーザ、組織用** のページ
   - 己のページ
   - `USERNAME.github.com` という特別なリポジトリを作れば `http://USERNAME.github.com` でアクセスできる
   - ビルドには `master` ブランチが使用される
1. **プロジェクト** のページ
   - 各プロジェクト用のページ
   - GitHubに `PROJECT` というプロジェクトがあれば `http://USERNAME.github.com/PROJECT` でアクセスできる
   - ビルドには **`gh-pages`** ブランチが使用される

という事でよろしい？

### かぶった場合どうなる？

ところで、こうなるとユーザのGitHub Pagesにプロジェクト名と同じ階層でファイルを作ったらどっちが呼ばれるの？

=> [あーありがち - github pagesとjekyllを今さら練習 , 夏だ](http://aligach.net/diary/20120716.html) によると、

> 1. github.com/wtnabe/wtnabe.github.com 内に /ical2gcal/index.html を作成
>    - 作った /ical2gcal/index.html が wtnabe.github.com/ical2gcal/ に表示される
> 1. github.com/wtnabe/ical2gcal に gh-pages branch を作る
>    - 作った gh-pages が wtnabe.github.com/ical2gcal/ に表示される
> 1. github.com/wtnabe/wtnabe.github.com/ical2gcal/index.html を編集
>    - 今編集したファイルが表示される。つまり 1 に戻る。

ちょっと気をつけないといけない。

## GitHub Pagesの作り方

プロジェクト用のGitHub Pagesの場合。

既に `master` が少し育っているとして `gh-pages` ブランチを作成してみる。とりあえず、GitHubから以下のようなコマンド例が提示される。

{% highlight console %}
$ cd /path/to/repo-name
$ git symbolic-ref HEAD refs/heads/gh-pages
$ rm .git/index
$ git clean -fdx
$ echo "My GitHub Page" > index.html
$ git add .
$ git commit -a -m "First pages commit"
$ git push origin gh-pages
{% endhighlight %}

何をやっているのかというと… `master` ブランチ(というか、ソースとかがある本流のブランチ？)と **独立した空っぽのブランチ** を作り、そこにindex.htmlをpushしている。

### コマンド、オプションのメモ

{% highlight console %}
$ cd /path/to/repo-name
$ git symbolic-ref HEAD refs/heads/gh-pages
{% endhighlight %}

`HEAD(.git/HEAD)ファイル` には最終コミットの参照が入っている。例えば…

{% highlight console %}
$ cat .git/HEAD
ref: refs/heads/master
{% endhighlight %}

こんなん。で、checkoutとかすると変わる。このHEADファイルを変更するためのコマンドが `symbolic-ref` 。

移動した後は、Gitで管理していたファイルはインデックスに移っている。

{% highlight console %}
$ rm .git/index
$ git clean -fdx
{% endhighlight %}

ので、まず `index` ファイルを削除してインデックスにあったファイルを追跡対象から除外。

そして `clean` コマンドで追跡対象外のファイルを掃除。 `-f` 実行(このオプションを指定しないと実行されない)、 `-d` ディレクトリも含める。 `-x` 無視ファイルも削除

{% highlight console %}
$ echo "My GitHub Page" > index.html
$ git add .
$ git commit -a -m "First pages commit"
$ git push origin gh-pages
{% endhighlight %}

奇麗さっぱりしたらindex.htmlを作ってFirst commit...。

これで `master` ブランチ(ソース)とは完全に独立した `gh-pages` ブランチが作成できた。

## JekylプラグインをGitHub Pagesで使えるようにするには

さてようやく本題。

今までの情報からわかった事は以下。

- 自分が使っているのは **ユーザ用のGitHub Pages**
  - つまり、 **`master`** ブランチのファイルがビルドされる
- 今の `master` ブランチにはJekyll用のソースがある
  - ページのテンプレートやMarkdownで書かれたエントリなど

この状況を以下のように変更する。

- `source` ブランチ: 現在の `master` ブランチのソースをそのまま持ってくる
  - エントリなどはこちらで書いていく事になる
- `master` ブランチ: 一旦からっぽにして、 `source` ブランチのソースから生成した **静的ファイル** を持ってきてプッシュする
  - ローカルで一旦生成しちゃった後でGitHub Pagesにpushしているから、プラグインが動かないという問題も起こらない

そうすると

- `source` ブランチでファイルを生成する(_site/直下)
- これを `master` にコピーする
- push

を毎回やらなければならない…それはめんどくさい！

これはrakeでやればいいかな。

- Rakefile にdeployコマンドとして上記の動作を実行してくれる処理を記載する
  - [deploy タスクを追加 2943985 gosyujin/gosyujin.github.com GitHub](https://github.com/gosyujin/gosyujin.github.com/commit/2943985064ced913767157eb0fdae431b68ac491)

こんな感じ。

{% highlight ruby %}
# Usage: rake deploy
desc "Begin a push static file to GitHub"
task :deploy do
  puts "! Copy static file from _site to _deploy"
  sh "cp -r _site/* _deploy/"
  puts "! Change directory _deplay"
  cd "_deploy" do
    puts "! Push to master branch of GitHub"
    sh "git add *"
    message = "deploy at #{Time.now}"
    begin
      sh "git commit -m \"#{message}\""
      sh "git push origin master:master"
    rescue Exception => e
      puts "! Error - git command abort"
      exit -1
    end
  end
end
{% endhighlight %}

とやれば、手間はそれほど変わらずにGitHub PagesでJekyllプラグインが使えるか。
