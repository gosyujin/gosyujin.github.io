---
layout: post
title: "Redmine 2.x でテストを実行するとエラーになってしまう"
description: ""
category: 
tags: [Redmine]
---

## あらすじ

Redmine 2.x でプラグインだけをテストするにはどうしたらいいのか。

と、実行するとエラーになってしまった。

## 環境

- Windows 7
- Redmine 2.x

## 参考サイト

- [テストの実行 — Redmine.JP](http://redmine.jp/tech_note/plugins/developer/quickref/run-test/)
- [tail -f pinzo.log: Redmine プラグインのテストが実行できるまで](http://blog.mkt-sys.jp/2013/06/redmine.html)
- [Haru's blog: Redmine 2.0.xにプラグインを移植する](http://haruiida.blogspot.com/2012/06/redmine-20x.html)

## 手順

公式には `rake test:engines:units` とか `rake test:engines:functionals` でいけるって書いてあるけどだめだった。昔のバージョンから変わってるっぽい。

タスクを見てみると…。

```console
rake redmine:plugins:test                        # Runs the plugins tests
rake redmine:plugins:test:functionals            # Run tests for {:function...
rake redmine:plugins:test:integration            # Run tests for {:integrat...
rake redmine:plugins:test:units                  # Run tests for {:units=>"...
rake redmine:send_reminders                      # Send reminders about iss...
rake redmine:tokens:prune                        # Removes expired tokens
rake redmine:watchers:prune                      # Removes watchers from wh...
rake routes                                      # Print out all defined ro...
rake secret                                      # Generate a cryptographic...
rake stats                                       # Report code statistics (...
rake test                                        # Runs test:units, test:fu...
rake test:coverage                               # Measures test coverage
rake test:rdm_routing                            # Run tests for rdm_routin...
rake test:recent                                 # Run tests for {:recent=>...
rake test:scm                                    # Run unit and functional ...
rake test:scm:functionals                        # Run tests for {:function...
rake test:scm:setup:all                          # Creates all test reposit...
rake test:scm:setup:bazaar                       # Creates a test bazaar re...
rake test:scm:setup:create_dir                   # Creates directory for te...
rake test:scm:setup:cvs                          # Creates a test cvs repos...
rake test:scm:setup:darcs                        # Creates a test darcs rep...
rake test:scm:setup:filesystem                   # Creates a test filesyste...
rake test:scm:setup:git                          # Creates a test git repos...
rake test:scm:setup:mercurial                    # Creates a test mercurial...
rake test:scm:setup:subversion                   # Creates a test subversio...
rake test:scm:units                              # Run tests for {:units=>"...
rake test:scm:update                             # Updates installed test r...
rake test:single                                 # Run tests for {:single=>...
rake test:ui                                     # Run tests for {:ui=>"db:...
rake test:uncommitted                            # Run tests for {:uncommit...
```

`test:engines` なんてタスクはなかった。代わりに `redmine:plugins:test:xxxx` とかがあるからこれを使うんだろう。

しかし、実行してみるとなんか変なエラー。

```console
$ rake redmine:plugins:test:functionals
C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `require': cannot load such file -- C:/local/test/test_helper (LoadError)
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `block in require'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:236:in `load_dependency'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `require'
        from C:/local/redmine-2.3.1/plugins/redmine_importer/test/test_helper.rb:2:in `<top (required)>'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `require'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `block in require'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:236:in `load_dependency'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `require'
        from C:/local/redmine-2.3.1/plugins/redmine_importer/test/functional/importer_controller_test.rb:1:in `<top (required)>'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `require'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `block in require'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:236:in `load_dependency'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:252:in `require'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/rake-10.1.0/lib/rake/rake_test_loader.rb:15:in `block in <main>'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/rake-10.1.0/lib/rake/rake_test_loader.rb:4:in `select'
        from C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/rake-10.1.0/lib/rake/rake_test_loader.rb:4:in `<main>'
rake aborted!
Command failed with status (1): [ruby -I"lib;test" -I"C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/rake-10.1.0/lib" "C:/local/redmine-2.3.1/vendor/bundle/ruby/1.9.1/gems/rake-10.1.0/lib/rake/rake_test_loader.rb" "plugins/*/test/functional/**/*_test.rb" ]
```

なんか Redmine のあるディレクトリ( `C:/local/redmine-2.3.1` )より上に遡ってrequireしようとしてる…？

plugins 下にあるプラグインディレクトリの test_helper でしくってるよう。

該当ファイルを確認してみると

```ruby
# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
```

確かにこれだと一階層上にあがってるな。。

あ、もしかしてプラグイン場所が変わったから直さないといけないのか！

前は `vendor/plugins` とかそんな場所だった気がする！

- [Haru's blog: Redmine 2.0.xにプラグインを移植する](http://haruiida.blogspot.com/2012/06/redmine-20x.html)

> vendor/pluginsが無い！

> Redmine 2.0ではプラグインディレクトリがROOT/vendor/pluginsからROOT/pluginsに変わりました。 

> pluginのtest_helper.rbの中に以下のコードが書かれていると思います。
>
> require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
>
> プラグインディレクトリの階層構造が変わったので以下のように’../’を一つ減らす必要があります。
>
> require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

2.0 で `vendor/plugins` から `plugins` になったみたい！
