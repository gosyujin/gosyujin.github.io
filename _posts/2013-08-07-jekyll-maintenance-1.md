---
layout: post
title: "Jekyllバージョンアップの際に思いのほか手こずった話 Jekyll Bootstrapの更新に追従したい編"
description: ""
category: 
tags: [Ruby, Jekyll, Git]
---

## あらすじ

forkとか、fetchとか、本で読んでるだけじゃ実際やりたい時にどうやりゃいいかわからん…という話。

---

Github Pagesで運用しているJekyllのバージョンアップをする時に死んだ

- 原因は、他の人が公開しているプラグインやcssをほいほい **コピペ** していたため
  - 公開先ではもちろんJekyllの更新に追従しており、更新を怠った己が自爆しているだけ)
- なんとか自分のリポジトリでも追従したい。でもコピペはやだ

追従したいのは、主に Jekyll Bootstrap ファイル全般と @nitoyon さんのてっく煮ブログで使われているプラグイン。(特にはてな系)

パッパとやって手順だけメモするかーと思ったら凄まじくてこずったので、今回はBootstrapだけ。

## 環境

- Ruby 1.9.3
  - RedCloth (4.2.9)
  - bundler (1.3.5)
  - classifier (1.3.3)
  - colorator (0.1)
  - commander (4.1.4)
  - directory_watcher (1.4.1)
  - fast-stemmer (1.0.2)
  - highline (1.6.19)
  - hparser (0.4.0 dc35f05)
  - jekyll (1.0.0 9f94eaf)
  - kramdown (0.14.2)
  - liquid (2.5.1)
  - maruku (0.6.1)
  - posix-spawn (0.3.6)
  - pygments.rb (0.4.2)
  - rake (10.1.0)
  - rdiscount (2.1.6)
  - redcarpet (2.2.2)
  - safe_yaml (0.7.1)
  - syntax (1.0.0)
  - yajl-ruby (1.1.0)

## 参考サイト

