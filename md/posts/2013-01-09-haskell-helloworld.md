---
layout: post
title: "プログラミングHaskellでHaskellことはじめ"
description: ""
category: 
tags: [Haskell]
old_url: http://d.hatena.ne.jp/kk_Ataka/20130110/1357798953
---

## あらすじ

やりたいことがあるのだけど、調べていたらHaskellでやってみました系の記事が多い気がしたので読めるようになりたい！

## 参考

- プログラミングHaskell

※ とても良書だと思うのだけど、超初心者が挑むには早すぎたので、以下の簡単なライブラリを使用してみた後は「すごいHaskell」にいったん移行しました。

(本の中の記述が数学記号で書かれているのが予想外にキツい。記号の意味はわかるんだけど、 `Haskellでの書き方が` わからないので脳内で数学記号をHaskellに戻して…をやっていると全く進まなかった…。一周目はまず無心で写経しないとダメなタイプ)

## インストール

[Haskell入門 5ステップ - HaskellWiki](http://www.haskell.org/haskellwiki/Haskell%E5%85%A5%E9%96%80_5%E3%82%B9%E3%83%86%E3%83%83%E3%83%97) によると、HaskellはGHCかHugsのどちらかで行けるよう。

ただし、Hugsはもうメンテナンスされていないみたい。

### Hugs

[Downloading Hugs](http://cvs.haskell.org/Hugs/pages/downloading.htm) からDL。Windows版は.exeなのでそのままインストール。

### GHC

[The Glasgow Haskell Compiler](http://www.haskell.org/ghc/) からDL。これもWindows版は.exeがあるのでそのままインストールできる。

※ これよりもHaskellPlatformも入れた方が良いらしい。オールインワン的な？

Downloadページには `Bundled packages and cabal-install` と書かれている。cabalとは

> Cabal is a system for building and packaging Haskell libraries and programs. 

パッケージを作る…とかはまだ必要ないと思うけど。[The Haskell Cabal](http://www.haskell.org/cabal/) からDLできるのだが、setupファイルが.hsで、Haskellファイルのようなので、Haskellを入れてからsetupする感じか。まだいらない。

## ghciのコマンド

コロンから始まるいろいろなコマンドでファイルをロードしたり、ghciを終了したりできる。まずは脱出できるように。

## 変数

小文字から始まればよいみたい。意外なのはシングルクォーテーションが使えること。まじか。

test.hsとして、関数をこう定義する。

```haskell
double x' = x' + x'
```

ghciから呼ぶ。

```haskell
Prelude> :load test.hs
[1 of 1] Compiling Main             ( test.hs, interpreted )
Ok, modules loaded: Main.
*Main> double 13
26
```

呼べる！

## Hello World

以下ghcとghciを使ってやっていく。

インストールが完了したらコマンドプロンプトを起動し、 `ghci` と入力。

```haskell
> ghci
GHCi, version 7.6.1: http://www.haskell.org/ghc/  :? for help
Loading package ghc-prim ... linking ... done.
Loading package integer-gmp ... linking ... done.
Loading package base ... linking ... done.
Prelude>
```

とりあえずよくわからないが、Hello World。

```haskell
Prelude> "Hello World"
"Hello World"
Prelude> putStrLn "Hello World"
Hello World
```

ファイルに記述してコンパイルして実行させる事もできる。 `hello.hs` ファイルを作って以下のように記述する。

```haskell
main = putStrLn "Hello World"
```

コンパイル。

```console
$ c -o hello hello.hs
[1 of 1] Compiling Main             ( hello.hs, hello.o )
Linking hello.exe ...
```

成功したらhello.exeというファイルができているので実行してみる。

```console
$ hello.exe
Hello World
```

## 階数を求める

`fac.hs` として以下のようなファイルを作る。

```haskell
fac n = if n == 0 then 1 else n * fac (n-1)
```

なんか、右辺はなんとなく読めるな。

```haskell
$ ghci
GHCi, version 7.6.1: http://www.haskell.org/ghc/  :? for help
Loading package ghc-prim ... linking ... done.
Loading package integer-gmp ... linking ... done.
Loading package base ... linking ... done.
Prelude> :load fac.hs
[1 of 1] Compiling Main             ( fac.hs, interpreted )
Ok, modules loaded: Main.
*Main> fac 2
2
*Main> fac 3
6
*Main> fac 4
24
*Main> fac 42
1405006117752879898543142606244511569936384000000000
```

## 標準ライブラリを使う

### head

リストの先頭を取得。

```haskell
Prelude> head [2,4,5]
2
Prelude> head [4,2,5]
4
```

### tail

リストから先頭の要素を取り除く。

```haskell
Prelude> tail [1,2,3,4]
[2,3,4]
Prelude> tail [2,3,1,4]
[3,1,4]
```

### !! n

リストのn番目の要素を取得。

```haskell
Prelude> [1,2,3,4,5] !! 2
3
Prelude> [1,2,3,4,5] !! 7
*** Exception: Prelude.(!!): index too large
```

### take n

リストの先頭からn個の要素を取得する。多く指定してもよい。

```haskell
Prelude> take 1 [1,2,3,4,5]
[1]
Prelude> take 4 [1,2,3,4,5]
[1,2,3,4]
Prelude> take 9 [1,2,3,4,5]
[1,2,3,4,5]
```

### drop n

先頭からn個の要素を削除する。多く指定してもよい。

```haskell
Prelude> drop 1 [1,2,3,4,5]
[2,3,4,5]
Prelude> drop 3 [1,2,3,4,5]
[4,5]
Prelude> drop 9 [1,2,3,4,5]
[]
```

### length

要素のサイズを取得する。

```haskell
Prelude> length [1,2]
2
Prelude> length [1,2,3,4,5]
5
```

### sum

リストの要素の和を返す。

```haskell
Prelude> sum [1,2,3,4]
10
```

### product

リストの要素の積を返す。

```haskell
Prelude> product [8,8]
64
```

### ++

リストの連結を行う。

```haskell
Prelude> [1,2,3] ++ [1,2,3]
[1,2,3,1,2,3]
```

### reverse

リストの要素を逆転させる。

```haskell
Prelude> reverse [1,2,3,4,5]
[5,4,3,2,1]
```

### 'div'

<del>divはできなかった。</del> くくるのはシングルクォーテーションじゃなくてバッククォートだった！

```haskell
Prelude> 2 'div' 1

<interactive>:25:3:
    Syntax error on 'div'
    Perhaps you intended to use -XTemplateHaskell
```

## 練習問題

2章の練習問題にあったリストの最後を取得する。

```haskell
*Main> head (reverse [1,2,3,4,5])
5
```

