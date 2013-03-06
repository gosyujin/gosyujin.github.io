---
layout: post
title: "IEとかiPhoneWebView上でSeleniumを走らせる"
description: ""
category: 
tags: [Ruby, Selenium, iPhone, IE, Test]
---
{% include JB/setup %}

## あらすじ

1. Firefoxのアドオンである `Selenium IDE` で作ったテストケースをWebDriver, RSpec形式でエクスポート
1. このソースは、デフォルトではFirefoxでテストが開始されるようになっている
1. これを、 `IE` でテストするようにしたり、 `iPhoneWebView` (内部ブラウザ)を起動してテストするようにしたい
1. 結果としては、どちらもテスト可能だが、準備が若干めんどい

## IEでテストをするには

### 環境

- IE 9

### 手順

基本的には、 `Selenium IDE` で生成したテストコードの「何のブラウザを開くか」ってところを変えればいいはず……。

{% highlight ruby %}
-  @driver = Selenium::WebDriver.for :firefox
+  @driver = Selenium::WebDriver.for :ie
{% endhighlight %}

……が、それだけではダメ。実行すると以下のようなエラーが出る。

{% highlight ruby %}
Failures:

  1) MailcheckSpec test_mailcheck_spec
     Failure/Error: @driver = Selenium::WebDriver.for :ie
     Selenium::WebDriver::Error::WebDriverError:
       Unable to find standalone executable. Please download the IEDriverServer
from http://code.google.com/p/selenium/downloads/list and place the executable o
n your PATH.
     # ./mailcheck_spec.rb:10:in `block (2 levels) in <top (required)>'

Finished in 0.05651 seconds
1 example, 1 failure

Failed examples:

rspec ./mailcheck_spec.rb:24 # MailcheckSpec test_mailcheck_spec
{% endhighlight %}

むむ。IEを動かすには `IEDriverServer` というものが必要なのか。

