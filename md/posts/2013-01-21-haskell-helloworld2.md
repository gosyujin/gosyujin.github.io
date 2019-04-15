---
layout: post
title: "すごいHaskellたのしく学ぼうでHaskellことはじめ"
description: ""
category: 
tags: [Haskell]
---

## あらすじ

Halkellを学ぶにあたってのメモやわからない所を以下に時系列でつらつらと。

## 参考

- すごいHaskellたのしく学ぼう

## 2章 型を信じろ！

- Haskellでは、すべての式の型がコンパイル時にわかっている
- また、自分で書かなくても型推論でなんとかしてくれる
- 式の型は `:t` コマンドで調べられる

```haskell
*Main> :t "Hello"
"Hello" :: [Char]
*Main> :t [1,2,3]
[1,2,3] :: Num t => [t]
*Main> :t (True, "Hello")
(True, "Hello") :: (Bool, [Char])
*Main> :t 4 == 5
4 == 5 :: Bool
```

- `::` は `の型を持つ` の意味
  - "Hello"はChar型のリスト(文字列)を持つ

こんな関数を作る。

```haskell
removeNonUppercase :: [Char] -> [Char]
removeNonUppercase st = [c | c <- st, c `elem` ['A'..'Z']]
```

実行結果はこう。

```haskell
*Main> removeNonUppercase "Hello World"
"HW"
```

この関数は `[Char] -> [Char]` という型を持つ。これは `1つの文字列型を受け取り、1つの文字列型を返す` と考える。たしかに"Hello World"を受け取り"HW"を返してるな。

次はこんな関数。ちょっとややこしくなってきた。

```haskell
addThree :: Int -> Int -> Int -> Int
addThree x y z = x + y + z
```

```haskell
*Main> addThree 1 2 3
6
```

ここでは、 `3つのIntを受け取り、1つのIntを返す` としか読めないが、いったんそう覚えておく。うーん。

### 型変数

headって、リストを引数に渡せば文字だろうが数値だろうがheadを返してくれる。

```haskell
*Main> head [1,2,3]
1
*Main> head ['s','a','f']
's'
*Main> head [True,False,True]
True
```

型はどうなってんの？

```haskell
*Main> :t head
head :: [a] -> a
```

a…だと…。

aは型変数と呼ばれ、どんな型でもとれる。ただし、aは同じである必要がある。

今回は数値を渡したら `[Int] -> Int` となるという事かな。

### 型クラス

- なんらかの振る舞いを定義するインターフェース
- 関数の集まり
- 型クラスに集まる関数をメソッドとも呼ぶ
- 関数が特殊文字のみの場合、デフォルトで中置関数になる
  - +とか*とか

ふーむ。よくわからんので実例を見てみよう。

```haskell
*Main> :t (==)
(==) :: Eq a => a -> a -> Bool
*Main> 1 == 1
True
*Main> 1 == 2
False
```

(==) は1つの何かの型の引数と1つの何かの型の引数を受け取り、Bool型を返す。

中置関数なので、実際は `(==) 1 1` こういう事か。

```haskell
*Main> :t (+)
(+) :: Num a => a -> a -> a
*Main> 1 + 2
3
```

これはIntとIntを渡してIntが返る。

なるほどね。

`=>` はなんだろう。

#### =>

- このシンボルより前にあるものは型クラス制約と呼ばれる。
- (==)の場合は1つの何かの型の引数と1つの何かの型の引数を受け取り、Bool型を返す。ただし `引数aはEqクラスのインスタンスでなければならない` という事か
- **型クラスのクラスは、オブジェクト指向のクラスとは同じでない** 

わかったようなわからんような。
