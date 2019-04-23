---
layout: post
title: "Dropboxをコマンドラインで使用する方法"
description: ""
category: 
tags: [Dropbox]
old_url: http://d.hatena.ne.jp/kk_Ataka/20170430/1493953059
---

## あらすじ

- LinuxサーバーでもDropboxを起動させたい

## 参考サイト

- [インストール - Dropbox](https://www.dropbox.com/install-linux)
    - Ubuntu(.deb), Fedora(.rpm), Debian(.deb)パッケージが提供されている。ソースからコンパイルもできる
- [DropboxをLinuxで利用する方法 - maruko2 Note.](http://www.maruko2.com/mw/Dropbox%E3%82%92Linux%E3%81%A7%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)
- [Dropbox を Linuxサーバでも使うときにやるべき設定 - Qiita](http://qiita.com/yudoufu/items/163f9c9b6b9fa2f4bf9e)
- [Using the Official Dropbox Command Line Interface (CLI) - The Unofficial Dropbox Wiki](http://www.dropboxwiki.com/tips-and-tricks/using-the-official-dropbox-command-line-interface-cli)

## 手順

- [インストール - Dropbox](https://www.dropbox.com/ja/install?os=linux) の `コマンド ラインを使った Dropbox のヘッドレス インストール` に沿ってDropboxデーモンをインストールする

```sh
wget -O – "https://www.dropbox.com/download?plat=lnx.x86_64" | tar zxf -
```

- `.dropbox-dist` というディレクトリができるので、その中の `dropboxd` を実行後、アカウントと紐付ける

```sh
$ ~/.dropbox-dist/dropboxd
このコンピュータは Dropbox アカウントにリンクされていません...
このデバイスをリンクするには、https://www.dropbox.com/cli_link_nonce?nonce=HOGE にアクセスしてください。
このコンピュータは Dropbox アカウントにリンクされていません...
このデバイスをリンクするには、https://www.dropbox.com/cli_link_nonce?nonce=HOGE にアクセスしてください。

(以降Dropboxでログインするまでループ)

このデバイスをリンクするには、https://www.dropbox.com/cli_link_nonce?nonce=HOGE にアクセスしてください。
このコンピュータは Dropbox にリンクされました。ようこそ、xxx さん。

強制終了
```

- `dropbox.py` をDLする

```sh
wget -O dropbox.py https://www.dropbox.com/download?dl=packages/dropbox.py
```

```sh
$ python dropbox.py 
Dropbox command-line interface

commands:

Note: use dropbox help <command> to view usage for a specific command.

 status       get current status of the dropboxd
 throttle     set bandwidth limits for Dropbox
 help         provide help
 puburl       get public url of a file in your dropbox's publ automatically start dropbox at login
 exclude      ignores/excludes a directory from syncing
 lansync      enables or disables LAN sync
 sharelink    get a shared link for a file in your dropbox
 proxy        set proxy settings for Dropbox
```

色々いじる前に最低限、lansync(Lan同期)の設定だけは確認しておく。

初期設定のままだと同一Lan内にUDPパケットを投げまくるので、VPSなどで `lansync y` (デフォルトがy)のままだと他の人に迷惑ががが。
