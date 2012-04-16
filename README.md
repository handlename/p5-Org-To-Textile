# Org::To::Textile

## これはなに？

emacsのorg-modeの書式からtextile形式に変換するモジュールです。

    use Org::Parser;
    use Org::To::Textile qw/org_to_textile/;
    
    my $parser = Org::Parser->new();
    my $org = $parser->parse_file("/path/to/file.org");
    my $textile = org_to_textile(source => $org);

## 変換例

元のorg-mode形式のテキスト

    * Header
    ** Text
       The quick brown fox jumps over the lazy dog.
     
    ** List
       - list1
         text text
       - list2
         text text
         - listA
         - listB
     
    ** Block
       #+BEGIN_EXAMPLE
       Inside of block
       #+END_EXAMPLE
     
    ** Table
       | cell1-1 | cell2-1 |
       | cell1-2 | cell2-2 |
     
    ** Link
       [[http://hoge.com][hoge]]
     
    ** Text Decoration
       *bold*
       /italic/
       _underline_
       +delete+
       =double delete=

変換後のTextile形式のテキスト

    h1. Header
     
    h2. Text
     
    The quick brown fox jumps over the lazy dog.
     
    h2. List
     
    * list1
      text text
    * list2
      text text
    ** listA
     
    ** listB
     
    h2. Block
     
    <pre>Inside of block</pre>
     
    h2. Table
     
    | cell1-1 | cell2-1 |
    | cell1-2 | cell2-2 |
     
    h2. Link
     
    "hoge":http://hoge.com
     
    h2. Text Decoration
     
    *bold*
    _italic_
    +underline+
    -delete-
    -double delete-

このプロジェクトのトップディレクトリで次のようにすることで同様の結果を得られます。

    $ perl -Ilib org2textile.pl --file=sample.org

## emacsと連携する

まず、org2textile.plをパスの通った場所に置いてください。

次に、`org-to-textile.el` を .emacs で require すると `org-to-textile` というコマンドが有効になります。

    (add-to-list 'load-path "/path/to/p5-Org-To-Textile")
    (require 'org-to-textile)

org-mode で書かれたファイルを開いている時に `M-x org-to-textile` を実行すると、新しいバッファに Textile 変換したものを表示します。

選択されたリージョンがあった場合、リージョンの範囲内のテキストのみを対象にして変換を行います。

## 注意！

org-modeのすべての書式に対応しているわけではありません。対応している書式は先の「変換例」に書かれているものだけです。