- [Git - サブモジュール](http://git-scm.com/book/ja/Git-%E3%81%AE%E3%81%95%E3%81%BE%E3%81%96%E3%81%BE%E3%81%AA%E3%83%84%E3%83%BC%E3%83%AB-%E3%82%B5%E3%83%96%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB)
- [Git で複数のリポジトリをまとめたり、逆に切り出したりする - Qiita [キータ]](http://qiita.com/uasi/items/77d41698630fef012f82)
- [gitでforkしたrepoにoriginalのrepoをmergeする手順 - memo.yomukaku.net](http://memo.yomukaku.net/entries/Xj9vo6X)
- [fork元の xupdate が更新されたので追従する ｜ BmathLog](http://bmath.org/wordpress/?p=1733)
- [オダろぐ : Git＞マージがコンフリクトしたときに，どちらかを有効にする方法](http://blog.livedoor.jp/odaxsen/archives/1624005.html)

## やりたい事: Jekyll Bootstrap 編

テンプレートとかcssが更新されたらそれを取得して適用したい。

初回に 0.2.13 を持ってくる時はごっそりコピーして自分のリポジトリにaddしてただけなので…。

毎回コピーするよりはなにかうまい方法を探したい。

### 方針

- Jekyll Bootstrapの新しいバージョン(ブランチ/タグ)をみて新しいのが出たらマージ

### その1: Jekyll Bootstrapリポジトリから直接更新分を持ってくる(断念)

まずは、自分のJekyllプロジェクトに、本家のJekyl Bootstrapをリモートリポジトリとして登録する。

{% highlight console %}
$ git remote add jb http://github.com/plusjade/jekyll-bootstrap.git
$ git remote -v
jb      http://github.com/plusjade/jekyll-bootstrap.git (fetch)
jb      http://github.com/plusjade/jekyll-bootstrap.git (push)
origin  http://github.com/gosyujin/gosyujin.github.com.git (fetch)
origin  http://github.com/gosyujin/gosyujin.github.com.git (push)
{% endhighlight %}

#### マージする

適用するブランチ/タグを探す。

参考: ブランチなら`remote show` でも見れるんだけど、タグを見るには `ls-remote --tags` コマンドというものがあるみたい。

{% highlight console %}
$ git ls-remote --tags jb v*
20f90ffb0fa840f6aea90fc581ffd0dc84ee701f        refs/tags/v0.1.0
c1972379f3fa93998947f355948359c24f1307a5        refs/tags/v0.1.0^{}
8d498097c81e685fee3b1d1ffe61fcb66784db31        refs/tags/v0.2.0
4c29c7ed76a1f972b456f3cd158432caef5c0a81        refs/tags/v0.2.0^{}
37c14cf57ef968b8d27a54f9c3b55957bd9f7591        refs/tags/v0.2.1
3a2df76133171e1cd576708a60694e7d0632b671        refs/tags/v0.2.1^{}
f23e43f6f5cc564a3f411c503ca4eceb88b8b4c7        refs/tags/v0.2.13
9c0026973bf54324304ed1b917bb227603d87071        refs/tags/v0.2.13^{}
8fc944393399c6f64a2fa54045ce3cb7282e1970        refs/tags/v0.2.7
12e41751883d7336225cfd039139137bac9eca4d        refs/tags/v0.2.7^{}
7b27f21b7eb8f84be4decfe9085d82c6eb374e8d        refs/tags/v0.2.8
cefdd4e2c3ff08a1e949e035d492387b90329c88        refs/tags/v0.2.8^{}
653b332f47eff2f8fbe36eaca206fa0f1136d9ad        refs/tags/v0.2.9
162a85dfb6f2801840b00ae995adeb322487132b        refs/tags/v0.2.9^{}
{% endhighlight %}

ん？ `^{}` はなんだ…？ちょっとわからないところがあるが、いったんおいといて最新版をfetchしてmerge。(どうもtagが切られていないだけで、0.3.0が出ているよう)

{% highlight console %}
$ git fetch jb HEAD
warning: no common commits
remote: Counting objects: 658, done.
remote: Compressing objects: 100% (350/350), done.
remote: Total 658 (delta 324), reused 560 (delta 272)
Receiving objects: 100% (658/658), 209.25 KiB, done.
Resolving deltas: 100% (324/324), done.
From http://github.com/plusjade/jekyll-bootstrap
 * tag               HEAD     -> FETCH_HEAD
{% endhighlight %}

{% highlight console %}
$ git checkout source # 適用したいブランチに移動
$ git merge FETCH_HEAD
Auto-merging index.md
CONFLICT (add/add): Merge conflict in index.md
Auto-merging changelog.md
CONFLICT (add/add): Merge conflict in changelog.md
Auto-merging atom.xml
CONFLICT (add/add): Merge conflict in atom.xml
(略)
{% endhighlight %}

いっぱいコンフリクトしたので、地道にコンフリクト解消。。。

#### 結論

- 毎回コピーはしなくてよくなった
- Jekyll Bootstrap の更新はチェックする必要がある
- コンフリクト解消作業は毎回やることに…？(量が増えたら毎回めんどい？)
- **ログを確認するとき、Jekyll Bootstrapの更新も表示されてしまう** (かなり多い)

Bootstrap側でどんな更新があったかまでは確認できる必要もないんだけど…と思って調べていくと、 git checkout に `--orphan` オプションがあるということがわかった。

- [git-checkout(1)](https://www.kernel.org/pub/software/scm/git/docs/git-checkout.html)
- [ひょうたん: FuelPHPのgit管理にorphanブランチ使ったらどうかねぇ？](http://onjiro.blogspot.jp/2013/03/fuelphpgitorphan.html)

これは使えるかも?

### その2: Jekyll Bootstrapリポジトリを一回forkしてそこから更新分を持ってくる(採用)

今度は、はじめに **forkして** 自分のところに持ってくる。そしてclone。

{% highlight console %}
$ git clone http://github.com/gosyujin/jekyll-bootstrap.git # forkしたのでアカウントが `plusjade` から自分に変わっている
{% endhighlight %}

#### 自分用ブランチの作成

Bootstrap系のログを除外したいので、まったく独立した `oreore-jb` ブランチを作りたい。

独立したブランチを作るには `checkout --orphan` を使う。

{% highlight console %}
$ git checkout --orphan oreore-jb
Switched to a new branch 'oreore-jb'
$ git st
# On branch oreore-jb
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#       new file:   .gitignore
#       new file:   404.html
#       new file:   README.md
#       new file:   Rakefile
#       new file:   _config.yml
(略)
{% endhighlight %}

ファイルはステージングされた状態になっているのでそのままadd。

{% highlight console %}
$ git add .
$ git com "first commit"
[oreore-jb (root-commit) df703a3] fc
 46 files changed, 2530 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 404.html
 create mode 100644 README.md
 create mode 100644 Rakefile
 create mode 100644 _config.yml
(略)
{% endhighlight %}

これで、独立した `oreore-jb` ブランチにBootstrapの最新版が入ったことになる。

試しにmasterブランチでいくつか適当にコミットしたあとグラフを確認してみる。

{% highlight console %}
$ git g (グラフ表示エイリアス)
*   bb73195 8940469 2013-08-06 kk_Ataka  (HEAD, master) test2
| * df703a3 fac1d1e 2013-08-06 kk_Ataka  (oreore-jb) first commit
*   9da0a7c fac1d1e 2013-08-06 kk_Ataka  test1j
*   7501cf3 4b3dcb2 2013-07-26 Jade Dominguez  (origin/master, origin/HEAD) Merge add-drafts. closes #167
|\
| * c2d70e5 4b3dcb2 2013-07-23 Jade Dominguez  add draft feature
{% endhighlight %}

過去を断ち切れてる。

一度 `oreore-jb` を作れたら、以降は

- 本家の更新をチェック
- masterブランチにfetch, merge
- 独立ブランチ2 `feature` を作成
- `feature` と `oreore-jb` とmerge

するのかな？？

{% highlight console %}
$ git checkout --orphan feature # 本家の最新版を取り入れた後…
$ git add ./
$ git commit -m "更新取り入れ"  # この時点でブランチは大きく1. 本流, 2. oreore-jb, 3. feature の3つが存在する
$ git checkout oreore-jb
$ git merge feature             # 変更されてるところはぶつかる
Auto-merging Rakefile
CONFLICT (add/add): Merge conflict in Rakefile
Automatic merge failed; fix conflicts and then commit the result.
$ git ch --theirs Rakefile      # theirsのファイルかoursのファイルか(エディタ使って手でなおしてもいい)
$ git add ./
$ git commit -m "vX.X.X"
$ git g
*     221593a 028b015 2013-08-06 kk_Ataka  (HEAD, master) 本流の変更4
| *   940c432 a4f1743 2013-08-06 kk_Ataka  (oreore-jb) com
| |\
| | * 1938f54 a4f1743 2013-08-06 kk_Ataka  (feature) 新バージョン
* |   7b7427f f3131bb 2013-08-06 kk_Ataka  本流の変更3
* |   d109479 bd61d9c 2013-08-06 kk_Ataka  本流の変更2
| *   1fd0b54 9d627ae 2013-08-06 kk_Ataka  merge
| |\
| | * 626d51a 9d627ae 2013-08-06 kk_Ataka  tuizui
* |   6c592be 9d627ae 2013-08-06 kk_Ataka  本流の変更
| *   59abd4b 4b3dcb2 2013-08-06 kk_Ataka  first commit
*     7501cf3 4b3dcb2 2013-07-26 Jade Dominguez  (origin/master, origin/HEAD) Merge add-drafts. closes #167
$ git push origin oreore-jb:oreore-jb
{% endhighlight %}

わかりにくいけどグラフの左が本流、右が今回作ったJekyll Bootstrap自体の履歴をもたない `oreore-jb` 傍流。

#### 合体

これを、自分のJekyllにmergeしてやる。

{% highlight console %}
$ git re add jb http://github.com/gosyujin/jekyll-bootstrap.git
$ git fetch jb oreore-jb
remote: Counting objects: 7, done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 5 (delta 3), reused 0 (delta 0)
Unpacking objects: 100% (5/5), done.
From http://github.com/gosyujin/jekyll-bootstrap.git
 * branch            oreore-jb  -> FETCH_HEAD
$ git merge FETCH_HEAD   # コンフリクトした場合は解消にいそしむ
$ git g
| *     feaea36 1675a4d 2013-08-06 kk_Ataka  (HEAD, source) Merge branch 'oreore-jb' of ../jekyll-bootstrap into source
| |\
| | *   940c432 a4f1743 2013-08-06 kk_Ataka  com
| | |\
| | | * 1938f54 a4f1743 2013-08-06 kk_Ataka  新バージョン
| * |   6caafdd 7d2b1c0 2013-08-06 kk_Ataka  OK
| |\ \
| | |/
| | *   1fd0b54 9d627ae 2013-08-06 kk_Ataka  merge
| | |\
| | | * 626d51a 9d627ae 2013-08-06 kk_Ataka  tuizui
| | *   59abd4b 4b3dcb2 2013-08-06 kk_Ataka  first commit
* |     b3f9818 1d67408 2013-08-06 kk_Ataka  (origin/master, origin/HEAD) deploy at 2013-08-06 01:03:02 +0900
| *     524de33 4135ebe 2013-08-04 kk_Ataka  (origin/source) 追加 AndroidアプリのIntentタイプ
{% endhighlight %}

グラフの左はdeploy用のブランチなのでおいといて、真ん中がソースを管理している `source` ブランチ、右が `oreore-jb` 。

#### 結論

- 毎回コピーはしなくてよくなった
- Jekyll Bootstrap の更新はチェックする必要がある
- コンフリクト解消作業は毎回やることに…？(量が増えたら毎回めんどい？)
- ログは自分がBootstrapから切り出した最小限のものだけにできた

というわけで、自分の中では一応納得。

しかし、これがいい方法なのかはわからんー。

後半へ続く。
