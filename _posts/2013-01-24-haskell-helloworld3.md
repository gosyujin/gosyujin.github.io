---
layout: post
title: "すごいHaskellたのしく学ぼうでHaskellことはじめ"
description: ""
category: 
tags: [Haskell]
---
{% include JB/setup %}

## 3章 関数の構文

### パターンマッチ

- 関数の場合分け
- 上から順番に調べられる
- 全てに合致するパターンを最後に入れておくと吉

{% highlight haskell %}
lucky 7 = "SEVEN !"
lucky x = "Other Number"
{% endhighlight %}

{% highlight haskell %}
*Main> lucky 1
"Other Number"
*Main> lucky 7
"SEVEN !"
*Main> lucky 9
"Other Number"
{% endhighlight %}

上から順番なので、一行目と二行目をひっくり返すと、引数に7を渡しても "SEVEN !" が出力されなくなる。

### タプルのパターンマッチ

{% highlight haskell %}
addVectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)
{% endhighlight %}
{% highlight haskell %}
*Main> addVectors (1,3) (5,9)
(6,12)
{% endhighlight %}

### リストのパターンマッチ

`x:xs` … リストの先頭要素xと残りのxs(リスト `[1,2,3]` は `1:2:3:[]` と表せる)

{% highlight haskell %}
*Main> [1,2,3,4]
[1,2,3,4]
*Main> 1:[2,3,4]
[1,2,3,4]
{% endhighlight %}

それを踏まえてhead関数の独自実装。

- `error` はランタイムエラーを発生させる

{% highlight haskell %}
head' [] = error "Error Dayo"
head' (x:xs) = x
{% endhighlight %}

{% highlight haskell %}
*Main> head' "He is ..."
'H'
*Main> head' [3,2,4]
3
*Main> head' []
*** Exception: Error Dayo
*Main> head' ""
*** Exception: Error Dayo
{% endhighlight %}

上記のコードでは、 `xs` は一回も使っていない = どうでもいい値 なので `_` とする事もできる。

### as

- 引数をパターンマッチのパターンに分解するが、その値自体も使う場合
- パターンの前に `変数@` を追加

{% highlight haskell %}
firstLetter "" = "Empty"
firstLetter all@(x:xs) = "The first letter of " ++ all ++ " is " ++ [x]
{% endhighlight %}

{% highlight haskell %}
*Main> firstLetter "Watashi"
"The first letter of Watashi is W"
*Main> firstLetter ""
"Empty"
{% endhighlight %}

### ガード

- 場合分け
- if else のようなもの
- **ひとつ以上のスペース** でインデントする必要がある
- 上から順番に
- 全てキャッチするのは `otherwise`

{% highlight haskell %}
bmiTell bmi
 | bmi <= 18.5 = "Yase!"
 | bmi <= 25.0 = "Normal!"
 | bmi <= 30.0 = "Debuya!"
 | otherwise   = "Otherwise!"
{% endhighlight %}

{% highlight haskell %}
*Main> bmiTell 1
"Yase!"
*Main> bmiTell 19
"Normal!"
*Main> bmiTell 26
"Debuya!"
*Main> bmiTell 31
"Otherwise!"
{% endhighlight %}

### Where

BMIって「体重(kg) / (身長(m) ^ 2)」らしいので、上記の関数をこんな風に変えられる。

{% highlight haskell %}
bmiTell wei hei
 | wei / hei ^ 2 <= 18.5 = "Yase!"
 | wei / hei ^ 2 <= 25.0 = "Normal!"
 | wei / hei ^ 2 <= 30.0 = "Debuya!"
 | otherwise   = "Otherwise!"
{% endhighlight %}

{% highlight haskell %}
*Main> bmiTell 40 1.5
"Yase!"
*Main> bmiTell 50 1.5
"Normal!"
*Main> bmiTell 60 1.5
"Debuya!"
*Main> bmiTell 90 1.5
"Otherwise!"
{% endhighlight %}

ただし、上記のガード式だとBMI算出を無駄に繰り返している。whereを使って置き換える。

{% highlight haskell %}
bmiTell wei hei
 | bmi <= 18.5 = "Yase!"
 | bmi <= 25.0 = "Normal!"
 | bmi <= 30.0 = "Debuya!"
 | otherwise   = "Otherwise!"
 where bmi = wei / hei ^ 2
{% endhighlight %}

**同一パターンの中でしか使えない。**

{% highlight haskell %}
20 greet "Juan"     = hell ++ " Juan"
21 greet "Fernando" = hell ++ " Fernando"
22 greet name       = hell ++ " " ++ name
23  where hell = "Hell."
{% endhighlight %}

コンパイルすると20, 21行目でNot in scope。
{% highlight haskell %}
xxx.hs:20:20: Not in scope: `hell'

xxx.hs:21:20: Not in scope: `hell'
{% endhighlight %}

### let

- let ... in ...
- whereと似ている
- letは式、whereはそうじゃない

{% highlight haskell %}
cylinder r h =
 let sideArea = 2 * pi * r * h
     topArea  = pi * r ^ 2
 in  sideArea + 2 * topArea
{% endhighlight %}

{% highlight haskell %}
*Main> cylinder 4 3
175.92918860102841
{% endhighlight %}

### case

- case ... of ... -> ...
- caseも式

{% highlight haskell %}
head'' [] = error "Error"
head'' (x:_) = x

head''' xs = case xs of []    -> error "Error"
                        (x:_) -> x
{% endhighlight %}

{% highlight haskell %}
*Main> head'' [2,3,4,5]
2
*Main> head''' [2,3,4,5]
2
*Main> head'' []
*** Exception: Error
*Main> head''' []
*** Exception: Error
{% endhighlight %}
