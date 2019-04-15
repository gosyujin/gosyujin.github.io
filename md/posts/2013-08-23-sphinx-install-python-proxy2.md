---
layout: post
title: "Sphinxをインストールしようとしたら全然関係ないproxy周りでハマった話 続き"
description: ""
category: 
tags: [Python, Sphinx]
---

## 前回までのあらすじ

- [Sphinxをインストールしようとしたら全然関係ないproxy周りでハマった話](http://gosyujin.github.io/2013/08/21/sphinx-install-python-proxy/)

easy_install で見に行く proxy の順番はこんな感じだった。

1. 引数に明示的に指定した場合は引数を使う
1. ↑を満たさず、環境変数 `xxxx_proxy` が設定されている場合はそこから読み込む
1. ↑を満たさない場合、 Windows ではレジストリ( IE の proxy 設定)を見にいく

で、なぜか環境変数 `HTTP_PROXY` を読み込んだ場合は失敗して、 `HTTP_PROXY` をクリアしてレジストリの proxy 設定を使ったら DL が成功しちゃったという話。

なんでか気になったので調べた。

## 結論

http **以外** の proxy 設定をしていなかったから。というマヌケなオチ。

次から気をつけよう。

### レジストリ( IE の設定)から

IE の 設定では、 `ツール > インターネットオプション > 接続 > LAN の設定 > 詳細設定` の Secure にも proxy の設定が入れていた。

`すべてのプロトコルに同じプロキシサーバーを使用する` にチェックを入れていたので。

レジストリから読み込んだ場合、 Python 実行中に取得した変数 `proxies` (使用する proxy をしまっておく変数)の値はこんな感じだった。

```python
[('http', 'http://PROXY:PORT/'), ('https', 'https://PROXY:PORT/'), ('ftp', 'ftp://PROXY:PORT')]
```

### 環境変数から

一方、環境変数には `HTTP_PROXY` しか指定していなかった。 `proxies` を出力するとこう。

```python
[('http', 'http://PROXY:PORT/')]
```

なので、環境変数に `HTTPS_PROXY` : `https://PROXY:PORT/` を追加すると無事に easy_install できた！

## 内部の処理

内部がどうなっているのか見てみよう。

### 環境変数 `HTTP_PROXY` を設定している、IEのプロキシを設定している場合

この場合、環境変数 `HTTP_PROXY` が使われる。

また、ProxyHandler への引数 `proxies` が指定されている場合(明示的に指定している場合)、それが最優先で使われる。

- urllib2#ProxyHandler から urllib#getproxies を呼ぶ

```python
class ProxyHandler(BaseHandler):
    # Proxies must be in front
    handler_order = 100

    def __init__(self, proxies=None):
        if proxies is None:
            proxies = getproxies()
```

- getproxies_environment を呼ぶ

```python
    def getproxies():
        """Return a dictionary of scheme -> proxy server URL mappings.

        Returns settings gathered from the environment, if specified,
        or the registry.

        """
        return getproxies_environment() or getproxies_registry()
```

- 環境変数を取得して `xxxx_proxy` のものを探して返す

```python
def getproxies_environment():
    """Return a dictionary of scheme -> proxy server URL mappings.

    Scan the environment for variables named <scheme>_proxy;
    this seems to be the standard convention.  If you need a
    different way, you can pass a proxies dictionary to the
    [Fancy]URLopener constructor.

    """
    proxies = {}
    for name, value in os.environ.items():
        name = name.lower()
        if value and name[-6:] == '_proxy':
            print name
            proxies[name[:-6]] = value
    return proxies
```

これで `HTTP_PROXY` が見つかって `proxies` にぶちこまれてる。

### 環境変数 `HTTP_PROXY` を設定していない、IEのプロキシを設定している場合

この場合、 IE の proxy 設定をレジストリから探しに行く。

- getproxies_environment を呼ぶところまでは同じだが、 getproxies_environment から設定を見つけられないので getproxies_registry へ

```python
   def getproxies_registry():
        """Return a dictionary of scheme -> proxy server URL mappings.

        Win32 uses the registry to store proxies.

        """
        proxies = {}
        try:
            import _winreg
        except ImportError:
            # Std module, so should be around - but you never know!
            return proxies
        try:
            internetSettings = _winreg.OpenKey(_winreg.HKEY_CURRENT_USER,
                r'Software\Microsoft\Windows\CurrentVersion\Internet Settings')
            proxyEnable = _winreg.QueryValueEx(internetSettings,
                                               'ProxyEnable')[0]
            if proxyEnable:
                # Returned as Unicode but problems if not converted to ASCII
                proxyServer = str(_winreg.QueryValueEx(internetSettings,
                                                       'ProxyServer')[0])
                if '=' in proxyServer:
```

Internet Settings に探しにいっている。
