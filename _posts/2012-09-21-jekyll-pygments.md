---
layout: post
title: "Pygmentsを使ってJekyll内記事のコードハイライトを実現する"
description: ""
category: 
tags: [Python, Ruby, Jekyll]
---
{% include JB/setup %}

## あらすじ

Jekyllではデフォルトでコードにハイライトをつける事はできないようなので、Pygmentsという拡張を入れる。

## 環境

- Python 2.7.3 (2.6以上が必要)
  - easy_install

easy_installは[http://peak.telecommunity.com/dist/ez_setup.py](http://peak.telecommunity.com/dist/ez_setup.py)からDLし `$ (sudo) python ez_setup.py` でインストールする。

※ 後に以下のようなエラーが出るかもしれない。

> Liquid error: undefined method 'Py_IsInitialized' for RubyPython::Python:Module

これはRubyからPythonを呼びに行くRubypythonというライブラリの中で、libpython2.7.soというファイルを探しに行くが、見つからないとすぐあきらめるようなので？　`--enable-shared` オプションつけてのインストールが吉。

また、以下の様なエラーが出た場合、libpython2.7.so.1.0が見つからなくてpythonコマンドが実行できなくなった。

    $ python
    > python: error while loading shared libraries: libpython2.7.so.1.0: cannot open shared object file: No such file or directory
    
    $ ldd python
        linux-vdso.so.1 =>  (0x00007fff9cf94000)
        libpython2.7.so.1.0 => not found
        libpthread.so.0 => /lib64/libpthread.so.0 (0x000000343d600000)
        libdl.so.2 => /lib64/libdl.so.2 (0x000000343ce00000)
        libutil.so.1 => /lib64/libutil.so.1 (0x0000003440200000)
        libm.so.6 => /lib64/libm.so.6 (0x0000003665600000)
        libc.so.6 => /lib64/libc.so.6 (0x000000343d200000)
        /lib64/ld-linux-x86-64.so.2 (0x000000343ca00000)

/usr/libとか共有ライブラリが検索するように設定しているパスにシンボリックリンクを貼るか、LD_LIBRARY_PATHにパスを追加するか/etc/ld.so.conf.d/hogehoge.confを作ってパスを追加するかldconfigコマンドでパスを追加してからもう一回Pythonインストールする。

- [CentOS 5.5にvirtualenvを入れて、Python2.7とFlaskの環境を作ったよ！ - Bouldering & Com.](http://d.hatena.ne.jp/shrkw/20110124/1295851744)
- [共有ライブラリのコンパイル時に必要な検索パスを追加する方法 - ドキ！丸ごと！夏目だらけの水泳大会](http://d.hatena.ne.jp/natsumesouxx/20111126/1322339821)

## 参考サイト

* [ Windowsでpygmentsを使ってコードハイライト ](http://fingaholic.tumblr.com/post/20841800395/windows-pygments)
* [pygmentsが原因でjekyllが重くなってた](http://d.hatena.ne.jp/hokaccha/20120808/1344436656)
* [Swap out albino for pygments.rb](https://github.com/tombell/jekyll/commit/b2a1d61c0407d6612450fe7d90a9a1a397aaa28e)
* [tpw / css / syntax.css](https://github.com/mojombo/tpw/blob/master/css/syntax.css)

## 手順

いきなりeasy_install。

    $ easy_install Pygments
    Searching for Pygments
    Best match: pygments 1.5
    Processing pygments-1.5-py2.7.egg
    pygments 1.5 is already the active version in easy-install.pth
    Installing pygmentize-script.py script to C:\Pythons\Python27\Scripts
    Installing pygmentize.exe script to C:\Pythons\Python27\Scripts
    Installing pygmentize.exe.manifest script to C:\Pythons\Python27\Scripts
    
    Using c:\pythons\python27\lib\site-packages\pygments-1.5-py2.7.egg
    Processing dependencies for Pygments
    Finished processing dependencies for Pygments

以下、highlight hogeタグをテストするが、以下のようなエラーが表示されてしまった。

    Liquid error: Bad file descriptor

* [ Windowsでpygmentsを使ってコードハイライト ](http://fingaholic.tumblr.com/post/20841800395/windows-pygments " Windowsでpygmentsを使ってコードハイライト ")によると、

> C:\Ruby193\lib\ruby\gems\1.9.1\gems\albino-1.3.3\lib\albino.rbにパッチを当てる。

という事で `albino.rb` にパッチをあてると解決するらしい。

確かに、Bundlerでインストールしたgemの中にしっかりと `albino-1.3.3` がある。

……が。このalbinoはhighlightがあるたびにPygmentsを呼ぶようなのでこのまま使っていくと超重くなるらしい。

> 今現在gemでインストールできるjekyllはコードハイライトにalbinoっていう
> モジュールを使ってみるみたいで、こいつはハイライトするコードブロックが
> あるあるたびにpygamentsプロセスを立ち上げるらしく、それが原因で超重くなってたみたい。

それはできれば避けたい……。

## Jekyllの修正

[Swap out albino for pygments.rb](https://github.com/tombell/jekyll/commit/b2a1d61c0407d6612450fe7d90a9a1a397aaa28e)を見ながら `albino` を `pygments.rb` に差し替えてやる。

差し替えが完了したらpygment.rbとその依存gemを取りに行くためbundle update。

    $ bundle update
    Fetching source index for http://rubygems.org/
    Fetching source index for http://rubygems.org/
    Using RedCloth (4.2.9)
    Installing blankslate (3.1.2)
    Using fast-stemmer (1.0.1)
    Using classifier (1.3.3)
    Using directory_watcher (1.4.1)
    Installing ffi (1.0.11) with native extensions
    Installing kramdown (0.14.0)
    Using liquid (2.4.1)
    Using syntax (1.0.0)
    Installing maruku (0.6.1)
    Installing rubypython (0.5.3)
    Installing pygments.rb (0.2.13)
    Using jekyll (0.11.2)
    Using bundler (1.0.21)
    Your bundle is updated! Use `bundle show [gemname]` to see where a bundled gem is installed.

これでまずは

    {{ " {% highlight ruby " }} %}
     puts "hello world"
    {{ " {% endhighlight " }} %}

こういう表記が一応、liquid errorがでずに出力されるようになった。

{% highlight ruby %}
puts "hello world"
world.each do |w|
  w = "hoge"
end
{% endhighlight %}

## 色づけ

最後にハイライト。(記事上はもう色がついちゃってるんだけど、本来は全部黒いはず)これは[tpw / css / syntax.css](https://github.com/mojombo/tpw/blob/master/css/syntax.css)からCSSを持ってくれば良い。このsyntax.cssの内容を `JEKYLL_HOME\assets\themes\twitter\bootstrap\css\bootstrap.min.css` に追記する。

これでOK！
