---
layout: post
title: "Androidアプリのインストール、起動方法によってIntentのタイプが微妙に変わる件"
description: ""
category:
tags: [Java, Android]
---

## あらすじ

Androidアプリにおいて、Eclipseからビルドしていた時は想定通り動いていたのに、リリース署名をしたアプリ(apkファイル)をインストールした場合だけ動作が想定していないものになった。

具体的には、Activityがむちゃくちゃたまる現象が起こるということで非常に困った。

## 結論

起動のさせ方により、起動時のIntentフラグが変わる。これはAndroid内部で知らぬ間にやられてしまう。

onCreate時などでIntentのフラグをチェックして何とかするしかない。

## 環境

- AndroidDeveloperTools Build: v21.1.0-569685

### ソースの中身

- メインのActivityには `action.Main` と `category.LAUNCHER` しか設定していない。
  - AndroidManifest.xmlはプロジェクト作成時ほぼそのまま

{% highlight xml %}
  <uses-sdk
    android:minSdkVersion="13"
    android:targetSdkVersion="14" />

  <application
    android:allowBackup="true"
    android:icon="@drawable/ic_launcher"
    android:label="@string/app_name"
    android:theme="@style/AppTheme" >
    <activity
      android:name="com.example.testproject.MainActivity"
      android:label="@string/app_name" >
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />

        <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>
    </activity>
    (略)
{% endhighlight %}

- FLAG設定は特に記載せず
  - メインのActivity(MainActivity.java)もほぼそのまま

{% highlight java %}
public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      setContentView(R.layout.activity_main);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
       getMenuInflater().inflate(R.menu.main, menu);
       return true;
    }
}
{% endhighlight %}

単純にHelo Worldを表示するだけのサンプルプログラム。

## 現象

**特定の手順** を踏んだ時だけ MainActivity のスタックが溜まりまくり、Hello World画面→Hello World画面→Hello World画面→Hello World画面...とバックキーを押しまくっても一向にホーム画面が現れなくなる。

また、以下のような状況でもある。

- この現象は起こらない時は全然起こらないし、起こったと思ったらすぐなおることもある
- Eclipse経由でビルドしていた時はなんともなかったのに、apk経由でインストールした途端急に起こり始めた

### 再現性調査

とりあえずいろいろな状況で `adb.exe shell dumpsys activity activities` を使いタスクのHistを確認しまくってみた。

以下は正常時のHist。このMainActivityが一個だけ。

