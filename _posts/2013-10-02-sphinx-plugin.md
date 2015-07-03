---
layout: post
title: "Sphinxのプラグインの作り方を学ぶ"
description: ""
category: 
tags: [Sphinx]
---

## あらすじ

Sphinx のタグを拡張してみたい。具体的には打ち消し記法がほしい。

という事で Sphinx 拡張に手を出す。

ただし、 Python は Hello World くらい…。

## 参考サイト

- [Sphinx拡張 Sphinx v1.0.6 documentation](http://sphinx-users.jp/doc10/extensions.html)
- [Sphinx拡張 Sphinx 1.2b1 documentation](http://docs.sphinx-users.jp/extensions.html)

打ち消し線は既に実例があったので、これを写経する方針で。

- [Sphinxで打ち消し線を使う - TIM Labs](http://labs.timedia.co.jp/2012/04/sphinx.html)

## 環境

- Windows XP
- Python 2.7.3
- Sphinx 1.1.3

と、

- Windows 7
- Python 2.7.4
- Sphinx 1.2b.1

## Sphinxの拡張の仕方

Sphinx 1.1.3 時に調べていた感じでは、拡張には大きく3通りある模様。

- 新出力形式対応やパース時のアクションサポート(ビルダー追加で実現)
- reSTのマークアップ拡張
- いろいろなフックポイントで諸処理を記述

今回はreSTのマークアップ拡張が該当するかな。

拡張は基本的にPythonで記述する。(setup関数を呼び出す)

作成した拡張機能は `conf.py` の中で読み込むように設定を変更する。

以下、打ち消し線を導入しつつ何してるのか写経してみる。

## 作成

### conf.py(修正)

{% highlight python %}
sys.path.append(os.path.abspath('exts'))
extensions += ['sphinxcontrib_roles']

# configuration case.1: define roles as list (define only roles)
roles = ['strike', 'red']

# configuration case.2: define roles as dict (define roles and its style on HTML)
roles = {'strike': "text-decoration: line-through;", 'red': "color: red;" }
{% endhighlight %}

- . [自分自身の拡張機能はどこに置くべき？](http://docs.sphinx-users.jp/extensions.html#where-to-put-your-own-extensions) という事で、プラグインファイルを置く場所を `conf.py` の `sys.path` に追加する
- `extensions`
  - 使用したいSphinx拡張モジュールを格納する(配列)
  - 絶対パスで指定

rolesは **設定値** 。これから作る sphinxcontrib_roles.py で定義する。

### sphinxcontrib_roles.py(新規)

一番はじめは `setup(app)` 関数。

{% highlight python %}
def setup(app):
    app.add_config_value('roles', [], 'html')
    app.connect("builder-inited", on_builder_inited)
    app.connect("html-collect-pages", on_html_collect_pages)
    app.connect("html-page-context", html_page_context)
{% endhighlight %}

- `app.add_config_value(name, default, rebuild)`
  - 新しい設定値 `"roles"` を追加する(名前衝突を避けるため、 `name` **には拡張機能名を入れなければならない** )
  - `default` はデフォルト値
  - `rebuild` はリビルドする時の設定。 `"html"` の場合は出力が `html` だった時リビルドされる。
- `sphinx.connect(event, collback)`
  - `event` が発行された時に呼ばれる `collback` を登録。

eventは以下のようなものがある。

event|説明
-----|----
builder-inited|ビルダーオブジェクト作成時に発行
html-collect-pages|
html-page-context|テンプレートを使用してレンダリングを行う時に発行

他にも…。

event|説明
-----|----
source-read|ソースファイルが読み込まれる時に発行
build-finished|ビルド完了時、例外としてビルドが例外を投げた時も発行

html-collect-pagesってなんだろう？

できあがったのはこう。(というか、まんま)

{% highlight python %}
# -*- coding: utf-8 -*-
import os
from docutils.parsers.rst import roles

def _define_role(name):
#    print "sphinxcontrib_roles#_define_role name:", name
    #=> strike, red
    base_role = roles.generic_custom_role
    role = roles.CustomRole(name, base_role, {'class': [name]}, [])
    roles.register_local_role(name, role)

def on_builder_inited(app):
#    print "sphinxcontrib_roles#onbuilder_inited item", app.builder.config.roles.items()
    #=> [('strike', 'text-decoration: line-through;'), ('red', 'color: red;')]
    for name in app.builder.config.roles:
        _define_role(name)

def on_html_collect_pages(app):
    if isinstance(app.builder.config.roles, dict) and app.builder.config.roles:
        cssdir = os.path.join(app.builder.outdir, '_static')
        cssfile = os.path.join(cssdir, 'roles.css')
        if not os.path.exists(cssdir):
            os.makedirs(cssdir)

        fd = open(cssfile, 'wt')
#        print "sphinxcontrib_roles#on_html_collect_pages write cssfile", cssfile
        #=> C:\work\sphinx\_build\html\_static\roles.css
        for name, style in app.builder.config.roles.items():
            fd.write("span.%s { %s }\n" % (name, style))
        fd.close()
    return ()

def html_page_context(app, pagename, templatename, context, doctree):
    if isinstance(app.builder.config.roles, dict) and app.builder.config.roles:
        if 'css_files' in context:
#            print "sphinxcontrib_roles#html_page_context pagename", pagename
            context['css_files'].append('_static/roles.css')

def setup(app):
    print "sphinxcontrib_roles#setup"
    app.add_config_value('roles', [], 'html')
    app.connect("builder-inited", on_builder_inited)
    app.connect("html-collect-pages", on_html_collect_pages)
    app.connect("html-page-context", html_page_context)
{% endhighlight %}

`index.rst` を作成。

{% highlight rst %}
.. project documentation master file, created by
   sphinx-quickstart on Thu Aug 22 18:15:35 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to project's documentation!
===================================

Contents:

.. toctree::
   :maxdepth: 2

- :strike:`thids ahas`
- :red:`red`


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
{% endhighlight %}

ビルドもしてみる。

{% highlight python %}
$ make html
Making output directory...
Running Sphinx v1.2b1
sphinxcontrib_roles#setup
loading pickled environment... not yet created
sphinxcontrib_roles#onbuilder_inited item [('strike', 'text-decoration: line-through;'), ('red', 'color: red;')]
sphinxcontrib_roles#_define_role name: strike
sphinxcontrib_roles#_define_role name: red
building [html]: targets for 1 source files that are out of date
updating environment: 1 added, 0 changed, 0 removed
reading sources... [100%] index

looking for now-outdated files... none found
pickling environment... done
checking consistency... done
preparing documents... done
writing output... [100%] index
sphinxcontrib_roles#html_page_context pagename index

writing additional files...sphinxcontrib_roles#on_html_collect_pages write cssfile C:\work\sphinx\_build\html\_static\roles.css
 genindexsphinxcontrib_roles#html_page_context pagename genindex
 searchsphinxcontrib_roles#html_page_context pagename search

copying static files... done
dumping search index... done
dumping object inventory... done
build succeeded.

Build finished. The HTML pages are in _build/html.
{% endhighlight %}

生成されたソースの抜粋。

{% highlight html %}
<p>Contents:</p>
<div class="toctree-wrapper compound">
<ul class="simple">
</ul>
</div>
<ul class="simple">
<li><span class="strike">thids ahas</span></li>
<li><span class="red">red</span></li>
</ul>
</div>
{% endhighlight %}

とりあえずこんな感じ。
