---
layout: post
title: "Gatlingを使用してみた"
description: ""
category:
tags: [Scala]
---

## あらすじ

サーバーにリクエストをいっぱい投げて負荷をかけたい。(いわゆる弾投げ)

- WEB+DB-PRESS-Vol.83 Javaの鉱脈 Gatlingによる多彩で柔軟な負荷テスト
- [便利すぎる負荷試験テストツールGatlingの使い方~自力ソース編~ - Qiita](http://qiita.com/nii_yan/items/d7d0ea949abeab13aea7)
- [Scala 初心者が Gatling をぶっ放して負荷テストをやってみました - SHANON　Engineer's　Blog](http://shanon-tech.blogspot.jp/2015/10/scala-gatling.html)

## Gatlingとは

- 負荷テストツール
- 2011年頃から作成
- Scalaで実装されている
- **Scalaでテストケースを書く**
- ライバルはJMeter

## 実際に使う

- [Gatling Project, Stress Tool](http://gatling.io/#/resources/download)

からダウンロードできる。今回はzipでDLした。

- DLしたzipファイルを解凍、ディレクトリに移動し、適当なテストケースを作成する

```sh
cd gatling-charts-highcharts-bundle-2.2.1
vi user-files/simulations/computerdatabase/advanced/Sample.scala
```

- テストコードはサンプルを見ながら…scalaやったことないからちょっと難しい

```scala
import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._
class Sample extends Simulation {
  // プロトコルの定義
  val httpConf = http
    .baseURL("http://localhost:8080")
  // シナリオの定義
  val scn = scenario("Sample")
    .exec(http("sample_request")
      .get("/"))
    .pause(100 milliseconds)
  // シナリオの構成
  setUp(scn.inject(rampUsers(10) over(5 seconds)) .protocols(httpConf))
}
```

- `bin/gatling.sh` でテスト実行。他にもいくつかサンプルテストケースが列挙されるので、今回は自分で作った `Sample` `[0]` を選択

```
$ sh bin/gatling.sh 
GATLING_HOME is set to /Users/kk_Ataka/Downloads/gatling-charts-highcharts-bundle-2.2.1
Choose a simulation number:
     [0] Sample
     (略)
0
Select simulation id (default is 'sample'). Accepted characters are a-z, A-Z, 0-9, - and _

Select run description (optional)

Simulation Sample started...

================================================================================
2016-07-30 14:05:54                                           5s elapsed
---- Sample --------------------------------------------------------------------
[###########################################################--------       ] 80%
          waiting: 1      / active: 1      / done:8     
---- Requests ------------------------------------------------------------------
> Global                                                   (OK=9      KO=0     )
> sample_request                                           (OK=9      KO=0     )
================================================================================


================================================================================
2016-07-30 14:05:55                                           5s elapsed
---- Sample --------------------------------------------------------------------
[##########################################################################]100%
          waiting: 0      / active: 0      / done:10    
---- Requests ------------------------------------------------------------------
> Global                                                   (OK=10     KO=0     )
> sample_request                                           (OK=10     KO=0     )
================================================================================

Simulation Sample completed in 4 seconds
Parsing log file(s)...
Parsing log file(s) done
Generating reports...

================================================================================
---- Global Information --------------------------------------------------------
> request count                                         10 (OK=10     KO=0     )
> min response time                                      5 (OK=5      KO=-     )
> max response time                                     23 (OK=23     KO=-     )
> mean response time                                    13 (OK=13     KO=-     )
> std deviation                                          5 (OK=5      KO=-     )
> response time 50th percentile                         14 (OK=14     KO=-     )
> response time 75th percentile                         15 (OK=15     KO=-     )
> response time 95th percentile                         20 (OK=20     KO=-     )
> response time 99th percentile                         22 (OK=22     KO=-     )
> mean requests/sec                                      2 (OK=2      KO=-     )
---- Response Time Distribution ------------------------------------------------
> t < 800 ms                                            10 (100%)
> 800 ms < t < 1200 ms                                   0 (  0%)
> t > 1200 ms                                            0 (  0%)
> failed                                                 0 (  0%)
================================================================================

Reports generated in 0s.
Please open the following file: /Users/kk_Ataka/Downloads/gatling-charts-highcharts-bundle-2.2.1/results/sample-xxxxxxxxxxx/index.html
```

- 実行が終わったら `result` 下にレポートが出力されている

```
open results/sample-xxxxxxxxxxx/index.html
```

リクエスト間隔や数を変更するなら「シナリオの構成」部分に手を加えたら良い。

というような感じで、今回は単純なリクエストを送信するだけに使ったが、もっと凝った事ができるので、詳細はWEB+DB-PRESS-Vol.83を読む。
