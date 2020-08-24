use lib 'lib';

use Test;
use Metropolis;

plan 4;

# almost every test here check result that was derived from random values
# therefore some samples are taken that will give general idea of probability distribution
# with rounding to lower integer bucket and huge tolerance to avoid false negatives

subtest 'f( x ) = 0' => {

    plan 2;

    my $m = Metropolis.new(
        function => -> $x { 0 },
        domain => 0 .. 1
    );

    is $m.sample( timeout => 0.1 ), Nil, 'sample not found';
    is $m.sample( timeout => 0.1 ), Nil, 'sample not found again';

};

subtest 'f( x ) = x' => {
    
    plan 2;
    
    my $m = Metropolis.new(
        function => -> $x { $x },
        domain => 0 .. 5,
    );
    
    my @stats;
    @stats[ $m.sample( ).floor( ) ]++ for ^10_000;
    
    is [+]( @stats ), 10_000, 'amount of samples pulled';
    ok [<]( @stats ), 'linear increase of probability';
    
};

subtest 'f( x ) = sin x' => {
    
    plan 2;
    
    my $m = Metropolis.new(
        function => -> $x { sin $x },
        domain => 0 .. 25,
    );
    
    my @maximums = ( pi / 2, 5 * pi / 2, 9 * pi / 2, 13 * pi / 2 ).map: *.floor;
    my @minimums = ( 3 * pi / 2, 7 * pi / 2, 11 * pi / 2 ).map: *.floor;
    
    my @stats;
    @stats[ $m.sample( ).floor( ) ]++ for ^10_000;
    
    ok [and]( @stats[ @maximums ] ), 'all probability oases reached';
    ok ![or]( @stats[ @minimums ] ), 'all probability deserts crossed';
    
};

subtest 'f( x ) = | $x - 10 | - 5, with jump distributions' => {
    
    plan 2;
    
    my $function = -> $x { abs( $x - 10 ) - 5 };
    my $domain = 0 .. 20;
    
    my $m = Metropolis.new(
        :$function,
        :$domain,
        jumper => sub ( *%_ ){
            return &uniform-distribution( |%_, delta => 15 )
        }
    );
    
    my @stats;
    @stats[ $m.sample( ).floor( ) ]++ for ^10_000;
    ok [and]( @stats[ 0, 19 ] ), 'big probability deserts crossed with uniform distribution and high delta';

    $m = Metropolis.new(
        :$function,
        :$domain,
        jumper => sub ( *%_ ){
            return &normal-distribution( |%_, standard-deviation => 10 )
        }
    );
    
    @stats = ( );
    @stats[ $m.sample( ).floor( ) ]++ for ^10_000;
    
    ok [and]( @stats[ 0, 19 ] ), 'big probability deserts crossed with normal distribution and high standard deviation';

};