{% highlight console %}
* TaskRecord{418cbab0 #42 A com.example.testproject}
  affinity=com.example.testproject
  intent={act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=com.example.testproject/.MainActivity bnds=[120,254][240,404]}
  realActivity=com.example.testproject/.MainActivity
  * Hist #1: ActivityRecord{41448a70 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10064 app=ProcessRecord{41545a80 23603:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=com.example.testproject/.MainActivity bnds=[120,254][240,404] }
      frontOfTask=true task=TaskRecord{418cbab0 #42 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{418cbab0 #42 A com.example.testproject}
  TaskRecord{418cbab0 #42 A com.example.testproject}
    Run #1: ActivityRecord{41448a70 com.example.testproject/.MainActivity}
  mResumedActivity: ActivityRecord{41448a70 com.example.testproject/.MainActivity}
  mFocusedActivity: ActivityRecord{41448a70 com.example.testproject/.MainActivity}
* Recent #0: TaskRecord{418cbab0 #42 A com.example.testproject}
  affinity=com.example.testproject
  intent={act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=com.example.testproject/.MainActivity bnds=[120,254][240,404]}
  realActivity=com.example.testproject/.MainActivity
  intent={act=android.intent.action.DELETE dat=package:com.example.testproject#com.example.testproject.MainActivity flg=0x10800000 cmp=com.android.packageinstaller/.UninstallerActivity}
{% endhighlight %}

溜まりまくる場合のHist。MainActivityがやまほど生まれてる。

{% highlight console %}
* TaskRecord{41446350 #45 A com.example.testproject}
  affinity=com.example.testproject
  intent={act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.example.testproject cmp=com.example.testproject/.MainActivity}
  realActivity=com.example.testproject/.MainActivity
  * Hist #8: ActivityRecord{416dcb20 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10064 app=ProcessRecord{414f9d80 27069:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10600000 cmp=com.example.testproject/.MainActivity bnds=[0,405][120,555] }
      frontOfTask=false task=TaskRecord{41446350 #45 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{41446350 #45 A com.example.testproject}
  * Hist #7: ActivityRecord{41604ef8 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10064 app=ProcessRecord{414f9d80 27069:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10600000 cmp=com.example.testproject/.MainActivity bnds=[0,405][120,555] }
      frontOfTask=false task=TaskRecord{41446350 #45 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{41446350 #45 A com.example.testproject}
  * Hist #6: ActivityRecord{41562120 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10064 app=ProcessRecord{414f9d80 27069:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10600000 cmp=com.example.testproject/.MainActivity bnds=[0,405][120,555] }
      frontOfTask=false task=TaskRecord{41446350 #45 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{41446350 #45 A com.example.testproject}
  * Hist #5: ActivityRecord{41451680 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10064 app=ProcessRecord{414f9d80 27069:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10600000 cmp=com.example.testproject/.MainActivity bnds=[0,405][120,555] }
      frontOfTask=false task=TaskRecord{41446350 #45 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{41446350 #45 A com.example.testproject}
  * Hist #4: ActivityRecord{41554ec0 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10064 app=ProcessRecord{414f9d80 27069:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10600000 cmp=com.example.testproject/.MainActivity }
      frontOfTask=false task=TaskRecord{41446350 #45 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{41446350 #45 A com.example.testproject}
  * Hist #3: ActivityRecord{416f12c0 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10064 app=ProcessRecord{414f9d80 27069:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10600000 cmp=com.example.testproject/.MainActivity }
      frontOfTask=false task=TaskRecord{41446350 #45 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{41446350 #45 A com.example.testproject}
  * Hist #2: ActivityRecord{413febd0 com.example.testproject/.MainActivity}
      packageName=com.example.testproject processName=com.example.testproject
      launchedFromUid=10078 app=ProcessRecord{414f9d80 27069:com.example.testproject/10159}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.example.testproject cmp=com.example.testproject/.MainActivity }
      frontOfTask=true task=TaskRecord{41446350 #45 A com.example.testproject}
      taskAffinity=com.example.testproject
      realActivity=com.example.testproject/.MainActivity
      base=/data/app/com.example.testproject-1.apk/data/app/com.example.testproject-1.apk data=/data/data/com.example.testproject
      thumbHolder=TaskRecord{41446350 #45 A com.example.testproject}
  TaskRecord{41446350 #45 A com.example.testproject}
    Run #8: ActivityRecord{416dcb20 com.example.testproject/.MainActivity}
  TaskRecord{41446350 #45 A com.example.testproject}
    Run #6: ActivityRecord{41604ef8 com.example.testproject/.MainActivity}
    Run #5: ActivityRecord{41562120 com.example.testproject/.MainActivity}
    Run #4: ActivityRecord{41451680 com.example.testproject/.MainActivity}
    Run #3: ActivityRecord{41554ec0 com.example.testproject/.MainActivity}
    Run #2: ActivityRecord{416f12c0 com.example.testproject/.MainActivity}
    Run #1: ActivityRecord{413febd0 com.example.testproject/.MainActivity}
  mResumedActivity: ActivityRecord{416dcb20 com.example.testproject/.MainActivity}
  mFocusedActivity: ActivityRecord{416dcb20 com.example.testproject/.MainActivity}
  * Recent #0: TaskRecord{41446350 #45 A com.example.testproject}
    affinity=com.example.testproject
    intent={act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 pkg=com.example.testproject cmp=com.example.testproject/.MainActivity}
    realActivity=com.example.testproject/.MainActivity
    intent={act=android.intent.action.DELETE dat=package:com.example.testproject#com.example.testproject.MainActivity flg=0x10800000 cmp=com.android.packageinstaller/.UninstallerActivity}
{% endhighlight %}

### 再現方法

以下の操作で再現がとれた。

1. **apkを作成する**
1. apkをAndroid端末に送る
1. ファイルマネージャアプリなどからapkを選択しインストールする
1. 「アプリケーションをインストールしました 完了/開く」画面で **「開く」** を選択しアプリを起動
1. ホームキーでホーム画面に戻る( **バックキーでアプリ終了** させた場合は正常時の挙動に移行)
1. 再びアプリ起動
1. ホームキー、アプリ起動を繰り返す

どうやら **「apk経由でインストール」** し、 **「そのままアプリを開いた」** ときだけ変になる模様。

そして上記のdumpファイルから正常時とおかしい時を比較すると、 `Intentのフラグ` 設定が異なっているみたい。

### ソース修正

MainActivityにonResumeメソッドとIntentのフラグを出力するToastを追加してみた。

dumpファイルのフラグは16進で出力されているが、ソースからフラグを取得してみる( `getIntent().getFlags()` )と10進で格納されているようなので、16進に変換している。(268435456→10000000)

{% highlight java %}
    @Override
    protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
+     Toast.makeText(this, "FLAG:" + Integer.toHexString(getIntent().getFlags()), Toast.LENGTH_SHORT).show();
      setContentView(R.layout.activity_main);
   }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
      getMenuInflater().inflate(R.menu.main, menu);
      return true;
    }

+   @Override
+   protected void onResume() {
+     super.onResume();
+     Toast.makeText(this, "FLAG:" + Integer.toHexString(getIntent().getFlags()), Toast.LENGTH_SHORT).show();
+   }
{% endhighlight %}

すると、以下のようなフラグが出力された。dumpを見ても同じ値になっているな。

### 操作時のフラグ

インストール方法|操作                                        |フラグ
----------------|--------------------------------------------|-----------
正常時          |                                            |
----------------|--------------------------------------------|-----------
Eclipse Run     |ビルド後起動                                |`10000000`
                |バックキーでいったんアプリ終了→アプリ起動  |`10020000`
apkインストール |インストール後「完了」→アプリ起動          |`10020000`
                |バックキーで終了後タスク履歴から呼びだした時|`10304000`
----------------|--------------------------------------------|----------
おかしい時      |                                            |
----------------|--------------------------------------------|----------
apkインストール |インストール後、即「開く」                  |`10000000`
                |その後、ホームキー→アプリ起動              |`10600000` ...

ふーむ。呼び方によってフラグの値が変わっている…。だが、そういうこともあるらしい。

- [とまと日記 android shell am コマンド](http://ahoworld.blog58.fc2.com/?m&no=378)

これがなんなのか…。javadocから照らし合わせてみよう。

### フラグ一覧(抜粋)

フラグ(16進) |ばらし  |フラグ(10進)|値
-------------|--------|------------|--------------------------------------
正常時       |        |            |
-------------|--------|------------|--------------------------------------
`10200000`   |10000000|268435456   | `FLAG_ACTIVITY_NEW_TASK`
             |00200000|002097152   | `FLAG_ACTIVITY_RESET_TASK_IF_NEEDED`
`10304000`   |10000000|268435456   | `FLAG_ACTIVITY_NEW_TASK`
             |00200000|002097152   | `FLAG_ACTIVITY_RESET_TASK_IF_NEEDED`
             |00100000|001048576   | `FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY`
             |00004000|000016384   |？
-------------|--------|------------|--------------------------------------
おかしい時   |        |            |
-------------|--------|------------|--------------------------------------
`10600000`   |10000000|268435456   | `FLAG_ACTIVITY_NEW_TASK`
             |00400000|004194304   | `FLAG_ACTIVITY_BROUGHT_TO_FRONT`
             |00200000|002097152   | `FLAG_ACTIVITY_RESET_TASK_IF_NEEDED`

- 参考: [Constant Field Values](http://www.androidjavadoc.com/2.3/constant-values.html#android.content.Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)

両者を比較すると、 apk経由のときだけ `FLAG_ACTIVITY_BROUGHT_TO_FRONT` というフラグがあるなー。なんじゃこりゃ。

- [Intent ｜ Android Developers](https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_BROUGHT_TO_FRONT)

> This flag is not normally set by application code, but set for you by the system as described in the launchMode documentation for the singleTask mode.

- [Androidメモ](http://www.saturn.dti.ne.jp/npaka/android/LaunchMode/)

> 既存アクティビティ(singleTask)を最前面に呼び出す。システムによって設定される。

やはり！Androidの中の人が勝手にセットしているっぽいなー。これが悪さをしているのか？

## 解決方法

`FLAG_ACTIVITY_BROUGHT_TO_FRONT` でググったらandroid group japanのメーリングリストが引っかかった！ほぼ同じ現象。

- [Re: [android-group-japan: 20121] apkインストー ル時のホームボタン挙動の変化について](http://www.mailinglistarchive.com/html/android-group-japan@googlegroups.com/2012-09/msg00445.html)

> ブラウザからinstallして起動したときと、ランチャーから起動した時では、
>
> 起動するときのIntentが微妙に異なります。
>
> その為、ランチャーから起動した場合の、「既に起動していたら二重起動しない」という
>
> 仕組みが動作しません。
>
> > この状態でapkを作成し、適当なサーバに配置した上で、ブラウザからインストールし、インストール完了時に「開く」を選んで、そのまま起動します。
> > Activity1の起動後、Activity2へ遷移します。
> > その後、ホームボタンでホーム画面へ移動し、アイコンをタップして復帰します。
>
> この時には、Activity stackは以下のようになっています。
>
> Activity1->Activity2->Activity1'
>
> 二重起動されたActivity1'では、起動IntentにFLAG_ACTIVITY_BROUGHT_TO_FRONTがセットされるようなので、

{% highlight java %}
protected void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
    finish();
    return;
  }
}
{% endhighlight %}

> のようにすると、所望の動作になると思います。

なるほど。今Activityにセットされているフラグに `FLAG_ACTIVITY_BROUGHT_TO_FRONT` が含まれていたら終われってことか。

確かにこれならHistも増えない。

…んでも、こんなケースまったく想定してなかったし、スマートフォンアプリにおけるテストで気を付けるところとか、本とかにまとまってないのかな。

みんなはどうやって要点抑えてるんだろう。社内ノウハウ集的なものがあるのかな？

---

以下、いろいろ考えた結果のボツ案。できるのかもしれないけどギブした。

- onCreate時にフラグを書きかえる
- Activity#onUserLeaveHint(ホームキータップ)時にフラグを書きかえ(これだとそのまま処理続けられるし) 
