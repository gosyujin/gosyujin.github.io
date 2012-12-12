---
layout: post
title: "git-svnインストールからgit svn dcommit完了までの手順"
description: ""
category: 
tags: [Git,Subversion]
---
{% include JB/setup %}

## あらすじ

CentOSのインストール時に入れたGitにはgit-svnが入っていない(？)ので、一から入れようとしたが、ネットに繋がっていない環境だと結構依存とかがめんどくさかったのでメモ。

## 環境

- CentOS 6.2
- Git 1.7.1
  - git は入っているが、git svnは実行できない
{% highlight console %}
$ git svn 
git: 'svn' is not a git command. See 'git --help'.
{% endhighlight %}
- svn 1.6.11 (r934486)
- ネットにつながっていないぼっち環境

yumとかで入れられると一発っぽいんだけどなー。

## 手順

まずは、git-svnのrpmをDLしてくる。

- [RPM resource git-svn](http://rpmfind.net/linux/rpm2html/search.php?query=git-svn)

インストールしたいPCに持ってきて、rpmコマンド。 `perl(SVN::Core)` と、 `perl(Term:ReadKey)` がないと言われる。

{% highlight console %}
# rpm -ivh git-svn-1.7.1-2.el6_0.1.noarch.rpm
警告: git-svn-1.7.1-2.el6_0.1.noarch.rpm: ヘッダ V3 RSA/SHA256 Signature, key ID c105b9de: NOKEY
エラー: 依存性の欠如:
        perl(SVN::Core) は git-svn-1.7.1-2.el6_0.1.noarch に必要とされています
        perl(Term::ReadKey) は git-svn-1.7.1-2.el6_0.1.noarch に必要とされています
{% endhighlight %}

### perl(SVN::Core)

SVN::Coreは `subversion-perl` というパッケージから入れられるよう。

- [SVN::Core は subversion-perl に入っている - init9の日記](http://d.hatena.ne.jp/init9/20080709/1215571342)
- [RPM CentOS 5 subversion-perl 1.6.11 i386 rpm](http://rpm.pbone.net/index.php3/stat/4/idpl/18080007/dir/centos_5/com/subversion-perl-1.6.11-10.el5_8.i386.rpm.html)

subversion-perlをDLしてインストール。

{% highlight console %}
# rpm -ivh subversion-perl-1.6.11-7.el6.i686.rpm
警告: subversion-perl-1.6.11-7.el6.i686.rpm: ヘッダ V3 RSA/SHA1 Signature, key ID c105b9de: NOKEY
エラー: 依存性の欠如:
        subversion = 1.6.11-7.el6 は subversion-perl-1.6.11-7.el6.i686 に必要と されています
{% endhighlight %}

あれ？Subversion入ってるのに見つけられてない？Subversionを入れ直してみる？

{% highlight console %}
# rpm -ivh subversion-1.6.11-7.el6.i686.rpm
警告: subversion-1.6.11-7.el6.i686.rpm: ヘッダ V3 RSA/SHA1 Signature, key ID c105b9de: NOKEY
準備中...                ########################################### [100%]
        ファイル /usr/bin/svnserve (パッケージ subversion-1.6.11-7.el6.i686 から) は、パッケージ subversion-1.6.11-2.el6_1.4.i686 からのファイルと競合しています。
略
{% endhighlight %}

やっぱインストール済み…1.6.11-2.el6_1_4…だと…。このrelease番号？ってsvn --versionじゃ確認できないの？

{% highlight console %}
# svn --version
svn, バージョン 1.6.11 (r934486)
   コンパイル日時: Sep 27 2011, 14:59:40

   Copyright (C) 2000-2009 CollabNet.
   Subversion is open source software, see http://subversion.tigris.org/
   This product includes software developed by CollabNet (http://www.Collab.Net/).

   以下のリポジトリアクセス (RA) モジュールが利用できます:

   * ra_neon : Neon を利用して WebDAV (DeltaV) プロトコルでリポジトリにアクセスするモジュール。
     - 'http' スキームを操作します
       - 'https' スキームを操作します
       * ra_svn : svn ネットワークプロトコルを使ってリポジトリにアクセスするモジュール 。
         - Cyrus SASL 認証を併用
   - 'svn' スキームを操作します
   * ra_local : ローカルディスク上のリポジトリにアクセスするモジュール。
     - 'file' スキームを操作します
{% endhighlight %}

色々探して、とりあえず1.6.11-2.el6_1_4のsubversion-perlを見つけた。

- [RPM Scientific Linux 6 subversion-perl 1.6.11 i686 rpm](http://rpm.pbone.net/index.php3/stat/4/idpl/16844891/dir/scientific_linux_6/com/subversion-perl-1.6.11-2.el6_1.4.i686.rpm.html)

再チャレンジ。

{% highlight console %}
# rpm -ivh subversion-perl-1.6.11-2.el6_1.4.i686.rpm
警告: subversion-perl-1.6.11-2.el6_1.4.i686.rpm: ヘッダ V4 DSA/SHA1 Signature, key ID 192a7d7d: NOKEY
準備中...                ########################################### [100%]
   1:subversion-perl        ########################################### [100%]
{% endhighlight %}

入ったー。で、依存は一個消えた。

{% highlight console %}
# rpm -ivh git-svn-1.7.1-2.el6_0.1.noarch.rpm
警告: git-svn-1.7.1-2.el6_0.1.noarch.rpm: ヘッダ V3 RSA/SHA256 Signature, key ID c105b9de: NOKEY
エラー: 依存性の欠如:
        perl(Term::ReadKey) は git-svn-1.7.1-2.el6_0.1.noarch に必要とされています
{% endhighlight %}

### perl(Term::ReadKey)

特にバージョンの指定がないんだけど、とりあえず後ろ(el6)は合わせてみた。elってRHELのELなのかな…？

- [泡史朗の戯れの日々: RPMパッケージの命名規則](http://blogger.horisawa.info/2012/03/rpm.html)
- [perl-TermReadKey-2.30-13.el6.i686.rpm CentOS 6 (RHEL 6) Download](http://pkgs.org/centos-6-rhel-6/centos-rhel-i386/perl-TermReadKey-2.30-13.el6.i686.rpm.html)

{% highlight console %}
[root@tpc6102 share]# rpm -ivh perl-TermReadKey-2.30-13.el6.i686.rpm
警告: perl-TermReadKey-2.30-13.el6.i686.rpm: ヘッダ V3 RSA/SHA1 Signature, key ID c105b9de: NOKEY
準備中...                ########################################### [100%]
   1:perl-TermReadKey       ########################################### [100%]
{% endhighlight %}

いった！

で、git-svnも入った！

## 動作確認

コミットしようとしたらエラーが。

{% highlight console %}
$ git svn dcommit
Committing to svn://xxxxxxx/repo/trunk ...
Authentication realm: <svn://xxxxxxx:3690> xxxxxxxx-...

(gnome-ssh-askpass:20438): Gtk-WARNING **: cannot open display:
Use of uninitialized value $password in substitution (s///) at /usr/libexec/git-core/git-svn line 3979.
error: git-svn died of signal 11
{% endhighlight %}

GUIでLinuxをインストールしている場合、 `gnome-ssh-askpass` を使ってパスワード認証をかますようにパスが通っており、今はtelnetなどでつないでいる(=認証画面出したいのに画面ない)のが問題みたい。

- [pm/DVCS - Yuna's Technical Guide](http://ultimania.org/trac/yuna/wiki/pm/DVCS#git%E3%81%A7%E8%AA%8D%E8%A8%BC%E3%82%A8%E3%83%A9%E3%83%BC)

確かにいる。

{% highlight console %}
$ echo $SSH_ASKPASS
/usr/libexec/openssh/gnome-ssh-askpass
{% endhighlight %}

これを空にしてやればよい。

{% highlight console %}
$ unset SSH_ASKPASS
$ echo $SSH_ASKPASS

{% endhighlight %}

で、dcommit！

{% highlight console %}
$ git svn dcommit
Committing to svn://xxxxxxxx/repo/trunk ...
Authentication realm: <svn://xxxxxxxx:3690> xxxxxxxxxxx.....
Password for 'kk_Ataka':
{% endhighlight %}

パスワード認証もOK。

{% highlight console %}
M       memo/test.txt
略
{% endhighlight %}

コミットされた！
