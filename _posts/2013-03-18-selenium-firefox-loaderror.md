---
layout: post
title: "Selenium WebDriverでFirefoxがロードできなくなった"
description: ""
category: 
tags: [Selenium, Firefox, Ruby]
---
{% include JB/setup %}

## あらすじ

`Selenium IDE` でテストケースを作成し、WebDriver形式でエクスポートしたRSpecファイルを `Firefox` で実行すると、 `invalid byte sequence` エラーが表示されるようになった。

どこさわったからこうなったのかわからん……。

(以下では、WebDriver.for時にテスト用のprofileを指定している) 

{% highlight console %}
$ rspec test.rb
F

Failures:

  1) test
     Failure/Error: @driver = Selenium::WebDriver.for :firefox, :profile => profile
     ArgumentError:
       invalid byte sequence in UTF-8
     # ./test.rb:13:in `block (2 levels) in <top (required)>'
{% endhighlight %}

profileの中かな？　とか思っていたけど。

## 環境

- Ruby 1.9.3
  - RubyGems 2.0.1
    - bundler (1.3.1)
    - childprocess (0.3.9)
    - diff-lcs (1.2.1)
    - ffi (1.4.0)
    - multi_json (1.6.1)
    - rspec (2.13.0)
    - rspec-core (2.13.0)
    - rspec-expectations (2.13.0)
    - rspec-mocks (2.13.0)
    - rubyzip (0.9.9)
    - selenium-webdriver (2.31.0)
    - websocket (1.0.7)
- Firefox 19.0.2 (x86 en-US)
  - プロファイルは `C:/Selenium/` のものを使用 ( `firefox.exe -ProfileManager` から)
  - Selenium IDE 1.1.0
  - Selenium IDE: Ruby Formatters 1.1.0

※ IEのDriverを使うと、正常に起動できる

## 原因

とりあえず、WebDriver.for :firefox (vendor/bundle/ruby/1.9.1/gems/selenium-webdriver-2.31.0/lib/selenium/webdriver/common/driver.rb) から順々に処理を追っていったら……。

{% highlight ruby %}
 def for(browser, opts = {})
   listener = opts.delete(:listener)

   bridge = case browser
            when :firefox, :ff
              Firefox::Bridge.new(opts)
{% endhighlight %}

どうも、レジストリを読み込むところ (vendor/bundle/ruby/1.9.1/gems/selenium-webdriver-2.31.0/lib/selenium/webdriver/firefox/binary.rb) の `reg.keys[0]` で処理が止まっていることがわかった。

{% highlight ruby%}
   def windows_registry_path
     require 'win32/registry'

     lm = Win32::Registry::HKEY_LOCAL_MACHINE
     lm.open("SOFTWARE\\Mozilla\\Mozilla Firefox") do |reg|
# ここ
       main = lm.open("SOFTWARE\\Mozilla\\Mozilla Firefox\\#{reg.keys[0]}\\Main")
       if entry = main.find { |key, type, data| key =~ /pathtoexe/i }
         return entry.last
       end
     end
   rescue LoadError
     # older JRuby or IronRuby does not have win32/registry
   rescue Win32::Registry::Error
   end
{% endhighlight %}

`HKEY_LOCAL_MACHINE/SOFTWARE/Mozilla/Mozilla Firefox/hogehoge/Main` を開こうとして力尽きている模様。。

もしかしてこのレジストリ情報が存在しない？

`regedit` で確認してみる。

{% highlight console %}
マイ コンピュータ
|
`HKEY_LOCAL_MACHINE
 |
 `SOFTWARE
  |
  `Mozilla
   |
   |`Firefox
   |`MaintenanceService
   |`Mozilla Firefox
   | |
   | `19.0.2 (en-US)
   |  |
   |  |`Main
   |  `Uninstall
   `Mozilla Firefox 19.0.2
{% endhighlight %}

`19.0.2 (en-US)` が `reg.keys[0]` に該当してる部分だなあ。

## 解決策

WebDriverのソースを直接ベタ書きすると、一応起動させる事ができた。

{% highlight ruby%}
   lm.open("SOFTWARE\\Mozilla\\Mozilla Firefox") do |reg|
-    main = lm.open("SOFTWARE\\Mozilla\\Mozilla Firefox\\#{reg.keys[0]}\\Main")
+    main = lm.open("SOFTWARE\\Mozilla\\Mozilla Firefox\\19.0.2 \(en-US\)\\Main")
     if entry = main.find { |key, type, data| key =~ /pathtoexe/i }
{% endhighlight %}

一応、Firefoxをアンインストールしてレジストリも消してから17.0に落としたり、18.0に上げたり、19.0に戻したりしたけど、全部上記の箇所で引っかかってた。

ベタ書くと動く。

うーん、なんでいきなりレジストリが読めなくなったのかきっかけがわからん。
