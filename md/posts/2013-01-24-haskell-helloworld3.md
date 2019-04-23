---
layout: post
title: "すごいHaskellたのしく学ぼうでHaskellことはじめ2"
description: ""
category: 
tags: [Haskell]
old_url: http://d.hatena.ne.jp/kk_Ataka/20130125/1359093344
---

## 前回までのあらすじ

[すごいHaskellたのしく学ぼうでHaskellことはじめ](http://gosyujin.github.com/2013/01/21/haskell-helloworld2/)

GitHub Pagesの方にリンクを貼ってみよう。

## 参考

- すごいHaskellたのしく学ぼう

## 3章 関数の構文

### パターンマッチ

- 関数の場合分け
- 上から順番に調べられる
- 全てに合致するパターンを最後に入れておくと吉

```haskell
lucky 7 = "SEVEN !"
lucky x = "Other Number"
```

```haskell
*Main> lucky 1
"Other Number"
*Main> lucky 7
"SEVEN !"
*Main> lucky 9
"Other Number"
```

上から順番なので、一行目と二行目をひっくり返すと、引数に7を渡しても "SEVEN !" が出力されなくなる。

### タプルのパターンマッチ

```haskell
addVectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)
```
```haskell
*Main> addVectors (1,3) (5,9)
(6,12)
```

### リストのパターンマッチ

`x:xs` … リストの先頭要素xと残りのxs(リスト `[1,2,3]` は `1:2:3:[]` と表せる)

```haskell
*Main> [1,2,3,4]
[1,2,3,4]
*Main> 1:[2,3,4]
[1,2,3,4]
```

それを踏まえてhead関数の独自実装。

- `error` はランタイムエラーを発生させる

```haskell
head' [] = error "Error Dayo"
head' (x:xs) = x
```

```haskell
*Main> head' "He is ..."
'H'
*Main> head' [3,2,4]
3
*Main> head' []
*** Exception: Error Dayo
*Main> head' ""
*** Exception: Error Dayo
```

上記のコードでは、 `xs` は一回も使っていない = どうでもいい値 なので `_` とする事もできる。

### as

- 引数をパターンマッチのパターンに分解するが、その値自体も使う場合
- パターンの前に `変数@` を追加

```haskell
firstLetter "" = "Empty"
firstLetter all@(x:xs) = "The first letter of " ++ all ++ " is " ++ [x]
```

```haskell
*Main> firstLetter "Watashi"
"The first letter of Watashi is W"
*Main> firstLetter ""
"Empty"
```

### ガード

- 場合分け
- if else のようなもの
- **ひとつ以上のスペース** でインデントする必要がある
- 上から順番に
- 全てキャッチするのは `otherwise`

```haskell
bmiTell bmi
 | bmi <= 18.5 = "Yase!"
 | bmi <= 25.0 = "Normal!"
 | bmi <= 30.0 = "Debuya!"
 | otherwise   = "Otherwise!"
```

```haskell
*Main> bmiTell 1
"Yase!"
*Main> bmiTell 19
"Normal!"
*Main> bmiTell 26
"Debuya!"
*Main> bmiTell 31
"Otherwise!"
```

### Where

BMIって「体重(kg) / (身長(m) ^ 2)」らしいので、上記の関数をこんな風に変えられる。

```haskell
bmiTell wei hei
 | wei / hei ^ 2 <= 18.5 = "Yase!"
 | wei / hei ^ 2 <= 25.0 = "Normal!"
 | wei / hei ^ 2 <= 30.0 = "Debuya!"
 | otherwise   = "Otherwise!"
```

```haskell
*Main> bmiTell 40 1.5
"Yase!"
*Main> bmiTell 50 1.5
"Normal!"
*Main> bmiTell 60 1.5
"Debuya!"
*Main> bmiTell 90 1.5
"Otherwise!"
```

ただし、上記のガード式だとBMI算出を無駄に繰り返している。whereを使って置き換える。

```haskell
bmiTell wei hei
 | bmi <= 18.5 = "Yase!"
 | bmi <= 25.0 = "Normal!"
 | bmi <= 30.0 = "Debuya!"
 | otherwise   = "Otherwise!"
 where bmi = wei / hei ^ 2
```

**同一パターンの中でしか使えない。**

```haskell
greet "Juan"     = hell ++ " Juan"
greet "Fernando" = hell ++ " Fernando"
greet name       = hell ++ " " ++ name
 where hell = "Hell."
```

コンパイルすると20, 21行目でNot in scope。
```haskell
xxx.hs:20:20: Not in scope: `hell'

xxx.hs:21:20: Not in scope: `hell'
```

### let

- let ... in ...
- whereと似ている
- letは式、whereはそうじゃない

```haskell
cylinder r h =
 let sideArea = 2 * pi * r * h
     topArea  = pi * r ^ 2
 in  sideArea + 2 * topArea
```

```haskell
*Main> cylinder 4 3
175.92918860102841
```

### case

- case ... of ... -> ...
- caseも式

```haskell
head'' [] = error "Error"
head'' (x:_) = x

head''' xs = case xs of []    -> error "Error"
                        (x:_) -> x
```

```haskell
*Main> head'' [2,3,4,5]
2
*Main> head''' [2,3,4,5]
2
*Main> head'' []
*** Exception: Error
*Main> head''' []
*** Exception: Error
```