- [InternetExplorerDriver - selenium - Everything you wanted to know about the Internet Explorer driver - Browser automation framework - Google Project Hosting](http://code.google.com/p/selenium/wiki/InternetExplorerDriver)

> You do not need to run an installer before using the InternetExplorerDriver, though some configuration is required. The standalone server executable must be downloaded from the Downloads page and placed in your PATH.

上記のサイトからIEWebDriver(64bitか32bit)をダウンロードし、パスが通っている場所に移す。

この時、 `IE -> ツール -> インターネット オプション -> セキュリティ -> インターネット、イントラ、信頼済み、制限つきサイト全ての保護モードの設定を同じ` にする必要がある(揃っていればON/OFFはどちらでも良いらしい) 

で、再び実行すると、IEDriverServerが起動し、IEが開かれる！

## iPhoneでテストをするには

### 環境

- Xcode 4.5 (4.2以上)
- Java 1.6 (SE Runtime Environment (build 1.6.0_29-b11-402-11M3527))

### 参考サイト

- [SeleniumのiPhone DriverのWikiを翻訳してみた](http://techmemomemo.blogspot.jp/2012/10/seleniumiphone-driverwiki.html)
- [iWebDriverでテストする - スコトプリゴニエフスク通信](http://d.hatena.ne.jp/perezvon/20120517/1337262144)

### 手順

- `git clone https://code.google.com/p/selenium/` でソースをDL

{% highlight console %}
$ cd selenium/
$ ./go iphone
(in /Users/user/Desktop/selenium)
Using iPhoneSDK: 'iphonesimulator6.0'
Building iWebDriver iphone app.
Build settings from command line:
    ARCHS = i386
    SDKROOT = iphonesimulator6.0

=== BUILD NATIVE TARGET iWebDriver OF PROJECT iWebDriver WITH CONFIGURATION Debug ===
Check dependencies

(略)

** BUILD SUCCEEDED **

Compiling: //java/client/src/org/openqa/selenium/remote:api as build/java/client/src/org/openqa/selenium/remote/api.jar
Compiling: //java/client/src/org/openqa/selenium:beta as build/java/client/src/org/openqa/selenium/beta.jar
Compiling: //java/client/src/org/openqa/selenium/logging:api as build/java/client/src/org/openqa/selenium/logging/api.jar
Compiling: //java/client/src/org/openqa/selenium:base as build/java/client/src/org/openqa/selenium/base.jar
Compiling: //java/client/src/org/openqa/selenium/logging:logging as build/java/client/src/org/openqa/selenium/logging/logging.jar
Compiling: //java/client/src/org/openqa/selenium:codecs as build/java/client/src/org/openqa/selenium/codecs.jar
Compiling: //java/client/src/org/openqa/selenium/interactions:api as build/java/client/src/org/openqa/selenium/interactions/api.jar
Compiling: //java/client/src/org/openqa/selenium/security:security as build/java/client/src/org/openqa/selenium/security/security.jar
Compiling: //java/client/src/org/openqa/selenium:webdriver-api as build/java/client/src/org/openqa/selenium/webdriver-api.jar
Compiling: //java/client/src/org/openqa/selenium/remote:base as build/java/client/src/org/openqa/selenium/remote/base.jar
Compiling: //java/client/src/org/openqa/selenium/interactions:interactions as build/java/client/src/org/openqa/selenium/interactions/interactions.jar
Compiling: //java/client/src/org/openqa/selenium/browserlaunchers:proxies as build/java/client/src/org/openqa/selenium/browserlaunchers/proxies.jar
Compiling: //java/client/src/org/openqa/selenium/remote:common as build/java/client/src/org/openqa/selenium/remote/common.jar
Compiling: //java/client/src/org/openqa/selenium/net:net as build/java/client/src/org/openqa/selenium/net/net.jar
Compiling: //java/client/src/org/openqa/selenium/os:os as build/java/client/src/org/openqa/selenium/os/os.jar
Compiling: //java/client/src/org/openqa/selenium/io:io as build/java/client/src/org/openqa/selenium/io/io.jar
Compiling: //java/client/src/org/openqa/selenium/remote:remote as build/java/client/src/org/openqa/selenium/remote/remote.jar
Compiling: //java/client/src/org/openqa/selenium/iphone:iphone as build/java/client/src/org/openqa/selenium/iphone/iphone.jar
{% endhighlight %}

### 実機にインストール

もちろん、iPhoneシミュレータでも動かせるようだが、今回はいきなり実機に放り込む。

- git clone してきたseleniumディレクトリの下にある `selenium/iphone/iWebDriver.xcodeproj` をXcodeで起動
  - iPhoneを接続、ビルド
- ビルド成功したら、 `iWebDriver` アプリがiPhoneにインストールされる
  - 起動すると、白い画面と画面下にアドレスが表示される( `Started at http://xx.xx.xx.xx:3001/wd/hub/` のような感じ)

Xcode上の設定としては以下を行った。

- Build Settingsの `Valid architectures` を `i386` から `armv7` に変えた
- 同じく `Code Signing Identity` を `iPhone Developer` に変えた
- `Info.plist` ファイルに `Application does not run in background: YES` を追加した
  - 一回終了したら、またはじめからとしたいため
  
### 操作

http://code.google.com/p/selenium/wiki/IPhoneDriver には以下のようにdriverの定義しろとある。

{% highlight ruby %}
@driver = Selenium::WebDriver.for :remote, :url => "http://localhost:3001/wd/hub", :desired_capabilities => :iphone
# or use the convenience class which uses localhost:3001 by default
@driver = Selenium::WebDriver.for :iphone
{% endhighlight %}

ただし、これはローカル上(シミュレータ？)の場合で、実機につなぎたい場合は `:url` のlocalhostを上記のiPhoneアプリ上に表示されたアドレスに置き換える。

……が、どうも動かない。以下のようなエラーが出る。

{% highlight console %}
An error occurred in an after hook
  RSpec::Expectations::ExpectationNotMetError: expected: []
     got: nil (using ==)
  occurred at /hogeproject/vendor/bundle/ruby/1.9.1/gems/rspec-expectations-2.13.0/lib/rspec/expectations/fail_with.rb:32:in `fail_with'

F

Failures:

  1) MailcheckSpec test_mailcheck_spec1
     Failure/Error: @driver = Selenium::WebDriver.for :iphone
     Selenium::WebDriver::Error::WebDriverError:
       unexpected response, code=403, content-type="text/html"
       <html>
       <head>
       <title>Error 403 Forbidden for Proxy</title>
       </head>
       <body>
       <h2>HTTP ERROR: 403</h2><pre>Forbidden for Proxy</pre>
       <p>RequestURI=/wd/hub/session</p>
       <p><i><small><a href="http://jetty.mortbay.org">Powered by Jetty://</a></small></i></p>
{% endhighlight %}

二つ目のWebDriver.forをコメントアウトすると動いた。

{% highlight ruby %}
@driver = Selenium::WebDriver.for :remote, :url => "http://localhost:3001/wd/hub", :desired_capabilities => :iphone
# or use the convenience class which uses localhost:3001 by default
# @driver = Selenium::WebDriver.for :iphone
{% endhighlight %}

### 注意

動かすタイミングとしては、

1. iPhoneのiWebDriverアプリを立ち上げ、 `Started at: ...` と表示されるのを待つ
1. PCからテストを実行する

iWebDriverが起動しきる前に先走ってテスト実行してしまうと余裕でエラーになったりする。

それでちょっとハマった。
