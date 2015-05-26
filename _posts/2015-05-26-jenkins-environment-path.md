---
layout: post
title: "実行ユーザの違いでJenkinsのホームディレクトリが変わって困った話"
description: ""
category: 
tags: [Jenkins]
---
{% include JB/setup %}

# あらすじ

結構昔にWindows 7上において、以下の2通りのSeleniumスクリプト実行結果が違ってすごく困っていた。

前提条件としては、Seleniumスクリプトは同じ。実行コマンドも `bundle exec ruby hoge.rb` で同じ。違うのは実行の仕方だけ。

1. コマンドプロンプトで実行
    - Seleniumスクリプト
    - コマンドプロンプトからコマンド実行
    - 正常終了
2. Jenkinsで実行
    - Seleniumスクリプト(「Windowsバッチコマンドの実行」でジョブに登録)
    - リモートビルドから実行
    - ＼エラー／

原因の切り分け方とかもわからなかったのでかなり苦戦…。

## 環境

- Windows 7
- Jenkins 1.581
- Ruby 1.9.3
    - bundler (1.3.5)
    - pit (0.0.7)
    - selenium-webdriver (2.43.0)

## 結論

原因はJenkinsとコマンドプロンプトでの実行時の **環境変数の違い** だった。環境変数をいじって解決。

具体的に何が起こっていたかというと…。

- Seleniumスクリプトの中で `pit` (https://github.com/cho45/pit) というアカウントのID、パスワードを外出しできるGemを使用していた
    - pitの挙動は、 `~/.pit` 直下にあるyamlファイルを探して、IDとパスワードを取得するというもの

### コマンドプロンプトで実行したとき

1. 実行ユーザは「今Windowsにログオンしている自分」
1. pitは `~/.pit` = `C:\Users\USER\.pit` を見に行っていた

ホームディレクトリにはアカウント定義しているyamlがあるので正常に動作。まあこれはそうだよね。問題は次。

### Jenkinsで実行したとき

1. 実行ユーザは「Jenkins自体？」(コンソール出力を見るとリモートホスト127.0.0.1が実行となってる)
1. pitは `~/.pit` = `C:\windows\system32\config\systemprofile\.pit` を見に行っていた

system32…？こんなパスにアカウント定義しているyamlはないので当然失敗する。

Jenkinsの管理 -> システム情報 からシステムプロパティを見ると `user.home` が `C:\Windows\System32\config\systemprofile` と定義されていた

- Seleniumスクリプト実行前にこんな環境変数セットして無理矢理解決した

`set USERPROFILE=C:\Users\USER`

- 普段目立たなかったライブラリの環境変数が変わっていることに気づかなかった
- あと、そこに気づけるようになっていなかったので、原因突き詰めるのにも手間取った

## 原因にたどり着くまで

- Jenkinsで実行するとこんなエラーがでた。なんかframeがないと。

{% highlight console %}
[remote server] file:///C:/windows/Temp/webdriver-rb-profilecopy20140902-7960-9wnep3/extensions/fxdriver@googlecode.com/components/driver_component.js:8929:5:in `FirefoxDriver.prototype.switchToFrame': Unable to locate frame: mainframe (Selenium::WebDriver::Error::NoSuchFrameError)
{% endhighlight %}

- でも、このエラーだけじゃ全然よくわからん…しかし、どうやって原因を切り分ければよいのかもわからんかった。
  - とりあえずputsを入れまくってみた
  - @yando さんの助言によりこけてそうなところでスクリーンショットを取るようにしてみた
- putsとスクショの結果を眺めると、ログインフォームにID、パスワードが入ってないようだ
- pitがうまく動いてないとわかった

という感じ。

いろんなテクニックを駆使して、どこでコケてるかわかりやすくしなければならないのか。

- [全国のSeleniumer必読](http://qiita.com/oh_rusty_nail/items/b8ba525d31ea7c522856)
- [Selenium+JenkinsのCIをできるだけコケなくするコツ](http://qiita.com/oh_rusty_nail/items/d2284efc7fd2dd7c3206)
