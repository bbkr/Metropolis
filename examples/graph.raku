#!/usr/bin/env raku

use Metropolis;

my $m = Metropolis.new(
    function => -> $x { 2 * $x / ( $x ** 3 + 0.5 ) },
    domain => 0 .. 10
);

$m.graph( samples => 10000, scale => 10 );
