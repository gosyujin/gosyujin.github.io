---
layout: post
title: "Sphinxをインストールしようとしたら全然関係ないproxy周りでハマった話"
description: ""
category: 
tags: [Python, Sphinx]
old_url: http://d.hatena.ne.jp/kk_Ataka/20130821/1377092315
---

## あらすじ

Sphinx を導入しようとして Python周りの環境を整えていたら easy_install がやたら失敗したりして困った。

## 環境

- Windows 7
- Python 2.7

## Python インストール

…は、以前入れるだけ入れていた 2.7 があったので割愛。

Sphinx-Users.jp のインストール手順では 2.6 が使われていたので、 2.7 でも大丈夫そう。

環境変数 `PATH` に以下のパスを追加。

- `C:\Python27`
  - Pythonのコマンドが含まれるフォルダ
- `C:\Python27\Scripts`
  - 次に説明するeasy_installコマンドや、Sphinxのコマンドが格納されるフォルダ

## easy_install インストール(distribute_setup.py)

Ruby でいうところの Bundler のようなもの？

- [setuptools - 清水川Web](http://www.freia.jp/taka/docs/pyhack4/setuptools/index.html)

setuptoolsの互換パッケージを導入。

- [python-distribute.org](http://python-distribute.org/) から `distribute_setup.py` をDLし実行。

```console
$ python distribute_setup.py
Downloading http://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz
Extracting in c:\users\USER\appdata\local\temp\tmp00_lbf
Now working in c:\users\USER\appdata\local\temp\tmp00_lbf\distribute-0.6.49
Installing Distribute
Before install bootstrap.
Scanning installed packages
Setuptools installation detected at c:\python27\lib\site-packages
Non-egg installation
Moving elements out of the way...
Already patched.
c:\python27\lib\site-packages\setuptools-0.6c11-py2.7.egg-info already patched.
running install
running bdist_egg
running egg_info

(略)

After install bootstrap.
C:\Python27\Lib\site-packages\setuptools-0.6c11-py2.7.egg-info already exists
```

これで、 `PYTHON/Scripts` 下に `easy_install` コマンドが入る。

### 実行時に urllib2.URLError エラー

ところで、初回に distribute_setup.py を実行するとこんなエラーになった。(原因はわかってない)

状況はこんな感じ。

- proxyが必要な環境
- 環境変数 `HTTP_PROXY` は設定している

```console
$ echo %http_proxy%
http://PROXY_URL:PORT/
$ python distribute_setup.py
Downloading http://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz
Traceback (most recent call last):
  File "distribute_setup.py", line 564, in <module>
    sys.exit(main())
  File "distribute_setup.py", line 560, in main
    tarball = download_setuptools(download_base=options.download_base)
  File "distribute_setup.py", line 219, in download_setuptools
    src = urlopen(url)
  File "C:\Python27\lib\urllib2.py", line 126, in urlopen
    return _opener.open(url, data, timeout)
  File "C:\Python27\lib\urllib2.py", line 400, in open
    response = meth(req, response)
  File "C:\Python27\lib\urllib2.py", line 513, in http_response
    'http', request, response, code, msg, hdrs)
  File "C:\Python27\lib\urllib2.py", line 432, in error
    result = self._call_chain(*args)
  File "C:\Python27\lib\urllib2.py", line 372, in _call_chain
    result = func(*args)
  File "C:\Python27\lib\urllib2.py", line 619, in http_error_302
    return self.parent.open(new, timeout=req.timeout)
  File "C:\Python27\lib\urllib2.py", line 394, in open
    response = self._open(req, data)
  File "C:\Python27\lib\urllib2.py", line 412, in _open
    '_open', req)
  File "C:\Python27\lib\urllib2.py", line 372, in _call_chain
    result = func(*args)
  File "C:\Python27\lib\urllib2.py", line 1207, in https_open
    return self.do_open(httplib.HTTPSConnection, req)
  File "C:\Python27\lib\urllib2.py", line 1174, in do_open
    raise URLError(err)
urllib2.URLError: <urlopen error [Errno 11004] getaddrinfo failed>
```

ん？Pythonは `HTTP_PROXY` じゃダメなの？

こんな話もあるようだが…。

- [blockdiagシリーズのseqdiagとactdiagが、[Errno 10060]のダウンロードエラーでeasy_installのインストールに失敗する - みちしるべ](http://d.hatena.ne.jp/orangeclover/20121020/1350689017)

今回は URL 直接指定でもエラーが変わらなかった。

色々試行錯誤し、 **とりあえず環境を一回きれいにしてみようと `HTTP_PROXY` もクリアした** 状態でダメ元で実行してみた…らいけた…だと…。

```console
$ set http_proxy=
$ python distribute_setup.py
Downloading http://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz
Extracting in c:\users\USER\appdata\local\temp\tmp00_lbf

(略)

After install bootstrap.
C:\Python27\Lib\site-packages\setuptools-0.6c11-py2.7.egg-info already exists
```

後述する、 Sphinx インストール時も同じエラーでハマったんだけどこの方法(環境変数クリア)で解決した。

proxy必要な環境で、proxyを明示的に指定してないのになんでつながるの？どっか見てる？こわい。

というわけで、ちょっと urllib のドキュメントを調べる…。

- [20.5. urllib — URL による任意のリソースへのアクセス — Python 2.7ja1 documentation](http://docs.python.jp/2/library/urllib.html#module-urllib)

> Windows 環境では、プロキシを指定する環境変数が設定されていない場合、プロキシの設定値はレジストリの Internet Settings セクションから取得されます。

- [20.6. urllib2 — URL を開くための拡張可能なライブラリ — Python 2.7ja1 documentation](http://docs.python.jp/2/library/urllib2.html#module-urllib2)

> このクラスはプロキシを通過してリクエストを送らせます。引数 proxies を与える場合、プロトコル名からプロキシの URL へ対応付ける辞書でなくてはなりません。標準では、プロキシのリストを環境変数 <protocol>_proxy から読み出します。
>
> プロキシ環境変数が設定されていない場合は、 Windows 環境では、レジストリのインターネット設定セクションからプロキシ設定を手に入れ、 Mac OS X 環境では、 OS X システム設定フレームワーク (System Configuration Framework) からプロキシ情報を取得します。

なに？レジストリ見てんの？

というわけでレジストリから `Internet Settings` を探すと、

- HKEY_USERS
  - S-1-5-21-xxxxxxxx-xxxxxxxx...
    - Software
      - Microsoft
        - Windows
          - CurrentVersion
            - Internet Settings

ここに `ProxyServer` という値があった！

どうやらこれはIEのインターネットオプションから設定する値らしい。

※ HKEY_USERSの下のS-xxx文字列

> HKEY_USERS以下には、次のようなサブキーが存在します。
>
> サブキー                                      |サブキーを参照するユーザー
> ----------------------------------------------|-----------------------------------------------------
> .DEFAULT                                      |プロファイルがロードされていないユーザーが参照する。
> ----------------------------------------------|-----------------------------------------------------
> S-1-5-18                                      |SYSTEMが参照する。
> ----------------------------------------------|-----------------------------------------------------
> S-1-5-19                                      |LOCAL SERVICEが参照する。
> ----------------------------------------------|-----------------------------------------------------
> S-1-5-20                                      |NETWORK SERVICEが参照する
> ----------------------------------------------|-----------------------------------------------------
> S-1-5-21-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX-XXXX|特定のユーザーが参照する。SIDの最後の4文字はRIDであり、各ユーザーはこれで識別される。 RIDを除いた残りのSIDは、コンピュータのSIDである。

なるほど。これを見にきたから `HTTP_PROXY` をクリアしてもOKだったわけか。

でも、 **なんで環境変数 `HTTP_PROXY` に値を入れている状態** だとインストール失敗したんだろう？( 環境変数 `HTTP_PROXY` と レジストリ `ProxyServer` はまったく同じ値)

ここから先中身を追ってみないと分からないか…。

## Sphinx インストール

やっと Sphinx。

easy_install で入れる。当環境では `HTTP_PROXY` を事前にクリアする必要があった。

```console
$ set http_proxy=
$ Scripts\easy_install sphinx
Searching for sphinx
Reading http://pypi.python.org/simple/sphinx/
Best match: Sphinx 1.2b1
Downloading https://pypi.python.org/packages/2.7/S/Sphinx/Sphinx-1.2b1-py2.7.egg#md5=60fbf057bc586dce8ceb55a404f5a9be
Processing Sphinx-1.2b1-py2.7.egg
creating c:\python27\lib\site-packages\Sphinx-1.2b1-py2.7.egg
Extracting Sphinx-1.2b1-py2.7.egg to c:\python27\lib\site-packages
Adding Sphinx 1.2b1 to easy-install.pth file
Installing sphinx-apidoc-script.py script to C:\Python27\Scripts
Installing sphinx-apidoc.exe script to C:\Python27\Scripts
Installing sphinx-apidoc.exe.manifest script to C:\Python27\Scripts
Installing sphinx-build-script.py script to C:\Python27\Scripts
Installing sphinx-build.exe script to C:\Python27\Scripts
Installing sphinx-build.exe.manifest script to C:\Python27\Scripts
Installing sphinx-quickstart-script.py script to C:\Python27\Scripts
Installing sphinx-quickstart.exe script to C:\Python27\Scripts
Installing sphinx-quickstart.exe.manifest script to C:\Python27\Scripts
Installing sphinx-autogen-script.py script to C:\Python27\Scripts
Installing sphinx-autogen.exe script to C:\Python27\Scripts
Installing sphinx-autogen.exe.manifest script to C:\Python27\Scripts

Installed c:\python27\lib\site-packages\sphinx-1.2b1-py2.7.egg
Processing dependencies for sphinx
Searching for docutils>=0.7
Reading http://pypi.python.org/simple/docutils/
Best match: docutils 0.11
Downloading https://pypi.python.org/packages/source/d/docutils/docutils-0.11.tar.gz#md5=20ac380a18b369824276864d98ec0ad6
Processing docutils-0.11.tar.gz
Writing c:\users\USER\appdata\local\temp\easy_install-kytfku\docutils-0.11\setup.cfg
Running docutils-0.11\setup.py -q bdist_egg --dist-dir c:\users\USER\appdata\local\temp\easy_install-kytfku\docutils-0.11\egg-dist-tmp-l7szgx
warning: no files found matching 'MANIFEST'
warning: no files found matching '*' under directory 'extras'
warning: no previously-included files matching '.cvsignore' found under directory '*'
warning: no previously-included files matching '*.pyc' found under directory '*'
warning: no previously-included files matching '*~' found under directory '*'
warning: no previously-included files matching '.DS_Store' found under directory '*'
zip_safe flag not set; analyzing archive contents...
docutils.parsers.rst.directives.misc: module references __file__
docutils.writers.docutils_xml: module references __path__
docutils.writers.html4css1.__init__: module references __file__
docutils.writers.latex2e.__init__: module references __file__
docutils.writers.odf_odt.__init__: module references __file__
docutils.writers.pep_html.__init__: module references __file__
docutils.writers.s5_html.__init__: module references __file__
Adding docutils 0.11 to easy-install.pth file
Installing rst2html.py script to C:\Python27\Scripts
Installing rst2latex.py script to C:\Python27\Scripts
Installing rst2man.py script to C:\Python27\Scripts
Installing rst2odt.py script to C:\Python27\Scripts
Installing rst2odt_prepstyles.py script to C:\Python27\Scripts
Installing rst2pseudoxml.py script to C:\Python27\Scripts
Installing rst2s5.py script to C:\Python27\Scripts
Installing rst2xetex.py script to C:\Python27\Scripts
Installing rst2xml.py script to C:\Python27\Scripts
Installing rstpep2html.py script to C:\Python27\Scripts

Installed c:\python27\lib\site-packages\docutils-0.11-py2.7.egg
Searching for Jinja2>=2.3
Reading http://pypi.python.org/simple/Jinja2/
Best match: Jinja2 2.7.1
Downloading https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.1.tar.gz#md5=282aed153e69f970d6e76f78ed9d027a
Processing Jinja2-2.7.1.tar.gz
Writing c:\users\USER\appdata\local\temp\easy_install-ewpoxa\Jinja2-2.7.1\setup.cfg
Running Jinja2-2.7.1\setup.py -q bdist_egg --dist-dir c:\users\USER\appdata\local\temp\easy_install-ewpoxa\Jinja2-2.7.1\egg-dist-tmp-xvfdqy
warning: no files found matching '*' under directory 'custom_fixers'
warning: no previously-included files matching '*' found under directory 'docs\_build'
warning: no previously-included files matching '*.pyc' found under directory 'jinja2'
warning: no previously-included files matching '*.pyc' found under directory 'docs'
warning: no previously-included files matching '*.pyo' found under directory 'jinja2'
warning: no previously-included files matching '*.pyo' found under directory 'docs'
Adding jinja2 2.7.1 to easy-install.pth file

Installed c:\python27\lib\site-packages\jinja2-2.7.1-py2.7.egg
Searching for Pygments>=1.2
Reading http://pypi.python.org/simple/Pygments/
Best match: Pygments 1.6
Downloading https://pypi.python.org/packages/2.7/P/Pygments/Pygments-1.6-py2.7.egg#md5=1e1e52b1e434502682aab08938163034
Processing Pygments-1.6-py2.7.egg
creating c:\python27\lib\site-packages\Pygments-1.6-py2.7.egg
Extracting Pygments-1.6-py2.7.egg to c:\python27\lib\site-packages
Adding Pygments 1.6 to easy-install.pth file
Installing pygmentize-script.py script to C:\Python27\Scripts
Installing pygmentize.exe script to C:\Python27\Scripts
Installing pygmentize.exe.manifest script to C:\Python27\Scripts

Installed c:\python27\lib\site-packages\pygments-1.6-py2.7.egg
Searching for markupsafe
Reading http://pypi.python.org/simple/markupsafe/
Best match: MarkupSafe 0.18
Downloading https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.18.tar.gz#md5=f8d252fd05371e51dec2fe9a36890687
Processing MarkupSafe-0.18.tar.gz
Writing c:\users\USER\appdata\local\temp\easy_install-3qrqxg\MarkupSafe-0.18\setup.cfg
Running MarkupSafe-0.18\setup.py -q bdist_egg --dist-dir c:\users\USER\appdata\local\temp\easy_install-3qrqxg\MarkupSafe-0.18\egg-dist-tmp-jj55bb
==========================================================================
WARNING: The C extension could not be compiled, speedups are not enabled.
Failure information, if any, is above.
Retrying the build without the C extension now.

==========================================================================
WARNING: The C extension could not be compiled, speedups are not enabled.
Plain-Python installation succeeded.
==========================================================================
Adding markupsafe 0.18 to easy-install.pth file

Installed c:\python27\lib\site-packages\markupsafe-0.18-py2.7.egg
Finished processing dependencies for sphinx
```

とりあえずインストールまで。

設定までしようと思ったけど、思わぬ所でハマってしまった…。

---

## おまけ easy_install インストール(ez_setup.py)

すごいはまった挙句、結局ローカルに落としてインストールした時の記録。

多分 distrybute_setup.py と同様、 `HTTP_PROXY` をクリアすれば IE の proxy 設定を参照しにいって無事にインストールされるのではないかと思われる。

しかし、こちらは現在メンテナンスされていないらしい。

- [Windowsへのインストール :: ドキュメンテーションツール スフィンクス Sphinx-users.jp](http://sphinx-users.jp/gettingstarted/install_windows.html)

`ez_setup.py` をダウンロードし、実行すると以下のようなエラー。

```console
$ python ez_setup.py
Downloading http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg
Traceback (most recent call last):
  File "ez_setup.py", line 278, in <module>
    main(sys.argv[1:])
  File "ez_setup.py", line 210, in main
    egg = download_setuptools(version, delay=0)
  File "ez_setup.py", line 158, in download_setuptools
    src = urllib2.urlopen(url)
  File "C:\python27\lib\urllib2.py", line 127, in urlopen
    return _opener.open(url, data, timeout)
  File "C:\python27\lib\urllib2.py", line 410, in open
    response = meth(req, response)
  File "C:\python27\lib\urllib2.py", line 523, in http_response
    'http', request, response, code, msg, hdrs)
  File "C:\python27\lib\urllib2.py", line 442, in error
    result = self._call_chain(*args)
  File "C:\python27\lib\urllib2.py", line 382, in _call_chain
    result = func(*args)
  File "C:\python27\lib\urllib2.py", line 629, in http_error_302
    return self.parent.open(new, timeout=req.timeout)
  File "C:\python27\lib\urllib2.py", line 404, in open
    response = self._open(req, data)
  File "C:\python27\lib\urllib2.py", line 422, in _open
    '_open', req)
  File "C:\python27\lib\urllib2.py", line 382, in _call_chain
    result = func(*args)
  File "C:\python27\lib\urllib2.py", line 1222, in https_open
    return self.do_open(httplib.HTTPSConnection, req)
  File "C:\python27\lib\urllib2.py", line 1184, in do_open
    raise URLError(err)
urllib2.URLError: <urlopen error [Errno 11004] getaddrinfo failed>
```

Downloading のurlにブラウザからアクセスするとダウンロードできるので、多分proxyの設定が適切になされていない。

「urllib2 proxy」で調べると ProxyHandler を使えばよいということ(というか、環境変数 `HTTP_PROXY` (設定済み) を呼んでくれそうな気がするんだけど)なので、 ez_setup.py の中で明示的に proxy を指定してみた。

- [20.6. urllib2 ? URL を開くための拡張可能なライブラリ ? Python 2.7ja1 documentation](http://docs.python.jp/2/library/urllib2.html#urllib2.urlopen)

```python
+ proxy_handler = urllib2.ProxyHandler({'http': 'http://PROXY:PORT/'})
+ opener = urllib2.build_opener(proxy_handler)
+ src = opener.open(url)
- src = urllib2.urlopen(url)
```

が、エラー変わらず。 proxy が原因じゃないのか。今度は Errno でググってみた。

- [ss_9's log　 Python](http://ss9neco.blog.fc2.com/category3-1.html)

> その際、proxy環境の場合は、
>
>> ＃ export http_proxy=http://[proxy名]:[ポート番号]
>
> にてproxy環境を整えてください。

お、やっぱり環境変数から呼んでくれるみたい。そして、

> また、ez_setupを取得して、以下のようなurllib2のエラーが出た時は、
>
> urllib2.URLError:
>
> setuptoolsをez_setupと同じディレクトリに置いてください。
>
>> ＃ sudo wget http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg#md5=fe1f997bc722265116870bc7919059ea

ということなので、この setuptools `setuptools-0.6c11-py2.7.egg` をDLし再び実行すると無事にインストールできた。

```console
$ python ez_setup.py
Processing setuptools-0.6c11-py2.7.egg
Copying setuptools-0.6c11-py2.7.egg to c:\python27\lib\site-packages
Adding setuptools 0.6c11 to easy-install.pth file
Installing easy_install-script.py script to C:\Python27\Scripts
Installing easy_install.exe script to C:\Python27\Scripts
Installing easy_install.exe.manifest script to C:\Python27\Scripts
Installing easy_install-2.7-script.py script to C:\Python27\Scripts
Installing easy_install-2.7.exe script to C:\Python27\Scripts
Installing easy_install-2.7.exe.manifest script to C:\Python27\Scripts

Installed c:\python27\lib\site-packages\setuptools-0.6c11-py2.7.egg
Processing dependencies for setuptools==0.6c11
Finished processing dependencies for setuptools==0.6c11
```

実行できた。

```console
$ easy_install --help

Global options:
  --verbose (-v)  run verbosely (default)
  --quiet (-q)    run quietly (turns verbosity off)
  --dry-run (-n)  don't actually do anything
  --help (-h)     show detailed help message
  --no-user-cfg   ignore pydistutils.cfg in your home directory

Options for 'easy_install' command:
  --prefix                       installation prefix
  --zip-ok (-z)                  install package as a zipfile
  --multi-version (-m)           make apps have to require() a version
  --upgrade (-U)                 force upgrade (searches PyPI for latest
                                 versions)
  --install-dir (-d)             install package to DIR
  --script-dir (-s)              install scripts to DIR
  --exclude-scripts (-x)         Don't install scripts
  --always-copy (-a)             Copy all needed packages to install dir
  --index-url (-i)               base URL of Python Package Index
  --find-links (-f)              additional URL(s) to search for packages
  --delete-conflicting (-D)      no longer needed; don't use this
  --ignore-conflicts-at-my-risk  no longer needed; don't use this
  --build-directory (-b)         download/extract/build in DIR; keep the
                                 results
  --optimize (-O)                also compile with optimization: -O1 for
                                 "python -O", -O2 for "python -OO", and -O0 to
                                 disable [default: -O0]
  --record                       filename in which to record list of installed
                                 files
  --always-unzip (-Z)            don't install as a zipfile, no matter what
  --site-dirs (-S)               list of directories where .pth files work
  --editable (-e)                Install specified packages in editable form
  --no-deps (-N)                 don't install dependencies
  --allow-hosts (-H)             pattern(s) that hostnames must match
  --local-snapshots-ok (-l)      allow building eggs from local checkouts

usage: easy_install-script.py [options] requirement_or_url ...
   or: easy_install-script.py --help
```
