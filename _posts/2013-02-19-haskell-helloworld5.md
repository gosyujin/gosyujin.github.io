---
layout: post
title: "すごいHaskellたのしく学ぼうでHaskellことはじめ4"
description: ""
category: 
tags: [Haskell]
---

## 前回までのあらすじ

[すごいHaskellたのしく学ぼうでHaskellことはじめ3](http://gosyujin.github.com/2013/02/04/haskell-helloworld4/)

なんとなーく再帰は書けたかなー？というレベル。

この先生きのこれるのか……。

## 参考

- すごいHaskellたのしく学ぼう

## 5章 高階関数

### カリー化

- Haskellでは **すべての関数が引数を一つだけとる** 事になっている。
  - ……んでも今まで普通に二つとか引数とってなかったっけ？ `max` とか

#### max関数

本書より、 `max 4 5` の場合……。

- はじめに `max 4` が適用される
- `max 4` の返り値は `5 に適用するための別の関数`
- `別の関数 5` が適用され、最終的な値が返る

ふーむ……？

max関数の型はこう。

{% highlight haskell %}
Prelude> :t max
max :: Ord a => a -> a -> a
{% endhighlight %}
こう書く事もできる。 `a型の値を引数にとり、a型の値を返す`
{% highlight haskell %}
max :: Ord a => a -> ( a -> a )
{% endhighlight %} 

関数を本来より少ない引数で呼び出すことを `部分適用する` という。 `部分適用` すると、関数をその場で作りだし、それを他の関数に渡せる。

それを踏まえて、max関数。

- はじめに `max 4` が適用される (一つ目のa)
- `max 4` の返り値は **引数を一つとって関数を返す関数** となる
 ( ( a -> a ) の部分)
- **引数を一つとって関数を返す関数** に5が適用され、最終的な値が返る ( かっこの中の a -> a )

これらから、部分適用できる、というのは何となくだけどわかった。これはかけるのだ。

{% highlight haskell %}
Prelude> let max' x = max 4 x
Prelude> :t max'
max' :: (Num a, Ord a) => a -> a
Prelude> max' 5
5
{% endhighlight %} 

これがわからない。

{% highlight haskell %}
Prelude> let max'' = max 4
Prelude> :t max''
max'' :: Integer -> Integer
Prelude> max'' 5
5
{% endhighlight %} 

やっていることは上と等価なはずなんだけど、関数定義の部分に変数xがいない。

max 4 の返り値が **引数を一つとって関数を返す関数** であるから、max'' も引数を一つとれるということ？

### セクション

中置関数(divとか)も部分適用ができる。

ん？カリー化どこいったの？

カリー化=部分適用……ではないんだよね？ - [カリー化談義 - あどけない話](http://d.hatena.ne.jp/kazu-yamamoto/20110906/1315279311)

ともあれ、中置関数はこう書く。かっこでくくって部分適用したい方の引数に値を書く。

{% highlight haskell %}
divideByTen  = (`div` 10)
divideByTen' = (10 `div`)
{% endhighlight %}

{% highlight haskell %}
*Main> divideByTen 200 # 200 / 10
20
*Main> divideByTen 10 # 10 / 10
1
*Main> divideByTen' 2 # 2 / 10
5
*Main> divideByTen' 10 # 10 / 10
1
{% endhighlight %}

ただし、引き算を使うときだけ注意しなければならない。 `(-4)` は `マイナス4` として扱われる。(引きたい時は `subtract` 関数を使う)

### 関数を表示する

これがどうなのか知りたかった！……んだけど「Show型クラスのインスタンスでないとエラーとなる」だって。

結局「その関数」(今回はdiv)が引数をどう取るか、部分適用して今どういう状態になっているのか(本書の言い方だと、どんな小さい工場になっているか)知らないと、部分適用しているかどうかってわからないって事？

うーん。

### 高階実演

Haskellでは関数も引数にとれる。同じ関数を二回適用する。

{% highlight haskell %}
applyTwice f x = f (f x)
{% endhighlight %}

{% highlight haskell %}
*Main> applyTwice tail [1,2,3,4]
[3,4]
{% endhighlight %}

`f (f x) -> f (tail [1,2,3,4]) -> f ([2,3,4]) -> tail [2,3,4] -> [3,4]`

ってことかな。

{% highlight haskell %}
*Main> applyTwice (++ "Hoge") "A"
"AHogeHoge"

*Main> applyTwice ("Hoge" ++) "A"
"HogeHogeA"
{% endhighlight %}

こういうのに対しては部分適用が使われている。

`f (f x) -> f ((++ "Hoge") "A" -> f ("AHoge") -> (++ "Hoge") "AHoge" -> "AHogeHoge"`

こういうことか！順番あってる？

#### zipWith

こんな関数。1つの関数と2つのリストを引数に持ち、リストの各要素に関数を適用する。

{% highlight haskell %}
Prelude> zipWith (+) [1,2,3,4] [6,7,8,9]
[7,9,11,13]
{% endhighlight %}

{% highlight haskell %}
zipWith' _ [] _ = []
zipWith' _ _ [] = []
zipWith' f (x:xs) (y:ys) = f x y : zipWith' f xs ys
{% endhighlight %}

#### flip

これも関数と2つの値をとる。で、値の順番を入れ替える。

{% highlight haskell %}
*Main> flip (div) 2 0
0
*Main> flip (div) 0 2
*** Exception: divide by zero
*Main> flip (++) [2] [1]
[1,2]
*Main> flip (++) [1] [2]
[2,1]
{% endhighlight %}

{% highlight haskell %}
flip' f x y = f y x
{% endhighlight %}

んー何となく書けたんだけど、解説がわからないぞ……。(解説ではxとyが逆になってる)

> この新しいバージョンのflip' では、関数がカリー化されていることをうまく使っています。flip' f を引数y とx なしで呼び出したら、2 つの引数を取る、引数の入れ替わったf が返るでしょう。

そうなの？

型を調べてみる。

{% highlight haskell %}
*Main> :t flip'
flip' :: (t1 -> t2 -> t) -> t2 -> t1 -> t
{% endhighlight %}

あ、わかったかも。並べて、

{% highlight haskell %}
flip' :: (t1 -> t2 -> t) -> t2 -> t1 -> t
flip' f x y = f y x
{% endhighlight %}

- 最初の引数(f)は `引数を二つ(t1, t2)をとり、関数(t)を返す関数` `(div) y x`
- 最初の引数(f)に次の引数(x / t2)を適用すると `最初の引数(f)に引数t2を適用した関数を返す関数` を返す `(div) y 0`
- `最初の引数(f)に引数t2を適用した関数を返す関数` に次の次の引数(y /t1)を適用すると `結果をshowする関数？` を返す？ `(div) 2 0` = 0

……？

あれ？違うっぽいな……。 

**続く！**