unit class Metropolis;

#| user function describing desired probability distribution
has &.function is required;

#| range within which samples should be generated
has Range:D $.domain is required;

#| function for determining new sampling point
has &.jumper = &normal-distribution;

#| current x
has Real $!x;

#| current y, for faster calculation of next jump acceptance
has Real $!y;

method sample ( Real :$timeout ) {
    
    # set initial x to random point within domain
    $!x //= ( $!domain.min .. $!domain.max ).rand;
    
    # save start execution time for timeout handling
    my $start-time = now if $timeout.defined;
    
    loop {
        
        # bail out if new sample was not found in given time
        return if $timeout.defined and now - $start-time > $timeout;
        
        # probability in current x,
        # may be known from previous jump attempts
        $!y //= &.function.( $!x ) max 0;
        
        # get new x proposal and probability in it
        my $x-new = &.jumper.( mean => $!x );
        my $y-new = &.function.( $x-new ) max 0;
        
        # if x proposal is outside domain do not jump
        unless $!domain.min <= $x-new <= $!domain.max {
            
            # take sample
            # but only if there is non zero probability for it
            return $!x if $!y > 0;
            
            # no sample was taken, try another jump
            next;
        }
        
        # how attractive is new x in terms of probability
        my $acceptance;
        
        if $!y == 0 {
            
            # this allows algorithm to dig out of zero probability gaps
            $acceptance = Inf;
        }
        else {
            
            # use probability ratio between new and current x
            $acceptance = $y-new / $!y;
        }
        
        # the more attractive new x is the more likely is to jump there
        if $acceptance > rand {
            $!x = $x-new;
            $!y = $y-new;
        }
        
        # take sample
        # but only if there is non zero probability for it
        return $!x if $!y > 0;
    }

}

sub uniform-distribution ( Real:D :$mean!, Int:D :$delta = 3 ) is export {
    
    return ( $mean - $delta .. $mean + $delta ).rand;
}

sub normal-distribution ( Real:D :$mean!, Real:D :$standard-deviation = 2 ) is export {
    
    my $r = sqrt -2 * log rand;
    my $t = tau * rand;
    
    return $r * cos( $t ) * $standard-deviation + $mean;
}

method graph ( Int:D :$samples!, Int:D :$scale = 100 ) {
    
    my %stats;
    %stats{ self.sample( ).round( ) }++ for ^$samples;

    my @blocks = '⎸', '█';
    my $max-length-x = %stats.keys.map( *.chars ).max // 0;
    my $max-y = %stats.values.max // 1;

    for self.domain.min.floor .. self.domain.max -> $x {
        
       my $y = %stats{ $x } // 0;
       my $scaled-y = ( $scale * $y / $max-y ).floor;
        
        printf '%' ~ $max-length-x ~ 'd ', $x;
        print $scaled-y ?? ( @blocks[ 1 ] x $scaled-y ) !! @blocks[ 0 ];
        printf ' (%d)', $y;
        print "\n";
    }

}
