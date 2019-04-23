---
layout: post
title: "WindowsにSphinxのlatexpdfjaができる環境を整えるのに苦戦した話"
description: ""
category: 
tags: [Sphinx]
old_url: http://d.hatena.ne.jp/kk_Ataka/20140528/1401271312
---

## あらすじ

Windows に Sphinx から pdf を出力する環境を作成したが、 `make latexpdfja` コマンドを打つと途中で失敗する。

> for f in *.pdf *.png *.gif *.jpg *.jpeg; do extractbb $f; done
> 
> f の使い方が誤っています。
> 
> make: *** [all-pdf-ja] Error 255

## 環境

- Windows 7
- Python 2.7.6
- Sphinx 1.2.2
- e-pTeX 3.1415926-p3.4-110825-2.6 (sjis) (TeX Live 2013/W32TeX)
  - kpathsea version 6.1.1
  - ptexenc version 1.3.1

## 結論

- `PYTHON_HOME\Lib\site-packages\SPHINX_HOME\sphinx\texinputs` の下に make.bat がなく、 Makefile しかない場合エラーが出るかもしれない
- [[Sphinx-Users 276] Re: LaTeX経由でのPDF作成手順をアップデートしました](http://www.python.jp/pipermail/sphinx-users/2012-April/000593.html) にある make.bat をコピーする
- 上記の `texinputs` 下に配置して再度 `make latexpdfja` を実行する

これでうまくいくかもしれない。

ただし、公式ドキュメントなどを見ていくと、 Sphinx 1.2.2 では、公式の正しい手順を踏めば pdf 出力はできるようなので、どこかに環境不備( Sphinx インストール方法とか、 Windows におけるビルド環境とか)があるのかもしれない。

これがわからない。

## 事前準備

- Sphinx は上記のバージョンをインストール済み
- [LaTeX経由でのPDF作成 > Python製ドキュメンテーションビルダー、Sphinxの日本ユーザ会](http://sphinx-users.jp/cookbook/pdf/latex.html) を参考に TeXLive をインストール
  - 同ページの「Sphinxへのパッチ適用」は Sphinx 1.2.2 だったのでスルー
  - 同ページの「Sphinxプロジェクトの設定変更」に従って `conf.py` の設定を追加

## 調査

### エラー内容

```console
C:\sphinx\project>make latexpdfja
(略)
processing project.tex... index local/project/project_plan ...
resolving references...
writing... done
copying TeX support files...
done
build succeeded, 1 warning.
for f in *.pdf *.png *.gif *.jpg *.jpeg; do extractbb $f; done
f の使い方が誤っています。
make: *** [all-pdf-ja] Error 255

Build finished; the PDF files are in build/latex.
```

うーん？ `make.bat` の latexpdfja 部分を見てみるか。

```bat
(略)
if "%1" == "latexpdfja" (
  %SPHINXBUILD% -b latex %ALLSPHINXOPTS% %BUILDDIR%/latex
  cd %BUILDDIR%/latex
  make all-pdf-ja
  cd %BUILDDIR%/..
  echo.
  echo.Build finished; the PDF files are in %BUILDDIR%/latex.
  goto end
)
(略)
```

`BUILDDIR/latex` の中でさらに make してるな。

```console
C:\sphinx\project>cd build\latex
C:\sphinx\project\build\latex>dir
(略)
2014/05/27  11:14            39,126 project.tex
2014/05/15  19:17             1,964 Makefile
2014/05/15  19:17               220 python.ist
2014/05/15  19:17            15,816 sphinx.sty
2014/05/15  19:17             2,699 sphinxhowto.cls
2014/05/15  19:17             4,101 sphinxmanual.cls
(略)
```

Makefileある。中身は…。

```console
all-pdf-ja:
  for f in *.pdf *.png *.gif *.jpg *.jpeg; do extractbb $$f; done
  for f in *.tex; do platex -kanji=utf8 $(LATEXOPTS) $$f; done
  for f in *.tex; do platex -kanji=utf8 $(LATEXOPTS) $$f; done
  for f in *.tex; do platex -kanji=utf8 $(LATEXOPTS) $$f; done
  -for f in *.idx; do mendex -U -f -d "`basename $$f .idx`.dic" -s python.ist $$f; done
  for f in *.tex; do platex -kanji=utf8 $(LATEXOPTS) $$f; done
  for f in *.tex; do platex -kanji=utf8 $(LATEXOPTS) $$f; done
  for f in *.dvi; do dvipdfmx $$f; done
```

エラーの行あるな。ここでこけてるのか。

### エラーメッセージ調査

とりあえず、エラーメッセージでググると Sphinx Users のメーリングリストがひっかかった。

2012 年の記事で、いろいろバージョンはちょい古め。

- [[Sphinx-Users 265] Re: LaTeX経由でのPDF作成手順をアップデートしました](http://www.python.jp/pipermail/sphinx-users/2012-April/000582.html)

で、この記事を追っていくと最終的には「打田さんのパッチを当てたら動いた(？)」という事らしい。

### パッチあて

ただ、今回インストールしている Sphinx 1.2.2 のソースと目 grep するとどうもこのパッチの修正が当たってたり当たってなかったり(？)するのが気になる。(基本的には取り込まれてるみたいなんだけど)

例えば、 `sphinx/writers/latex.py` のパッチのところ。

```console
{% raw %}
diff --git a/sphinx/writers/latex.py b/sphinx/writers/latex.py
--- a/sphinx/writers/latex.py
+++ b/sphinx/writers/latex.py
@@ -47,6 +47,10 @@
 \date{%(date)s}
 \release{%(release)s}
 \author{%(author)s}
+\hypersetup{
+  pdftitle={%(title)s},
+  pdfauthor={%(author)s},
+}
 \newcommand{\sphinxlogo}{%(logo)s}
 \renewcommand{\releasename}{%(releasename)s}
 %(makeindex)s
@@ -204,13 +208,10 @@
 
             # pTeX (Japanese TeX) for support
             if builder.config.language == 'ja':
-                self.elements['classoptions'] = ',dvipdfm'
-                # found elements of babel, but this should be above sphinx.sty.
-                # because pTeX (Japanese TeX) cannot handle this count.
-                self.elements['babel'] = r'\newcount\pdfoutput\pdfoutput=0'
-                # to make the pdf with correct encoded hyperref bookmarks
-                self.elements['preamble'] += \
-                    r'\AtBeginDvi{\special{pdf:tounicode EUC-UCS2}}'
+                # use dvipdfmx as default class option in Japanese
+                self.elements['classoptions'] = ',dvipdfmx'
+                # disable babel which has not publishing quality in Japanese
+                self.elements['babel'] = ''
         else:
             self.elements['classoptions'] += ',english'
         # allow the user to override them all
{% endraw %}
```

そして、 1.1.2 から 1.2.2 の diff 。

パッチ以外の修正もいっぱいあるのは当然として `hypersetup` の周りは取り込まれていなかったり。

```console
{% raw %}
C:\work>hg clone https://bitbucket.org/birkenfeld/sphinx
C:\work>cd sphinx
C:\work\sphinx>hg diff -r 1.2.2 -r 1.1.2 sphinx\writers\latex.py
diff -r 7d389fe78ee9 -r 14b315a7d010 sphinx/writers/latex.py
--- a/sphinx/writers/latex.py	     Tue Nov 01 21:40:52 2011 +0100
+++ b/sphinx/writers/latex.py	     Sun Mar 02 08:41:38 2014 +0100
@@ -8,7 +8,7 @@
     Much of this code is adapted from Dave Kuhlman's "docpy" writer from his
     docutils sandbox.
 
-    :copyright: Copyright 2007-2011 by the Sphinx team, see AUTHORS.
+    :copyright: Copyright 2007-2014 by the Sphinx team, see AUTHORS.
     :license: BSD, see LICENSE for details.
 """
 
@@ -22,7 +22,7 @@
 from sphinx import addnodes
 from sphinx import highlighting
 from sphinx.errors import SphinxError
-from sphinx.locale import admonitionlabels, versionlabels, _
+from sphinx.locale import admonitionlabels, _
 from sphinx.util import split_into
 from sphinx.util.osutil import ustrftime
 from sphinx.util.pycompat import any
@@ -34,6 +34,7 @@
 \documentclass[%(papersize)s,%(pointsize)s%(classoptions)s]{%(wrapperclass)s}
 %(inputenc)s
 %(utf8extra)s
+%(cmappkg)s
 %(fontenc)s
 %(babel)s
 %(fontpkg)s
@@ -100,10 +101,18 @@
 class ExtBabel(Babel):
     def get_shorthandoff(self):
         shortlang = self.language.split('_')[0]
-        if shortlang in ('de', 'sl', 'pt', 'es', 'nl', 'pl', 'it'):
+        if shortlang in ('de', 'ngerman', 'sl', 'slovene', 'pt', 'portuges',
+                         'es', 'spanish', 'nl', 'dutch', 'pl', 'polish', 'it',
+                         'italian'):
             return '\\shorthandoff{"}'
         return ''
 
+    def uses_cyrillic(self):
+        shortlang = self.language.split('_')[0]
+        return shortlang in ('bg','bulgarian', 'kk','kazakh',
+                             'mn','mongolian', 'ru','russian',
+                             'uk','ukrainian')
+
 # in latest trunk, the attribute is called Babel.language_codes and already
 # includes Slovene
 if hasattr(Babel, '_ISO639_TO_BABEL'):
@@ -133,8 +142,10 @@
         'papersize':       'letterpaper',
         'pointsize':       '10pt',
         'classoptions':    '',
+        'extraclassoptions': '',
         'inputenc':        '\\usepackage[utf8]{inputenc}',
         'utf8extra':       '\\DeclareUnicodeCharacter{00A0}{\\nobreakspace}',
+        'cmappkg':         '\\usepackage{cmap}',
         'fontenc':         '\\usepackage[T1]{fontenc}',
         'babel':           '\\usepackage{babel}',
         'fontpkg':         '\\usepackage{times}',
@@ -153,8 +164,12 @@
         'tableofcontents': '\\tableofcontents',
         'footer':          '',
         'printindex':      '\\printindex',
+        'transition':      '\n\n\\bigskip\\hrule{}\\bigskip\n\n',
     }
 
+    # sphinx specific document classes
+    docclasses = ('howto', 'manual')
+
     def __init__(self, document, builder):
         nodes.NodeVisitor.__init__(self, document)
         self.builder = builder
@@ -167,7 +182,7 @@
 
         self.elements = self.default_elements.copy()
         self.elements.update({
-            'wrapperclass': 'sphinx' + document.settings.docclass,
+            'wrapperclass': self.format_docclass(document.settings.docclass),
             'papersize':    papersize,
             'pointsize':    builder.config.latex_font_size,
             # if empty, the title is set to the first section title
@@ -202,19 +217,25 @@
             self.elements['shorthandoff'] = babel.get_shorthandoff()
             self.elements['fncychap'] = '\\usepackage[Sonny]{fncychap}'
 
+            # Times fonts don't work with Cyrillic languages
+            if babel.uses_cyrillic():
+                self.elements['fontpkg'] = ''
+
             # pTeX (Japanese TeX) for support
             if builder.config.language == 'ja':
-                self.elements['classoptions'] = ',dvipdfm'
-                # found elements of babel, but this should be above sphinx.sty.
-                # because pTeX (Japanese TeX) cannot handle this count.
-                self.elements['babel'] = r'\newcount\pdfoutput\pdfoutput=0'
-                # to make the pdf with correct encoded hyperref bookmarks
-                self.elements['preamble'] += \
-                    r'\AtBeginDvi{\special{pdf:tounicode EUC-UCS2}}'
+                # use dvipdfmx as default class option in Japanese
+                self.elements['classoptions'] = ',dvipdfmx'
+                # disable babel which has not publishing quality in Japanese
+                self.elements['babel'] = ''
+                # disable fncychap in Japanese documents
+                self.elements['fncychap'] = ''
         else:
             self.elements['classoptions'] += ',english'
         # allow the user to override them all
         self.elements.update(builder.config.latex_elements)
+        if self.elements['extraclassoptions']:
+            self.elements['classoptions'] += ',' + \
+                                             self.elements['extraclassoptions']
 
         self.highlighter = highlighting.PygmentsBridge('latex',
             builder.config.pygments_style, builder.config.trim_doctest_flags)
@@ -243,7 +264,6 @@
         self.next_figure_ids = set()
         self.next_table_ids = set()
         # flags
-        self.verbatim = None
         self.in_title = 0
         self.in_production_list = 0
         self.in_footnote = 0
@@ -258,6 +278,13 @@
         self.previous_spanning_column = 0
         self.remember_multirow = {}
 
+    def format_docclass(self, docclass):
+        """ prepends prefix to sphinx document classes
+        """
+        if docclass in self.docclasses:
+            docclass = 'sphinx' + docclass
+        return docclass
+
     def astext(self):
         return (HEADER % self.elements +
                 self.highlighter.get_stylesheet() +
@@ -292,7 +319,7 @@
                 if i > 0:
                     ret.append('\\indexspace\n')
                 ret.append('\\bigletter{%s}\n' %
-                           letter.translate(tex_escape_map))
+                           unicode(letter).translate(tex_escape_map))
                 for entry in entries:
                     if not entry[3]:
                         continue
@@ -351,7 +378,7 @@
                     widest_label = bi[0]
             self.body.append(u'\n\\begin{thebibliography}{%s}\n' % widest_label)
             for bi in self.bibitems:
-                target = self.hypertarget(bi[2] + ':' + bi[0].lower(),
+                target = self.hypertarget(bi[2] + ':' + bi[3],
                                           withdoc=False)
                 self.body.append(u'\\bibitem[%s]{%s}{%s %s}\n' %
                     (bi[0], self.idescape(bi[0]), target, bi[1]))
@@ -440,7 +467,7 @@
         self.body.append('}\n')
 
     def visit_transition(self, node):
-        self.body.append('\n\n\\bigskip\\hrule{}\\bigskip\n\n')
+        self.body.append(self.elements['transition'])
     def depart_transition(self, node):
         pass
 
@@ -544,10 +571,12 @@
 
     def visit_desc_name(self, node):
         self.body.append(r'\bfcode{')
+        self.no_contractions += 1
         self.literal_whitespace += 1
     def depart_desc_name(self, node):
         self.body.append('}')
         self.literal_whitespace -= 1
+        self.no_contractions -= 1
 
     def visit_desc_parameterlist(self, node):
         # close name, open parameterlist
@@ -585,11 +614,6 @@
     def depart_desc_content(self, node):
         pass
 
-    def visit_refcount(self, node):
-        self.body.append("\\emph{")
-    def depart_refcount(self, node):
-        self.body.append("}\\\\")
-
     def visit_seealso(self, node):
         self.body.append(u'\n\n\\strong{%s:}\n\n' % admonitionlabels['seealso'])
     def depart_seealso(self, node):
@@ -618,6 +642,7 @@
         if isinstance(node.parent, nodes.citation):
             self.bibitems[-1][0] = node.astext()
             self.bibitems[-1][2] = self.curfilestack[-1]
+            self.bibitems[-1][3] = node.parent['ids'][0]
         raise nodes.SkipNode
 
     def visit_tabular_col_spec(self, node):
@@ -680,16 +705,15 @@
             self.body.extend(self.tableheaders)
             self.body.append('\\endfirsthead\n\n')
             self.body.append('\\multicolumn{%s}{c}%%\n' % self.table.colcount)
-            self.body.append(r'\{\{\bfseries \tablename\ \thetable{} -- %s\}\} \\'
+            self.body.append(r'\{\{\textsf{\tablename\ \thetable{} -- %s\}}\} \\'
                              % _('continued from previous page'))
             self.body.append('\n\\hline\n')
             self.body.extend(self.tableheaders)
             self.body.append('\\endhead\n\n')
-            self.body.append(ur'\hline \multicolumn{%s}{|r|}\{\{%s\}\} \\ \hline'
+            self.body.append(ur'\hline \multicolumn{%s}{|r|}\{\{\textsf{%s\}\}} \\ \hline'
                              % (self.table.colcount,
                                 _('Continued on next page')))
             self.body.append('\n\\endfoot\n\n')
-            self.body.append('\\hline\n')
             self.body.append('\\endlastfoot\n\n')
         else:
             self.body.append('\\hline\n')
@@ -719,29 +743,28 @@
         # Redirect head output until header is finished. see visit_tbody.
         self.body = self.tableheaders
     def depart_thead(self, node):
-        pass
+        self.body.append('\\hline')
 
     def visit_tbody(self, node):
         if not self.table.had_head:
             self.visit_thead(node)
         self.body = self.tablebody
     def depart_tbody(self, node):
-        pass
+        self.body.append('\\hline')
 
     def visit_row(self, node):
         self.table.col = 0
     def depart_row(self, node):
         if self.previous_spanning_row == 1:
             self.previous_spanning_row = 0
-            self.body.append('\\\\\n')
-        else:
-            self.body.append('\\\\\\hline\n')
+        self.body.append('\\\\\n')
         self.table.rowcount += 1
 
     def visit_entry(self, node):
-        if self.remember_multirow.get(0, 0) > 1:
+        if self.table.col > 0:
             self.body.append(' & ')
-        if self.table.col > 0:
+        elif self.remember_multirow.get(1, 0) > 1:
+            self.remember_multirow[1] -= 1
             self.body.append(' & ')
         self.table.col += 1
         context = ''
@@ -761,7 +784,7 @@
                 self.body.append('}{l|}{')
             context += '}'
         if isinstance(node.parent.parent, nodes.thead):
-            self.body.append('\\textbf{')
+            self.body.append('\\textsf{\\relax ')
             context += '}'
         if self.remember_multirow.get(self.table.col + 1, 0) > 1:
             self.remember_multirow[self.table.col + 1] -= 1
@@ -1035,12 +1058,7 @@
     depart_warning = _depart_named_admonition
 
     def visit_versionmodified(self, node):
-        intro = versionlabels[node['type']] % node['version']
-        if node.children:
-            intro += ': '
-        else:
-            intro += '.'
-        self.body.append(intro)
+        pass
     def depart_versionmodified(self, node):
         pass
 
@@ -1172,7 +1190,7 @@
             id = self.curfilestack[-1] + ':' + uri[1:]
             self.body.append(self.hyperlink(id))
             if self.builder.config.latex_show_pagerefs and not \
-                    self.in_productionlist:
+                    self.in_production_list:
                 self.context.append('}} (%s)' % self.hyperpageref(id))
             else:
                 self.context.append('}}')
@@ -1248,7 +1266,8 @@
 
     def visit_citation(self, node):
         # TODO maybe use cite bibitems
-        self.bibitems.append(['', '', ''])  # [citeid, citetext, docname]
+        # bibitem: [citelabel, citetext, docname, citeid]
+        self.bibitems.append(['', '', '', ''])
         self.context.append(len(self.body))
     def depart_citation(self, node):
         size = self.context.pop()
@@ -1294,35 +1313,44 @@
         pass
 
     def visit_literal_block(self, node):
-        self.verbatim = ''
+        if self.in_footnote:
+            raise UnsupportedError('%s:%s: literal blocks in footnotes are '
+                                   'not supported by LaTeX' %
+                                   (self.curfilestack[-1], node.line))
+        if node.rawsource != node.astext():
+            # most probably a parsed-literal block -- don't highlight
+            self.body.append('\\begin{alltt}\n')
+        else:
+            code = node.astext().rstrip('\n')
+            lang = self.hlsettingstack[-1][0]
+            linenos = code.count('\n') >= self.hlsettingstack[-1][1] - 1
+            highlight_args = node.get('highlight_args', {})
+            if 'language' in node:
+                # code-block directives
+                lang = node['language']
+                highlight_args['force'] = True
+            if 'linenos' in node:
+                linenos = node['linenos']
+            def warner(msg):
+                self.builder.warn(msg, (self.curfilestack[-1], node.line))
+            hlcode = self.highlighter.highlight_block(code, lang, warn=warner,
+                    linenos=linenos, **highlight_args)
+            # workaround for Unicode issue
+            hlcode = hlcode.replace(u'€', u'@texteuro[]')
+            # must use original Verbatim environment and "tabular" environment
+            if self.table:
+                hlcode = hlcode.replace('\\begin{Verbatim}',
+                                        '\\begin{OriginalVerbatim}')
+                self.table.has_problematic = True
+                self.table.has_verbatim = True
+            # get consistent trailer
+            hlcode = hlcode.rstrip()[:-14] # strip \end{Verbatim}
+            hlcode = hlcode.rstrip() + '\n'
+            self.body.append('\n' + hlcode + '\\end{%sVerbatim}\n' %
+                             (self.table and 'Original' or ''))
+            raise nodes.SkipNode
     def depart_literal_block(self, node):
-        code = self.verbatim.rstrip('\n')
-        lang = self.hlsettingstack[-1][0]
-        linenos = code.count('\n') >= self.hlsettingstack[-1][1] - 1
-        if 'language' in node:
-            # code-block directives
-            lang = node['language']
-        if 'linenos' in node:
-            linenos = node['linenos']
-        highlight_args = node.get('highlight_args', {})
-        def warner(msg):
-            self.builder.warn(msg, (self.curfilestack[-1], node.line))
-        hlcode = self.highlighter.highlight_block(code, lang, warn=warner,
-                linenos=linenos, **highlight_args)
-        # workaround for Unicode issue
-        hlcode = hlcode.replace(u'€', u'@texteuro[]')
-        # must use original Verbatim environment and "tabular" environment
-        if self.table:
-            hlcode = hlcode.replace('\\begin{Verbatim}',
-                                    '\\begin{OriginalVerbatim}')
-            self.table.has_problematic = True
-            self.table.has_verbatim = True
-        # get consistent trailer
-        hlcode = hlcode.rstrip()[:-14] # strip \end{Verbatim}
-        hlcode = hlcode.rstrip() + '\n'
-        self.body.append('\n' + hlcode + '\\end{%sVerbatim}\n' %
-                         (self.table and 'Original' or ''))
-        self.verbatim = None
+        self.body.append('\n\\end{alltt}\n')
     visit_doctest_block = visit_literal_block
     depart_doctest_block = depart_literal_block
 
@@ -1477,6 +1505,7 @@
             text = text.replace(u'\n', u'~\\\\\n').replace(u' ', u'~')
         if self.no_contractions:
             text = text.replace('--', u'-{-}')
+            text = text.replace("''", u"'{'}")
         return text
 
     def encode_uri(self, text):
@@ -1484,13 +1513,10 @@
         return self.encode(text).replace('\\textasciitilde{}', '~')
 
     def visit_Text(self, node):
-        if self.verbatim is not None:
-            self.verbatim += node.astext()
-        else:
-            text = self.encode(node.astext())
-            if not self.no_contractions:
-                text = educate_quotes_latex(text)
-            self.body.append(text)
+        text = self.encode(node.astext())
+        if not self.no_contractions:
+            text = educate_quotes_latex(text)
+        self.body.append(text)
     def depart_Text(self, node):
         pass
 
@@ -1506,5 +1532,14 @@
     def depart_system_message(self, node):
         self.body.append('\n')
 
+    def visit_math(self, node):
+        self.builder.warn('using "math" markup without a Sphinx math extension '
+                          'active, please use one of the math extensions '
+                          'described at http://sphinx-doc.org/ext/math.html',
+                          (self.curfilestack[-1], node.line))
+        raise nodes.SkipNode
+
+    visit_math_block = visit_math
+
     def unknown_visit(self, node):
         raise NotImplementedError('Unknown node: ' + node.__class__.__name__)
{% endraw %}
```

[LaTeX経由でのPDF作成 > Python製ドキュメンテーションビルダー、Sphinxの日本ユーザ会](http://sphinx-users.jp/cookbook/pdf/latex.html) にも

> Sphinx-1.2 (2013/12/10リリース)に打田さんのパッチが取り込まれています。

と書かれているので、やっぱり 1.2.2 を正として、このバージョンでは動くものと考えて良いんだろう…。

じゃあなんでエラーになるんだろう。

いや、エラーになるのはわかるんだけど、なんで手順どおりにやってハマる？ 何か抜けてる？

抜けてるとしたら、 Sphinx インストール周りなんだけど。

## 解決策

- [[Sphinx-Users 276] Re: LaTeX経由でのPDF作成手順をアップデートしました](http://www.python.jp/pipermail/sphinx-users/2012-April/000593.html)

このトピックの最後で打田さんが make.bat を作ったといっている。

このファイルを作って `PYTHON_HOME\Lib\site-packages\SPHINX_HOME\sphinx\texinputs` の下にコピーした。(パスは環境によって変わるかも)

```bat
@@echo off
setlocal

::set %LATEXOPTS%=

if "%1" EQU "all-pdf" goto all-pdf
if "%1" EQU "all-dvi" goto all-dvi
if "%1" EQU "all-ps" goto all-ps
if "%1" EQU "all-pdf-ja" goto all-pdf-ja
if "%1" EQU "clean" goto clean

:all-pdf
for %%f in (*.tex) do pdflatex %LATEXOPTS% %%f
for %%f in (*.tex) do pdflatex %LATEXOPTS% %%f
for %%f in (*.tex) do pdflatex %LATEXOPTS% %%f
for %%f in (*.idx) do if exist %%f (makeindex -s python.ist %%f)
for %%f in (*.tex) do pdflatex %LATEXOPTS% %%f
for %%f in (*.tex) do pdflatex %LATEXOPTS% %%f
goto end

:all-dvi
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.idx) do if exist %%f (makeindex -s python.ist %%f)
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.tex) do latex %LATEXOPTS% %%f
goto end

:all-ps
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.idx) do if exist %%f (makeindex -s python.ist %%f)
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.tex) do latex %LATEXOPTS% %%f
for %%f in (*.dvi) do dvips %%f
goto end

:all-pdf-ja
for %%f in (*.pdf *.png *.gif *.jpg *.jpeg) do extractbb %%f
for %%f in (*.tex) do platex -kanji=utf8 %LATEXOPTS% %%f
for %%f in (*.tex) do platex -kanji=utf8 %LATEXOPTS% %%f
for %%f in (*.tex) do platex -kanji=utf8 %LATEXOPTS% %%f
for %%f in (*.idx) do if exist %%f (mendex -U -f -d "`basename %%f .idx`.dic" -s python.ist %%f)
for %%f in (*.tex) do platex -kanji=utf8 %LATEXOPTS% %%f
for %%f in (*.tex) do platex -kanji=utf8 %LATEXOPTS% %%f
for %%f in (*.dvi) do dvipdfmx %%f
goto end

:clean
del *.dvi *.log *.ind *.aux *.toc *.syn *.idx *.out *.ilg *.pla
goto end

:end
```

そして `make latexpdfja` を再チャレンジしたら動いた！

…とここまで書いて一つ思いついたけど、もしかして make の種類関係あるか…？
