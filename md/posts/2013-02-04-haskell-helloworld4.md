---
layout: post
title: "すごいHaskellたのしく学ぼうでHaskellことはじめ3"
description: ""
category: 
tags: [Haskell]
---

## 前回までのあらすじ

[すごいHaskellたのしく学ぼうでHaskellことはじめ2](http://gosyujin.github.com/2013/01/24/haskell-helloworld3/)

## 参考

- すごいHaskellたのしく学ぼう

## 4章 再帰

リストの中の最大値を取得するmax'関数を実装する。

### max'関数

#### 手順

- 動作原理はP53の図の通り。max'をずーっと掘っていく
- max'にリストを渡すと、ずーっと3番目のmax'が実行されるが、最後の一回だけは要素一つのリストになっているので、2番目の式が実行される
- 最後までいったらさかのぼる 

```haskell
max' [] = error "empty"        -- 1番目
max' [x] = x                   -- 2番目
max' (x:xs) = max x (max' xs)  -- 3番目
```

#### 実行結果

```haskell
*Main> max' [1,4,3,2,5,6]
6
*Main> max' [2]
2
*Main> max' []
*** Exception: empty
```

### 他の再帰

残りの再帰例も写経してみる+一部いじってみる。

```haskell
replicate' n x
 | n <= 0     = []
 | otherwise  = x:concat
 where concat = replicate' (n-1) x

take' n _
 | n <= 0      = []
take' _ []     = []
take' n (x:xs) = x:concat
 where concat  = take' (n-1) xs

reverse' []     = []
reverse' (x:xs) = reverse' xs ++ [x]

zip' [] _          = []
zip' _ []          = []
zip' (x:xs) (y:ys) = (x,y):concat
 where concat      = zip' xs ys
```

写経してみれば、なんとなく書きっぷりはわかってくるな。 
