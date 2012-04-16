package Org::To::Textile;
use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw/org_to_textile/;

our $VERSION = '0.01';

sub org_to_textile {
    my %params = @_;

    my $doc = $params{source};
    my $res = '';

    map { $res .= _convert_to_textile($_) } @{ $doc->children };

    return $res;
}

sub _convert_to_textile {
    my ($elem, $level) = @_;

    $level ||= 0;

    my $res = '';

    if ($elem->isa('Org::Element::Text')) {
        $res = _convert_text($elem, $level);
    }
    elsif ($elem->isa('Org::Element::Headline')) {
        $res = _convert_head($elem, $level);
    }
    elsif ($elem->isa('Org::Element::List')) {
        $res = _convert_list($elem, $level);
    }
    elsif ($elem->isa('Org::Element::ListItem')) {
        $res = _convert_list_item($elem, $level);
    }
    elsif ($elem->isa('Org::Element::Block')) {
        $res = _convert_block($elem, $level);
    }
    elsif ($elem->isa('Org::Element::Table')) {
        $res = _convert_table($elem, $level);
    }
    elsif ($elem->isa('Org::Element::Link')) {
        $res = _convert_link($elem, $level);
    }

    return $res;
}

sub _convert_text {
    my ($elem, $level) = @_;

    my $res = $elem->text;
    my $wrapper = {
        U => '+', # _underline_
        I => '_', # /italic/
        B => '*', # *bold*
        S => '-', # +delete+
        C => '-', # =double delete=
    }->{$elem->style};

    $wrapper ||= '';

    return _set_indent($wrapper . $res . $wrapper, $level);
}

sub _convert_head {
    my ($elem, $level) = @_;

    my $res = '';

    $res .= sprintf(
        "h%s. %s\n\n",
        $elem->level,
        $elem->title()->text
    );

    if ($elem->children) {
        map { $res .= _convert_to_textile($_) } @{ $elem->children };
    }

    return $res;
}

sub _convert_list {
    my ($elem, $level) = @_;

    my $res = '';

    # TODO: bullet_styleに応じてリストの種類切り替え
    for my $item (@{ $elem->children }) {
        $level += 2 if $item->isa('Org::Element::List');
        $res .= _convert_to_textile($item, $level);
    }

    return $res;
}

sub _convert_list_item {
    my ($elem, $level) = @_;

    my $res = '';
    my @children = @{ $elem->children };
    my $title = shift @children;

    $res .= __convert_list_item_title($title, $level);
    map { $res .= _convert_to_textile($_, $level + 1) } @children;
    $res .= "\n";

    return $res;
}

sub __convert_list_item_title {
    my ($elem, $level) = @_;

    my $res = '';
    my @texts = split "\n", $elem->text;

    my $bullet = ('*' x ($level / 2 + 1));
    $res .= $bullet . ' ' . shift @texts;
    $res .= "\n";
    $res .= _set_indent((join "\n", @texts), $level + 2);

    return $res;
}

sub _convert_block {
    my ($elem, $level) = @_;

    # TODO: nameを見て表示切替

    my $res = '';

    my $raw_content = $elem->raw_content;
    $raw_content =~ /^( +)/;
    my $indent = $1 || '';
    $raw_content =~ s/^$indent//;
    $raw_content =~ s/\n$indent/\n/g;

    $res .= _set_indent('<pre>', $level);
    $res .= $raw_content;
    $res .= "</pre>\n";

    return $res;
}

sub _convert_table {
    my ($elem, $level) = @_;

    return _set_indent($elem->as_string, $level);
}

sub _convert_link {
    my ($elem, $level) = @_;

    return _set_indent(sprintf('"%s":%s',
                               $elem->description->text,
                               $elem->link),
                       $level);
}

## utils

sub _remove_indent {
    my $text = shift;

    $text =~ s/^ +//;
    $text =~ s/\n +/\n/g;

    return $text;
}

sub _set_indent {
    my ($text, $level) = @_;

    my $indent = ' ' x $level;

    $text = _remove_indent($text);
    $text = $indent . $text;
    $text =~ s/\n/\n$indent/g;

    return $text;
}

1;
