#!/usr/bin/env perl

use strict;
use warnings;

use Org::Parser;
use Org::To::Textile qw/org_to_textile/;
use opts;

opts my $file => 'Str';

my $org;

if ($file) {
    if (-e $file) {
        my $fh;
        open $fh, '<', $file;
        $org = do { local $/; <$fh> };
        close $fh;
    }
    else {
        print "no such file: ${file}\n";
    }
}
else {
    $org = shift;
}

my $parser = Org::Parser->new();
print org_to_textile(source => $parser->parse($org));
