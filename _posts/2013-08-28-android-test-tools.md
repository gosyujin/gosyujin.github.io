---
layout: post
title: "Androidの自動テストツール、今(2013年)から使うなら何がよいのか"
description: ""
category: 
tags: [Java, Android]
---
{% include JB/setup %}

## あらすじ

Androidのテストを自動化したいので、テストツールの選定をしてみたが、昔の記事がヒットする事が多く、何を使えばいいのかよくわからん。

とはいっても、明確に「どんなテストがしたい」という方針もなく、とっかかりとしてどんなツールがあってどのくらい盛り上がってるのかが知りたかった。

## 環境

- Windows 7
- AndroidDeveloperTools Build: v21.1.0-569685

とりあえず Win メインで。

## とっかかり

### ロジックまわりのテスト

ロジック的なものは、 JUnit 拡張の TestCase クラスを使えば何とか書けそうというのはわかった。

- [Androidアプリ開発テスト入門（2）：Android SDKでビジネスロジックのテストを自動化するには (1/3) - ＠IT](http://www.atmarkit.co.jp/ait/articles/1112/16/news137.html)

2011 年の記事だけど、 JUnit で書くという大前提は崩れていないはず…。

### 画面遷移やGUIまわりのテスト

困ったのはこっち。どう書けばいいんだろう。

**「Android 自動テスト ツール」** とかで調べてみた結果、以下のような記事が引っ掛かった。

- [Androidアプリの自動テストツールで最も有望か - 「NativeDriver」，Google製「WebDriver」の拡張　（公式のAndroid版Selenium） - 主に言語とシステム開発に関して](http://d.hatena.ne.jp/language_and_engineering/20110930/p1)

これも 2011 年の記事だが、この中では `NativeDriver` , `robotium` , `Scirocco` の 3 ツールでは最終的に `NativeDriver` に集約されていくだろうという結論になっている。

…が、 2013 年現在においても本当にそうなのか？

## 結論

2013 年 08 月の時点ではこんな感じ。

ツール      |ソース                                              |Android |iOS |テスト記述可能な言語                  |備考
------------|----------------------------------------------------|--------|----|--------------------------------------|----
NativeDriver|[svn](http://nativedriver.googlecode.com/svn)       |-       |-   |-                                     |開発終了
robotium    |[GitHub](https://github.com/jayway/robotium)        |1.6 以上|    |`Java`                                |
Scirocco    |[GitHub](https://github.com/sonixlabs/scirocco-webdriver)|-  |-   |-                                     |2012/09 で更新が止まっている
Monkeyrunner|sdk内                                               |`○`    |    |`Java` `Python`                       |Jython で実行 / Plugin は Java で書ける / 今回はうまく動かせなかった
Appium      |[GitHub](https://github.com/appium/appium)          |4.2 以上|`○`|`Node.js` `Python` `PHP` `Ruby` `Java`|Windows 版は beta / iOS がメイン？ [ファイル置場](https://bitbucket.org/appium/appium.app/downloads)
Spoon       |[GitHub](https://github.com/square/spoon)           |4.1 以上|    |`Java`                                |Maven 実行推奨？
Selenroid   |[GitHub](https://github.com/DominikDary/selendroid) |`○`    |    |`Java`                                |Windows 版は現状未サポート / Ruby でもテスト書ける？
uiautomator |sdk内                                               |4.1 以上|    |`Java`                                |今回はうまく動かせなかった

Android / iOS 欄の `○` は公式で動くと謳っているが、詳しいバージョンまで見つけられなかったものに記入。

- 今でもよく検索に引っかかる `NativeDriver` はとっくに開発終了されている
- 新鋭( 2013 ～)ツールは便利な機能も多い印象だが、 Windows に未サポートのものが多い(バグ踏んでも泣かない)
- Windows 使いなら `robotium` あたりに行くのが良い？

以下、ひとつずつ見てみる。

## テストツール

### NativeDriver - 開発終了

- <del>公式 [nativedriver - Native application GUI automation with extended WebDriver API - Google Project Hosting](http://code.google.com/p/nativedriver/)</del>
  - <del>コミットログ日付 2011-04-25 - **2011-08-08** </del>
  - 2012年 [Googleのスマホアプリ自動テストツールNativeDriver事始め＆ハマったところ - Vermee81の日録](http://d.hatena.ne.jp/hrksb5029/20120607/1339091915)
  - 2012年 [AndroidのテストツールNativedriverを使ってみる - yyhayashi303's diary](http://yyhayashi303.hatenablog.com/entry/20120225/1330182071)

Selenium WebDriver の源流になっている WebDriver (Google謹製 / 2009年) の流れをくんでおり、かつAndroid, iOS対応とし、現在の主流なのかと思ったが、2011年で更新が止まっている？

→ `NativeDriver` はすでに **開発終了** しており、一部 Selenium 2(WebDriver 統合)に還元されて天に召された模様。

- [自己紹介 - Google Groups](https://groups.google.com/d/topic/seleniumjp/xVHa48gHBLg)
- [Winding down NativeDriver - Google グループ](https://groups.google.com/forum/#!topic/nativedriver-devs/WC0GopaDMIo)

上記のフォーラムで、 `NativeDriver` ユーザはどうすればよいか今後の方針が述べられている。

1. `Android Instrumentation` のような公式ツールを使え
2. `robotium` のようなサードパーティツールを使え
3. ( `NativeDriver` を引き続き使うなら)自分自身で  Hack し、より良くしてみろ

ということらしい。というわけで、2013年の時点では候補から除外した方がよさげ。

(ワードにもよるが) ググると高確率でこれが上位にあがってくるので、バリバリ使われているのかと思ったが、正式に凍結を声明した記述が見つかったので安心。

### robotium

- 公式 [robotium - The world's leading Android? test automation framework - Google Project Hosting](http://code.google.com/p/robotium/)
  - コミットログ日付 2009-12-10 - 2013-08-25
  - 2013年 [androidでrobotiumを使って画面遷移をテストする ≫ tech-tec](http://tech-tec.com/archives/881)
  - 2012年 [Robotiumを触ってみた(Android自動テストツール) - くのっふむ(knnfm)](http://d.hatena.ne.jp/knnfm/20120125/1327460923)
  - 2010年 [RobotiumでAndroidアプリのシナリオテストを自動化する - 遥かへのスピードランナー](http://poly.hatenablog.com/entry/20101019/p1)

この中では一番プロジェクトの歴史が古く、2013年に入っても精力的にコミットなされている。

> This project is neither affiliated with Google nor with OpenQA (Selenium).

「Google プロジェクトでも Selenium プロジェクトでもない」という事で、非公式 Selenium 的な感じの様子。

- Android 1.6 以上をサポート
- apk ファイルのみでもテスト可
- プリインストールされた端末でもテスト可
- ハイブリッドアプリもテスト可能( `robotium` 4.0 から)

これはちょっと Hello World してみよう。

#### 前準備

公式ページより Jar File をダウンロード。現在の最新版は `robotium-solo-4.2.jar`

これを `TESTPROJECT/libs/` に入れる。 libs ディレクトリに入れると、 Eclipse の Package Explorer で見たときに `Android Dependencies` 下に `robotium` の jar が見えるはず。

見えなければプロパティから追加。 [testing - Android Robotium NoClassDefFoundError - Stack Overflow](http://stackoverflow.com/questions/9875029/android-robotium-noclassdeffounderror)

#### シナリオ作成

基本的には JUnit のテストケース作成と同じ要領で進む。

適当なログイン画面のログインボタン押して、戻るだけのテストケース `LoginActivityTest.java`

{% highlight java %}
// robotium インポート
import com.jayway.android.robotium.solo.Solo;

(略)

// 既存のJUnitテストクラス
public class LoginActivityTest
  extends ActivityInstrumentationTestCase2<LoginActivity> {

(略)
    // に robotium を使ったテストを追加
    public void testMove() throws Exception {
            Solo solo = new Solo(getInstrumentation(), getActivity());
            // 座標指定してクリック
            solo.clickOnScreen(200, 600);
            // 画面から引数に指定したテキストを見つけて？クリック
            solo.clickOnText("Hoge");
            // ログインと書かれたボタンを見つけてクリック
            solo.clickOnButton("ログイン");

            solo.assertCurrentActivity("次の画面へ", MainActivity.class);
            
            // "/sdcard/Robotium-Screenshots/" にスクリーンショット保存
            solo.takeScreenshot();
            // アクティビティ戻る
            solo.goBack();
            
            solo.assertCurrentActivity("戻ってきた", LoginActivity.class);
        }
(略)
{% endhighlight %}

`solo.clickOnButton("ログイン")` でボタンを一気に押してくれるのが非常に便利に感じる。

(ボタンの取得の仕方とかは、今のところ findViewById でとってくる `Button button = (Button) activity.findViewById(com.example.testapp.R.id.login_button)` 方法しかしらないので)

また、スクリーンショット機能なども実装されており、メソッドを呼び出すだけでSDカードに入れてくれる！便利！

### Scirocco - 現Scirocco for WebDriver

- <del>公式 [scirocco - A UI Test Automation Tool for Android - Google Project Hosting](http://code.google.com/p/scirocco/)</del>
  - <del>コミットログ日付 2011-05-14 - **2011-12-06** </del>
- 公式 [Open Source Library｜Sonix](http://www.sonix.asia/service/library) / [Scirocco](http://www.sonixlabs.com/scirocco-jp/)
  - コミットログ日付  2012-07-31 - **2012-09-27**
  - 2012年 [Scirocco 開発メモ｜Android Wiki for Developers](http://wiki.android-fun.jp/?Scirocco%20%E9%96%8B%E7%99%BA%E3%83%A1%E3%83%A2)
  - 2012年 [sciroccoを触ってみた。(Android自動テストツール) - くのっふむ(knnfm)](http://d.hatena.ne.jp/knnfm/20120118/1326866266)
  - 2011年 [AndroidのUI自動テストツール Scirocco 触ってみた。 - しかじろうがプログラム作るよ！](http://d.hatena.ne.jp/re_shikajiro/20110531/1306848452)

※ Google Project Hosting 版は **Development Discontinued** とされており、今はソニックスが管理しているみたい。また、旧版は `Scirocco` , ソニックス版は `Scirocco WebDriver` となっておりアーキテクチャが変わっているらしい。

`robotium`, `scirocco plug-in` , `scirocco TestManagementSystem` から成り立つテストツール。

基本的には `robotium` に機能がプラスされたツールなんだろう。テストのレポートやスクリーンショットがとれる模様。(前述のとおり、 スクリーンショットは `robotium` でも(今は？)できる様子)

けど、 `robotium` が猛烈に更新されている一方で、こっちは更新が止まっている(遅れている？)ようなので、 `Scirocco` は深追いせずこれで終わり。

### MonkeyRunner

- AndroidSDKに同梱されている ( `SDK_ROOT\sdk\tools\monkeyrunner.bat` )
  - 2012年 [ここ数ヶ月、MonkeyRunnerを仕事で使ってみて思ったこと - 見習いプログラマーの修行日記](http://d.hatena.ne.jp/rukiadia0401/20121207/1354896442)
  - 2012年 [なめこMonkeyRunner（その1） - ReDo](http://greety.sakura.ne.jp/redo/2012/02/monkeyrunner.html)
  - 2011年 [Androiod端末のテストツール「monkeyrunner」-基本-](http://android-test-blog.blogspot.jp/2011/09/androiodmonkeyrunner.html)
  - 2011年 [monkeyrunner自動化計画(1): 16分の11拍子](http://kopanitsa.seesaa.net/article/195231645.html)
  - 2010年 [Y.A.M の 雑記帳: Android　monkeyrunner を訳して試してみた。](http://y-anz-m.blogspot.jp/2010/12/androidmonkeyrunner.html)

これだけ他のツールとちょっと毛色が違う感じがする。

Pythonで書ける、画面のボタン選択などは **座標指定** 。(座標を調べる事自体もめんどいし、複数端末あると端末分スクリプト作らなきゃいけない？)

画面のいろいろなところをやみくもにぽちぽちするテストもできる。

ちょっと使ってみよう。…と思ったけどなんかダメだった。

#### 前準備

まず、 `SDK_ROOT\sdk\tools\monkeyrunner.bat` を実行してみる。 Jython で実行するようなので Java (は入っていると思うが) と Python が必要？

{% highlight console %}
$ monkeyrunner.bat
Jython 2.5.0 (Release_2_5_0:6476, Jun 16 2009, 13:33:26)
[Java HotSpot(TM) Client VM (Oracle Corporation)] on java1.7.0_17
>>>
{% endhighlight %}

#### シナリオ作成

- [monkeyrunner｜Android Developers](http://developer.android.com/tools/help/monkeyrunner_concepts.html)

上記の Simple monkeyrunner Program をそのまま流し込んでみようと思ったんだけど、2行目でエラー…。

{% highlight console %}
$ monkeyrunner.bat
Jython 2.5.0 (Release_2_5_0:6476, Jun 16 2009, 13:33:26)
[Java HotSpot(TM) Client VM (Oracle Corporation)] on java1.7.0_17
>>> from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice
>>> device = MonkeyRunner.waitForConnection()
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] Adb rejected adb port forwarding command: cannot bind socket
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice]com.android.ddmlib.AdbCommandRejectedException: cannot bind socket
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.ddmlib.AdbHelper.createForward(AdbHelper.java:545)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.ddmlib.Device.createForward(Device.java:481)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.chimpchat.adb.AdbChimpDevice.createManager(AdbChimpDevice.java:126)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.chimpchat.adb.AdbChimpDevice.<init>(AdbChimpDevice.java:72)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.chimpchat.adb.AdbBackend.waitForConnection(AdbBackend.java:122)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.chimpchat.ChimpChat.waitForConnection(ChimpChat.java:91)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.monkeyrunner.MonkeyRunner.waitForConnection(MonkeyRunner.java:75)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at java.lang.reflect.Method.invoke(Method.java:601)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.PyReflectedFunction.__call__(PyReflectedFunction.java:175)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.PyReflectedFunction.__call__(PyReflectedFunction.java:190)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.PyObject.__call__(PyObject.java:381)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.PyObject.__call__(PyObject.java:385)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.pycode._pyx2.f$0(<stdin>:1)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.pycode._pyx2.call_function(<stdin>)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.PyTableCode.call(PyTableCode.java:165)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.PyCode.call(PyCode.java:18)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.Py.runCode(Py.java:1197)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.core.Py.exec(Py.java:1241)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.util.PythonInterpreter.exec(PythonInterpreter.java:147)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.util.InteractiveInterpreter.runcode(InteractiveInterpreter.java:89)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.util.InteractiveInterpreter.runsource(InteractiveInterpreter.java:70)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.util.InteractiveInterpreter.runsource(InteractiveInterpreter.java:46)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.util.InteractiveConsole.push(InteractiveConsole.java:110)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.util.InteractiveConsole.interact(InteractiveConsole.java:90)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at org.python.util.InteractiveConsole.interact(InteractiveConsole.java:60)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.monkeyrunner.ScriptRunner.console(ScriptRunner.java:193)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.monkeyrunner.MonkeyRunnerStarter.run(MonkeyRunnerStarter.java:73)
130828 20:34:40.534:S [main] [com.android.chimpchat.adb.AdbChimpDevice] at com.android.monkeyrunner.MonkeyRunnerStarter.main(MonkeyRunnerStarter.java:189)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
          at com.google.common.base.Preconditions.checkNotNull(Preconditions.java:191)
          at com.android.chimpchat.adb.AdbChimpDevice.<init>(AdbChimpDevice.java:74)
          at com.android.chimpchat.adb.AdbBackend.waitForConnection(AdbBackend.java:122)
          at com.android.chimpchat.ChimpChat.waitForConnection(ChimpChat.java:91)
          at com.android.monkeyrunner.MonkeyRunner.waitForConnection(MonkeyRunner.java:75)
          at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
          at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
          at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
          at java.lang.reflect.Method.invoke(Method.java:601)

java.lang.NullPointerException: java.lang.NullPointerException
{% endhighlight %}

- [android - Why does MonkeyRunner.waitForConnection() error "Adb rejected adb port forwarding command: cannot bind socket" - Stack Overflow](http://stackoverflow.com/questions/6950223/why-does-monkeyrunner-waitforconnection-error-adb-rejected-adb-port-forwardin)

`adb kill-server` してみては？という記事は見つけたけど特に変わらず…。

### Appium

- 公式 [Appium: Mobile App Automation Made Awesome.](http://appium.io/)
  - コミットログ日付 2013-06-03 - 2013-08-07
  - ファイル置場 https://bitbucket.org/appium/appium.app/downloads
  - 2013年 [Appiumを使ってスマートフォンアプリのテストを自動化する - Python編 - Qiita [キータ]](http://qiita.com/skinoshita/items/211ca23edbb5f2776771)
  - 2013年 [Android - Appiumを使ってスマートフォンアプリのテストを自動化する - 概要編 - Qiita [キータ]](http://qiita.com/skinoshita/items/fab6373f95836eceb177)
  - 2013年 [AppiumでiOSを自動で受け入れテスト Rspecでテストできるよ！ - コンユウメモ](http://konyu.hatenablog.com/entry/2013/06/08/011118)

Selenium ライクで **iOS, Android 両方** のテストを作成できる。

またテストコードは Node.js, Python, PHP, Ruby, Java などで書けるようだ。

ただし、以下のような依存がある。

> **Requirements**
>
> General:
>
> - Mac OS X 10.7 or higher, 10.8 recommended (Linux OK for Android-only; support for Windows is in "beta")
> - Node and npm (brew install node) (Node must be >= v0.8)
>
>For iOS automation:
>
> - XCode
> - Apple Developer Tools (iPhone simulator SDK, command line tools)
>
>For Android automation:
>
> - Android SDK API >= 17

今のところ **Windows は beta 版** のようなので、今回は試用見送り。あと  **Android API 17 以上(= 4.2以上)** というのも意外とハードルが高い。

iOSがメインで、Androidもテストできますよ、的な感じなのかも。

### Spoon

- 公式 [Spoon](http://square.github.io/spoon/)
  - コミットログ日付 2012-07-10 - 2013-07-08
  - 2013年 [Androidの実機テストを簡単にする「Spoon」を使ってみた-Sample編- - hentekoのdev日記](http://henteko07.hatenablog.com/entry/2013/03/24/190951)

Android 4.1 以上必須、実行に maven 推奨。

日本語の情報は少ない。

### Selendroid

- 公式 [Selendroid](http://dominikdary.github.io/selendroid/)
  - コミットログ日付 2013-01-07 - 2013-08-22
  - 2013年 [Selendroid　Android自動テストツールの　スケーラビリティー - つれづれなるままに。](http://dolias2010.hatenablog.com/entry/2013/06/26/002302)
  - 2013年 [Android の　自動テストツール - つれづれなるままに。](http://dolias2010.hatenablog.com/entry/20130604/1370357854)

Selenium for Android Apps という事で Android ネイティブアプリや Web ビューのテストを Selenium で書ける？

Mac か Linux で動作確認。 **Windows 版は not offially supported** でいくつか問題あり。

日本語の情報は少ない。

### uiautomator

はてブコメントや Twiter にて言及いただいたので調査。抜けていたのは、単純に知らなかったからです…。

- AndroidSDKに同梱されている ( `SDK_ROOT\sdk\tools\uiautomatorviewer.bat` )
  - 2013年 [2.11. テスト ・ mixi-inc/AndroidTraining Wiki ・ GitHub](https://github.com/mixi-inc/AndroidTraining/wiki/2.11.-%E3%83%86%E3%82%B9%E3%83%88)
  - 2012年 [uiautomatorを試してみた #android_tec - やらなイカ？](http://nowsprinting.hatenablog.com/entry/2012/11/22/235609)
  - 2012年 [[Android] はじめてのuiautomator - adakoda](http://www.adakoda.com/adakoda/2012/12/android-uiautomator-2.html)
  - 2012年 [Android APIレベル17から使えそうな、UI Automator Testについて調べてみた(その１) - Hack the World!](http://d.hatena.ne.jp/graceful_life/20121021/1350843227)

`Monkeyrunner` と同じ場所に入っていた。

- AndroidSDK 21 でサポートされた
- Android 4.1 以降で動作？(サポートされているのが 4.1 以降？)
- これは `adb shell` からたたく感じのツールみたい

ちょっとさわってみようと思ったが、これもかなり苦戦する。挙句動かせないという。

AndroidSDK に同梱されているツールは一筋縄で動かないなぁ。

#### 前準備

- テスト用プロジェクト右クリックし、 `Properties -> Java Build Path -> Add External JARs` から `SDK_ROOT\sdk\platforms\android-17\uiautomator.jar` を追加する
- テストクラスを `UIAutomatorTestCase` で extend する

#### シナリオ作成

- [uiautomator｜Android Developers](http://developer.android.com/tools/help/uiautomator/index.html)

UIxxx クラスで端末を操作していく。上記のサイトを参考に…。

{% highlight java %}
public class LoginActivityUITest extends UiAutomatorTestCase {
  public void testHelloWorld() throws Exception {
    getUiDevice().pressHome();

    UiObject allAppsButton = new UiObject(new UiSelector().description("アプリ"));
    allAppsButton.clickAndWaitForNewWindow();
    UiObject appsTab = new UiObject(new UiSelector().text("アプリ"));
    appsTab.click();
  }
}
{% endhighlight %}

#### 実行

ただ JUnit 実行すればいいってわけじゃないらしい。結構めんどい。

##### ビルドする

`SDK_ROOT\sdk\tools\` 下にある `android.bat` を使ってビルド。

{% highlight console %}
$ android.bat create uitest-project -n hoge -t x -p .
{% endhighlight %}

それぞれの引数はこう。

{% highlight console %}
Options:
  -p --path    : The new project's directory. [required]
  -n --name    : Project name.
  -t --target  : Target ID of the new project. [required]
{% endhighlight %}

`--target` は `android.bat list` コマンドで取得できる。(ずっと API レベルのことだと思って 17 とか指定していたら `Error: Target id is not valid. Use 'android.bat list targets' to get the target ids.` エラーで死んでた)

{% highlight console %}
$ android list
Available Android targets:
----------
(略)
----------
id: 6 or "android-17"
     Name: Android 4.2.2
     Type: Platform
     API level: 17
     Revision: 2
     Skins: HVGA, QVGA, WQVGA400, WQVGA432, WSVGA, WVGA800 (default), WVGA854, WXGA720, WXGA800, WXGA800-7in
     ABIs : armeabi-v7a
Available Android Virtual Devices:
    Name: test
    Path: C:\USER_PROFILE\.android\avd\test.avd
  Target: Android 3.2 (API level 13)
     ABI: armeabi
    Skin: 480x854
Snapshot: true
{% endhighlight %}

実行すると `build.xml` ができる。

{% highlight console %}
$ android.bat create uitest-project -n hoge -t 6 -p C:\hoge
Added file C:\hoge\build.xml
{% endhighlight %}

`ant build` して `bin` 下にできる jar ファイルを回収する

{% highlight console %}
$ C:\apache-ant-1.9.2\bin\ant build
Buildfile: C:\hoge\build.xml

-check-env:
 [checkenv] Android SDK Tools Revision 21.1.0
 [checkenv] Installed at SDK_ROOT\sdk

-build-setup:
     [echo] Resolving Build Target for hoge...
[getuitarget] Project Target:   Android 4.2.2
[getuitarget] API level:        17
     [echo] ----------
     [echo] Creating output directories if needed...

-pre-compile:

compile:

-post-compile:

-dex:
      [dex] input: C:\hoge\bin\classes
      [dex] Converting compiled files and external libraries into C:\hoge\bin\classes.dex...

-post-dex:

-jar:
      [jar] Building jar: C:\hoge\bin\hoge.jar

-post-jar:

build:

BUILD SUCCESSFUL
Total time: 4 seconds
{% endhighlight %}

##### 転送してテスト実行

次は `adb` コマンドで 今作った jar ファイルを端末に転送する。

{% highlight console %}
$ pwd
SDK_ROOT\sdk\platform-tools
$ adb.exe push C:\hoge\hoge.jar /data/local/tmp
463 KB/s (4271 bytes in 0.009s)
{% endhighlight %}

そして実行…だけど permission denied ？？

{% highlight console %}
$ adb.exe shell uiautomator runtest hoge.jar -c com.example.test
uiautomator: permission denied
{% endhighlight %}

- [testing - Cannot run android ui tests from command line - Stack Overflow](http://stackoverflow.com/questions/15949907/cannot-run-android-ui-tests-from-command-line)

権限とかも、特に間違ってないみたいなんだけど…。

{% highlight console %}
$ ls -l /data/local/tmp/*.jar
ls -l /data/local/tmp/*.jar
-rw-rw-rw- shell    shell        4271 2013-09-02 20:58 hoge.jar
{% endhighlight %}

とりあえず、用意が相当めんどくさいということはわかった。

それを補って余りある API が提供されているのだろうか…。

## おまけ

Android API レベルとOSとリリース日の対応のメモ。<del>裏をとるのがめんどいので</del>おまけなので、 Wikipedia 情報を全面的に信頼する。

- [Android - Wikipedia](http://ja.wikipedia.org/wiki/Android#.E3.83.90.E3.83.BC.E3.82.B8.E3.83.A7.E3.83.B3_2)
- [Androidのバージョン履歴 - Wikipedia](http://ja.wikipedia.org/wiki/Android%E3%81%AE%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E5%B1%A5%E6%AD%B4)

OS                   |API レベル|コードネーム    |リリース
---------------------|----------|----------------|------------------
Android 4.3          |18        |JellyBean       |2013/07/24
Android 4.2          |17        |JellyBean       |2012/11/13
Android 4.1          |16        |JellyBean       |2012/06/27
Android 4.0.3 - 4.0.4|15        |IceCreamSandwich|2012/03/28(4.0.4)
Android 4.0 - 4.0.2  |14        |IceCreamSandwich|2011/10/18
Android 3.2          |13        |Honeycomb       |2011/07/15
Android 3.1          |12        |Honeycomb       |2011/05/10
Android 3.0          |11        |Honeycomb       |2011/02/22
Android 2.3.3 - 2.3.7|10        |Gingerbread     |2011/09/20(2.3.7)
Android 2.3 - 2.3.2  |9         |Gingerbread     |2010/12/06(2.3)
Android 2.2          |8         |Froyo           |2010/05/21
Android 2.1          |7         |Eclair          |2010/01/12
Android 2.0.1        |6         |Eclair          |2009/12/03
Android 2.0          |5         |Eclair          |2009/10/26
Android 1.6          |4         |Donut           |2009/09/15
Android 1.5          |3         |Cupcake         |2009/04/30
Android 1.1          |2         |-               |2009/02/09
Android 1.0          |1         |-               |2008/09/23
