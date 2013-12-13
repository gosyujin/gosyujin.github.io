---
layout: post
title: "Gitの.git/objectsの中身を追ってみる"
description: ""
category: 
tags: [Git]
---
{% include JB/setup %}

## あらすじ

この記事は [Git Advent Calendar 2013](http://qiita.com/advent-calendar/2013/git) の 14 日目の記事です。

- 12 日目: [@ton1517](https://twitter.com/ton1517)さん [gitのサブコマンドを自分で作る - ton-tech-ton](http://ton-up.net/technote/2013/12/12/git-subcommand)
- 13 日目: [@horimislime](https://twitter.com/horimislime)さん 記事ないお
- 14 日目: ここ
- 15 日目: [kyanro](http://qiita.com/kyanro@github)さん to be continued

とりあえず 12 日目へつなげておきますね。

最近 Subversion を使うことが多く、めっきり Git を使っていないので、復習として `.git/objects` の中身を追ってみた。

## 参考

- Pro Git 9章 [Git - Gitの内側](http://git-scm.com/book/ja/Git%E3%81%AE%E5%86%85%E5%81%B4)
- アリスとボブのGit入門レッスン Chapter 14
- [Dive into .git 日本語版 - SlideShare](http://www.google.co.jp/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&ved=0CDQQFjAB&url=http%3A%2F%2Fwww.slideshare.net%2Fnishio%2Fdive-into-git-13060995&ei=6veWUperFciAkQWEioCYBg&usg=AFQjCNFMnXUnpMosnZUk7pSxZBb9vEX-PQ&bvm=bv.57155469,d.dGI) 
- [見えないチカラ: 【翻訳】Gitをボトムアップから理解する](http://www.google.co.jp/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CCkQFjAA&url=http%3A%2F%2Fkeijinsonyaban.blogspot.com%2F2011%2F05%2Fgit.html&ei=-_eWUoJ1gYyTBc-LgPgE&usg=AFQjCNGwMB97m7YLFQppj0QjaPOrpz9Hzw&bvm=bv.57155469,d.dGI&cad=rja)

## 結論

とりあえず *add さえしていれば* 、ファイルを救える。

以下、 `.git/objects` 下で起こる事。

### git add したとき

- `$ git add` した瞬間、 add したファイルが `.git/objects` 下に生成される
  - Git で決められたヘッダ情報と、ファイル中身から算出される SHA1 でファイル構造が決定する
  - 具体的には頭 2 文字でディレクトリを作り、残りの文字でファイル名

{% highlight console %}
  SHA1 557db03de997c86a4a028e1ebd3a1ceb225be238
  ファイル .git/objects/55/7db03de997c86a4a028e1ebd3a1ceb225be238
{% endhighlight %}

- add したときに作られるこのファイルは `blob` オブジェクトと呼ばれる
  - `blob` オブジェクトは構造など持たない
  - 構造を管理するのは後述する他のオブジェクト
- このファイルは `$ git cat-file` で中身を確認できる(他のコマンドでもいける)
  - zlib 圧縮されているだけなので、自力で解凍して中身を確認することもできる

### git commit したとき

- `$ git commit` すると、 2 つ以上のファイルが `.git/objects` 下に生成される
  - `commit` オブジェクトと `tree` オブジェクト
- `commit` オブジェクトからは、以下のことがわかる
  - `tree` オブジェクト(コミットした時のファイル一覧)
  - 1つ前の `commit` オブジェクト
    - merge した場合など、複数の親を持つ場合は親の分だけ前のオブジェクトの情報を持つ
  - 作成した人、コミットした人
  - コミットログ

{% highlight console %}
$ git cat-file -p 047f8f6f81e483c5c3004cd80d5ecb81a7f64090
tree c3b5990fc81599cd04934d349b2c08a952f16c18               # コミットした時のファイル一覧
parent c11123084bd99af451ddf8eaad378b9a0a5ae695             # 1つ前の commit オブジェクト
author kk_Ataka <kk_ataka@example.com> 1385538273 +0000     # 作成した人
committer kk_Ataka <kk_ataka@example.com> 1385538273 +0000  # コミットした人

add test.txt                                                # コミットログ
{% endhighlight %}

- `tree` オブジェクトからは、以下のことがわかる
  - Git リポジトリルートからのファイル一覧
  - それらの SHA1
  - `blob` オブジェクトか `tree` オブジェクトか(ファイルかディレクトリか)
  - パーミッション
- `tree` オブジェクトは構造をもたない `blob` オブジェクトをまとめてくれる

{% highlight console %}
$ git cat-file -p c3b5990fc81599cd04934d349b2c08a952f16c18
100644 blob 557db03de997c86a4a028e1ebd3a1ceb225be238    README
040000 tree 85a2934a71f7385034f934f9ccc8c746b73d4f44    testdir
{% endhighlight %}

`tree` オブジェクト(ディレクトリ) は続く限り繰り返される。

### git rm したとき

- 何も起こらない
- コミットした時は、いつもどおり `commit` オブジェクトと `tree` オブジェクトができる
  - ただし、 `tree` オブジェクトからは rm したファイルが除外されている

ここから先、実際にごちゃごちゃ Git をいじってみて心で理解する。

## 実際にやってみる

### 前準備

test 用ディレクトリを作成。

{% highlight console %}
$ mkdir git_test
$ cd git_test/
{% endhighlight %}

ここで `$ git init` 。 `.git` ディレクトリが作成され、通常はここにソースなどを置いていく。

{% highlight console %}
$ git init
Initialized empty Git repository in /home/vagrant/git_test/.git/
$ ls -la
total 12
drwxrwxr-x 3 vagrant vagrant 4096 Nov 26 03:08 .
drwx------ 4 vagrant vagrant 4096 Nov 26 03:08 ..
drwxrwxr-x 7 vagrant vagrant 4096 Nov 26 03:08 .git
{% endhighlight %}

今回は、さらに深く進んでいく。

{% highlight console %}
$ cd .git
$ ls -la
total 40
drwxrwxr-x 7 vagrant vagrant 4096 Nov 26 03:08 .
drwxrwxr-x 3 vagrant vagrant 4096 Nov 26 03:08 ..
drwxrwxr-x 2 vagrant vagrant 4096 Nov 26 03:08 branches
-rw-rw-r-- 1 vagrant vagrant   92 Nov 26 03:08 config
-rw-rw-r-- 1 vagrant vagrant   73 Nov 26 03:08 description
-rw-rw-r-- 1 vagrant vagrant   23 Nov 26 03:08 HEAD
drwxrwxr-x 2 vagrant vagrant 4096 Nov 26 03:08 hooks
drwxrwxr-x 2 vagrant vagrant 4096 Nov 26 03:08 info
drwxrwxr-x 4 vagrant vagrant 4096 Nov 26 03:08 objects
drwxrwxr-x 4 vagrant vagrant 4096 Nov 26 03:08 refs
{% endhighlight %}

各ファイルの役割はこんな感じ。全てはわかっていない。

ファイル     |役割
-------------|----
branches/    |新しいバージョンでは使用しない
config       |リポジトリ固有の設定
description  |GitWebプログラムで使用する
HEAD         |現在チェックアウトされているブランチ
index        |Gitのステージングエリアの情報を保管
hooks/       |フックスクリプト集
info/        |`.gitignore` に記述したくない無視パターンをを保持
objects/     |Gitで管理しているファイルの格納場所
refs/        |ブランチ内のコミットオブジェクトをさすポインタ

今回は、この `.git` ディレクトリの中でさらに `git init` して `.git` ディレクトリ内の変更を管理できるようにした。とりあえず全部 add 。

{% highlight console %}
$ git init
Initialized empty Git repository in /home/vagrant/git_test/.git/.git/
$ git add branches/ config description HEAD hooks/ info/ objects/ refs/
$ git commit -m "fitst commit"
{% endhighlight %}

まだ変更点はなし。

{% highlight console %}
$ git status
# On branch master
nothing to commit (working directory clean)
{% endhighlight %}

### git add でファイルを追加

#### 操作手順

Git で管理するファイルは `.git/objects` ディレクトリ下で管理される。

何かファイルを作ってみる。

{% highlight console %}
$ echo "Hello World" >> README
$ cat README
Hello World
{% endhighlight %}

作っただけでは、 `.git` ディレクトリに変化は起きない。

{% highlight console %}
$ cd .git
$ git status
# On branch master
nothing to commit (working directory clean)
{% endhighlight %}

ここで `$ git add` してみる。

{% highlight console %}
$ git add README
$ git status
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#       new file:   README
#
{% endhighlight %}

`.git/objects` 下が何か変わっている。(indexも変わっているが、今はスルー)

{% highlight console %}
$ cd .git
$ git status
# On branch master
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#       index
#       objects/
{% endhighlight %}

ファイルがひとつできてる。

{% highlight console %}
$ find ./objects/ -type f
./objects/55/7db03de997c86a4a028e1ebd3a1ceb225be238
{% endhighlight %}

これは、今 add した README ファイルの SHA1 ハッシュ。

  - はじめの 2 文字でディレクトリを作り、残り 38 文字でファイル名
  - なんでこういう分けかたになっているかは調べ切れなかった

`$ git cat-file` コマンドでこのハッシュからファイルの中身を確認できる。(中身は　`$ git show` でも見ることができる)

{% highlight console %}
$ git cat-file -t 557db03de997c86a4a028e1ebd3a1ceb225be238
blob # type
$ git cat-file -s 557db03de997c86a4a028e1ebd3a1ceb225be238
12 # size
$ git cat-file -p 557db03de997c86a4a028e1ebd3a1ceb225be238
Hello World # 中身
{% endhighlight %}

また、Git のオブジェクトは zlib 圧縮されているファイルなので、自力で展開することもできる。 {% ref ただし、validなフォーマットで圧縮はされていないのでgunzipなどでは展開できないらしい %}

{% highlight console %}
$ cd .git/objects/55
$ ls
7db03de997c86a4a028e1ebd3a1ceb225be238
$ irb
{% endhighlight %}

{% highlight ruby %}
irb(main):001:0> require 'zlib'
=> true
irb(main):002:0> f = File.open('7db03de997c86a4a028e1ebd3a1ceb225be238', 'r')
=> #<File:7db03de997c86a4a028e1ebd3a1ceb225be238>
irb(main):003:0> Zlib::Inflate.inflate(f.read)
=> "blob 12\x00Hello World\n"
{% endhighlight %}

ヘッダ+ファイルの中身が確認できた。 `blob` オブジェクトは 「 `"blob" + スペース + ファイルサイズ + "\x00" (NUL 制御コード) + 中身` 」というという構造らしいので、これで OK のようだ。

ここで出てきた `blob` っていうのは、 Git のオブジェクトの種類の1つ。全部で4つある。

- blob
- tree
- commit
- tag

### git commit でファイルコミット

いよいよコミットしてみる。

#### 操作手順

{% highlight console %}
$ git commit -m "README first commit"
[master (root-commit) c111230] README first commit
 1 files changed, 1 insertions(+), 0 deletions(-)
 create mode 100644 README
{% endhighlight %}

一心不乱に `.git/objects` へ。(それ以外にもいろいろできてる)

{% highlight console %}
$ cd .git/
$ find ./objects/ -type f
./objects/55/7db03de997c86a4a028e1ebd3a1ceb225be238
./objects/67/dc4302383b2715f4e0b8c41840eb05b1873697
./objects/c1/1123084bd99af451ddf8eaad378b9a0a5ae695
{% endhighlight %}

何か新しいオブジェクトが 2 個( `67dc` と `c111` )増えてる。

中身を見ると、さっき出てきた 4 つのオブジェクトの中の `commit` オブジェクトと、 `tree` オブジェクトだ。

{% highlight console %}
$ git cat-file -t c11123084bd99af451ddf8eaad378b9a0a5ae695
commit
$ git cat-file -s c11123084bd99af451ddf8eaad378b9a0a5ae695
182
$ git cat-file -p c11123084bd99af451ddf8eaad378b9a0a5ae695
tree 67dc4302383b2715f4e0b8c41840eb05b1873697
author kk_Ataka <kk_ataka@example.com> 1385505619 +0000
committer kk_Ataka <kk_ataka@example.com> 1385505619 +0000

README first commit
{% endhighlight %}

この `commit` オブジェクトからは以下のようなことがわかる。

- `tree` オブジェクトの SHA1
- 作成した人、コミットした人
- コミットログ

{% highlight console %}
$ git cat-file -t 67dc4302383b2715f4e0b8c41840eb05b1873697
tree
$ git cat-file -s 67dc4302383b2715f4e0b8c41840eb05b1873697
34
$ git cat-file -p 67dc4302383b2715f4e0b8c41840eb05b1873697
100644 blob 557db03de997c86a4a028e1ebd3a1ceb225be238    README
{% endhighlight %}

この `tree` オブジェクトからは以下のようなことがわかる。

- Git リポジトリルートからのファイル一覧
- SHA1
- 種類
- パーミッション

※ `tree` オブジェクトは `$ git ls-tree` でも確認できる。

次に、コミットログを増やしたいのと、もうちょっと複雑にしたいので、以下のようにディレクトリを作ってその中にファイルを作る。

1. `testdir` ディレクトリを作る
1. その下に `test.txt` を作る

{% highlight console %}
$ mkdir testdir
$ echo "test file" >> testdir/test.txt
$ git add testdir/test.txt
$ git commit -m "add test.txt"
[master 047f8f6] add test.txt
 1 files changed, 1 insertions(+), 0 deletions(-)
 create mode 100644 testdir/test.txt
{% endhighlight %}

オブジェクト。

{% highlight console %}
$ find .git/objects/ -type f
.git/objects/04/7f8f6f81e483c5c3004cd80d5ecb81a7f64090
.git/objects/55/7db03de997c86a4a028e1ebd3a1ceb225be238
.git/objects/c3/b5990fc81599cd04934d349b2c08a952f16c18
.git/objects/67/dc4302383b2715f4e0b8c41840eb05b1873697
.git/objects/85/a2934a71f7385034f934f9ccc8c746b73d4f44
.git/objects/c1/1123084bd99af451ddf8eaad378b9a0a5ae695
.git/objects/16/b14f5da9e2fcd6f3f38cc9e584cef2f3c90ebe
{% endhighlight %}

`047f` `c3b5` `85a2` `16b1` が増えた。

中身を確認すると、さっきまでとは趣きが違うところがいくつかある。

{% highlight console %}
$ git cat-file -t 047f8f6f81e483c5c3004cd80d5ecb81a7f64090
commit
$ git cat-file -p 047f8f6f81e483c5c3004cd80d5ecb81a7f64090
tree c3b5990fc81599cd04934d349b2c08a952f16c18
parent c11123084bd99af451ddf8eaad378b9a0a5ae695
author kk_Ataka <kk_ataka@example.com> 1385508273 +0000
committer kk_Ataka <kk_ataka@example.com> 1385508273 +0000

add test.txt
{% endhighlight %}

`parent` として、このコミットの親がわかるようになってる。

{% highlight console %}
$ git cat-file -t c3b5990fc81599cd04934d349b2c08a952f16c18
tree
$ git cat-file -p c3b5990fc81599cd04934d349b2c08a952f16c18
100644 blob 557db03de997c86a4a028e1ebd3a1ceb225be238    README
040000 tree 85a2934a71f7385034f934f9ccc8c746b73d4f44    testdir
$ git cat-file -t 85a2934a71f7385034f934f9ccc8c746b73d4f44
tree
$ git cat-file -p 85a2934a71f7385034f934f9ccc8c746b73d4f44
100644 blob 16b14f5da9e2fcd6f3f38cc9e584cef2f3c90ebe    test.txt
{% endhighlight %}

`tree` オブジェクトとして、 testdir が追加されてる。

{% highlight console %}
$ git cat-file -t 16b14f5da9e2fcd6f3f38cc9e584cef2f3c90ebe
blob
$ git cat-file -p 16b14f5da9e2fcd6f3f38cc9e584cef2f3c90ebe
test file
{% endhighlight %}

`blob` はファイルの内容なのでとりあえず特筆する点なし。

### 親が複数あるとき

merge したときなど、親を複数持つときもあるんじゃなかろうか。

ということで試してみる。まずは `test` ブランチを新しく作成し、ファイルを適当に作ってコミット。

{% highlight console %}
$ git checkout -b test
Switched to a new branch 'test'
$ echo "test branch" >> README
$ git add README
$ git commit -m "test branch"
[test 38c9e30] test branch
 1 files changed, 1 insertions(+), 0 deletions(-)
{% endhighlight %}

リポジトリのグラフを見てみる。(「g」コマンドは `$ git log --graph` に色々手を加えたもののエイリアス)

{% highlight console %}
$ git g
* 38c9e30 f60ab37 2013-11-28 kk_Ataka  (HEAD, test) test branch
* c2333bd 1a53959 2013-11-28 kk_Ataka  (master) master branch
* 047f8f6 c3b5990 2013-11-27 kk_Ataka  add test.txt
* c111230 67dc430 2013-11-27 kk_Ataka  README first commit
{% endhighlight %}

では、 `master` ブランチに戻り、 `master` ブランチに `test` ブランチをマージ。

{% highlight console %}
$ git checkout master
Switched to branch 'master'
$ git merge --no-ff test
Merge made by recursive.
 README |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)
{% endhighlight %}

改めてグラフ。現在の `master` ブランチ(= `b870b7` )はさっきまで `master` だったもの(= `c2333` )と、 `test` ブランチのもの(= `38c9e3` )が親になっているように見える。

{% highlight console %}
$ git g
*   b870b73 f60ab37 2013-11-28 kk_Ataka  (HEAD, master) Merge branch 'test'
|\
| * 38c9e30 f60ab37 2013-11-28 kk_Ataka  (test) test branch
|/
* c2333bd 1a53959 2013-11-28 kk_Ataka  master branch
* 047f8f6 c3b5990 2013-11-27 kk_Ataka  add test.txt
* c111230 67dc430 2013-11-27 kk_Ataka  README first commit
{% endhighlight %}

ということで確認。まずは今の場所の `commit` オブジェクトのハッシュを改めて取得。

{% highlight console %}
$ git rev-parse HEAD
b870b7313d2fcfda308204b12d5534c5ccac95cb
{% endhighlight %}

`commit` オブジェクトの中身を見てみる。

{% highlight console %}
$ git cat-file -p b870b7313d2fcfda30
tree f60ab375c7a4408527f814167a0dc9285f1cbcca
parent c2333bd833a82784ca06a960890a739d43f32c5e
parent 38c9e304d897e71c479bf78fe4def6bcb3ad1b72
author kk_Ataka <kk_ataka@example.com> 1385633710 +0000
committer kk_Ataka <kk_ataka@example.com> 1385633710 +0000

Merge branch 'test'
{% endhighlight %}

2つある！

### リポジトリからファイルを消したとき

消したらどうなるんだろう。

まずは適当なファイルを追加する。

{% highlight console %}
$ echo "hello" >> hello.txt
$ git add hello.txt
$ find .git/objects/ -type f
.git/objects/ce/013625030ba8dba906f756967f9e9ca394464a
{% endhighlight %}

add したらひとつできてる。 commit したら `commit` オブジェクトと `tree` オブジェクトのふたつができて、計みっつになるはず。

{% highlight console %}
$ git commit -m "first commit"
(略)
$ find .git/objects/ -type f
.git/objects/aa/a96ced2d9a1c8e72c56b253a0e2fe78393feb7    # tree
.git/objects/30/5fd379be250870d1e55584241637dacb44ec82    # commit
.git/objects/ce/013625030ba8dba906f756967f9e9ca394464a    # blob  hello.txt
$ git status
# On branch master
nothing to commit (working directory clean)
{% endhighlight %}

なってる。

次に、ファイルを削除。

{% highlight console %}
$ git rm hello.txt
rm 'hello.txt'
$ git status
# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       deleted:    hello.txt
#
$ find .git/objects/ -type f
.git/objects/aa/a96ced2d9a1c8e72c56b253a0e2fe78393feb7
.git/objects/30/5fd379be250870d1e55584241637dacb44ec82
.git/objects/ce/013625030ba8dba906f756967f9e9ca394464a
{% endhighlight %}

削除しただけだと変わらないか。

コミットするとどうか。

{% highlight console %}
$ git commit -m "delete hello.txt"
(略)
$ find .git/objects/ -type f
.git/objects/aa/a96ced2d9a1c8e72c56b253a0e2fe78393feb7    # tree
.git/objects/30/5fd379be250870d1e55584241637dacb44ec82    # commit
.git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904
.git/objects/ce/013625030ba8dba906f756967f9e9ca394464a    # blob  hello.txt
.git/objects/72/e0a285935e33b62877ecb809fd4b6fac6d416d
{% endhighlight %}

新たにふたつできてる。 `commit` オブジェクトと `tree` オブジェクトか。

{% highlight console %}
$ git cat-file -t 72e0
commit
$ git cat-file -p 72e0
tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904
parent 305fd379be250870d1e55584241637dacb44ec82
author kk_Ataka <kk_ataka@example.com> 1386303674 +0000
committer kk_Ataka <kk_ataka@example.com> 1386303674 +0000

delete hello.txt
{% endhighlight %}

{% highlight console %}
$ git cat-file -t 4b82
tree
$ git cat-file -p 4b82
$
{% endhighlight %}

あ、 `tree` オブジェクトのリストから消えるだけか。

というか、よく考えたら `git rm` したからってオブジェクトが消えたらチェックアウトで戻せなくなるな。

## 課題

まだよくわかってない。

1. `.git/index` がどうなっているのか。
  - [git indexの中身 - 西尾泰和のはてなダイアリー](http://d.hatena.ne.jp/nishiohirokazu/20120523/1337766796)
1. `.git/objects` 下の info と pack
  - `$ git gc` コマンドを使って整理した場合に複数のオブジェクトのファイルを pack ファイルに圧縮する
1. オブジェクトが勝手に消えるときはあるのか。
  - detached HEAD 状態になったコミットは gc とか走ると消えそうなんだけど…

## メモ

今回使った色々なコマンド。

### cat-file

{% highlight console %}
$ git cat-file -p HEAD # HEAD = commit オブジェクト
tree c3b5990fc81599cd04934d349b2c08a952f16c18
parent c11123084bd99af451ddf8eaad378b9a0a5ae695
author kk_Ataka <kk_ataka@example.com> 1385508273 +0000
committer kk_Ataka <kk_ataka@example.com> 1385508273 +0000

add test.txt

$ git cat-file -p c3b5990 # tree オブジェクト
100644 blob 557db03de997c86a4a028e1ebd3a1ceb225be238    README
040000 tree 85a2934a71f7385034f934f9ccc8c746b73d4f44    testdir
{% endhighlight %}

### hash-object

{% highlight console %}
$ git hash-object README # blob オブジェクト
557db03de997c86a4a028e1ebd3a1ceb225be238
{% endhighlight %}

### rev-parse

{% highlight console %}
$ git rev-parse HEAD
047f8f6f81e483c5c3004cd80d5ecb81a7f64090
{% endhighlight %}

### ls-tree

{% highlight console %}
$ git ls-tree HEAD
100644 blob 557db03de997c86a4a028e1ebd3a1ceb225be238    README
040000 tree 85a2934a71f7385034f934f9ccc8c746b73d4f44    testdir
$ git ls-tree 85a293
100644 blob 16b14f5da9e2fcd6f3f38cc9e584cef2f3c90ebe    test.txt
{% endhighlight %}

### ls-files

{% highlight console %}
$ git ls-files --stage
100644 d7f3c505ac2e28aaac5fa9210adb1115b8c57d72 0       README
100644 9daeafb9864cf43055ae93beb0afd6c7d144bfa4 0       new.txt
100644 16b14f5da9e2fcd6f3f38cc9e584cef2f3c90ebe 0       testdir/test.txt
{% endhighlight %}

### show 

{% highlight console %}
$ git show d7f3c505ac2e28a
Hello World
master branch
test branch

$ git show HEAD
commit b870b7313d2fcfda308204b12d5534c5ccac95cb
Merge: c2333bd 38c9e30
Author: kk_Ataka <kk_ataka@example.com>
Date:   Thu Nov 28 20:15:10 2013 +0000

    Merge branch 'test'
{% endhighlight %}
