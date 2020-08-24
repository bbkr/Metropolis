# Metropolis generator for [Raku](https://www.raku.org) language

[![Build Status](https://travis-ci.org/bbkr/Metropolis.svg?branch=master)](https://travis-ci.org/bbkr/Metropolis)

[Metropolis–Hastings algorithm](https://en.wikipedia.org/wiki/Metropolis–Hastings_algorithm) is Markov chain Monte Carlo (MCMC) method for generating sequence of random samples from probability distribution function.

It can be used to generate naturally looking data for applications testing and presentation. For example let's assume that you have software for online marketing campaigns. And you have to generate fake traffic (100 000 site visits) that occurred after campaign started 10 days ago to record tutorial for users. It's obvious that such traffic is not constant. After campaign start traffic is low, then it quickly gains momentum, reaches interest peak and slowly fades away like this:

![Campaign traffic](/images/1.png)

`f( x ) = 2x / ( x^3 + 0.5 ), { x > 0 }` generated using awesome [Desmos calculator](https://www.desmos.com/calculator).

With this module you will be able to generate such random samples with any probability distribution function within given domain.

**Note:** This is raw and fast implementation of Metropolis–Hastings algorithm. You may need to turn few dials to get best results for your cases. If you get bad results or timeouts be sure to read [TWEAKS](#tweaks) section.

# TABLE OF CONTENTS

* [SYNOPSIS](#synopsis)
* [METHODS](#methods)
  * [new](#new)
  * [sample](#sample)
  * [graph](#graph)
* [TWEAKS](#tweaks)
* [CONTACT](#contact) 

# SYNOPSIS

```raku
use Metropolis;

my $m = Metropolis.new(
    function => -> $x { 2* $x / ( $x ** 3 + 0.5 ) },
    domain => 0 .. 10
);

say $m.sample( ) for ^42;
```

# METHODS

## new

Params:

* `function` (mandatory) - probability distribution function, must accept exactly one positional argument.
* `domain` (mandatory) - range within which samples should be generated.
* `jumper` (optional) - function that will return new sample from given jumping distribution. Check [TWEAKS](#tweaks) section for more info.

## sample

Params:

* `timeout` (optional) - how long can algorithm look for next sample, no timeout by default.

Get next sample value of `Num` type. `Nil` will be returned in case of timeout.

## graph

Params:

* `samples` (mandatory) - how many samples should be gathered.
* `scale` (optional) - how high `y` axis should be, `100` characters by default.

Crude plotting to quickly visualize requested distribution. With **swapped** axis (x is vertical, turn your monitor). All values are rounded to nearest integer. All bars are rounded to nearest integer. For example to display distribution from [SYNOPSIS](#synopsis):

```raku
my $m = Metropolis.new(
    function => -> $x { 2 * $x / ( $x ** 3 + 0.5 ) },
    domain => 0 .. 10
);

$m.graph( samples => 10000, scale => 10 );
```

```
 0 ███ (1675)
 1 ██████████ (4481)
 2 ███ (1758)
 3 █ (758)
 4 ⎸ (431)
 5 ⎸ (316)
 6 ⎸ (188)
 7 ⎸ (166)
 8 ⎸ (112)
 9 ⎸ (79)
10 ⎸ (36)
```

Potato-grade but useful :)

# TWEAKS

**Common issues:**

* Some places have accumulation of samples way too high for requested probability distribution there.
* Algorithm is not reaching every part of the domain. Some zero probability gaps (like in `f( x ) = sin x` function) are not crossed by algorithm at all, places beyond them do not generate samples. 
* Sampling is realy, really slow.

**Solutions:**

* Don't go crazy with domain width. By default algorithm is tuned to work with domain of total width `<= 10`. Remember that you get `Num` values and you can project them to bigger domain (like for example 864_000 timestamps from the last 10 days) if needed.
* Avoid functions with zero probability gaps within domain. This algorithm can handle them to some extend. But you will get best results if probability is always positive across whole domain. Sometimes it is better to generate samples for each positive probability area separately.
* Burn samples to forget initial state. This algorithm is based on Markov chain Monte Carlo method which needs warmup to eventually converge to the desired distribution. For example throw away first 1000 samples.

**Expert:**

You can provide your own jump function with desired distribution. By default [normal distribution](https://en.wikipedia.org/wiki/Normal_distribution) with `standard-deviation = 2` is used. [Uniform distribution](https://en.wikipedia.org/wiki/Uniform_distribution_%28continuous%29) is also provided with default `delta = 3`.

To use prebuilt and/or change its default:

```raku
my $m = Metropolis.new(
    ...,
    
    # let's jump bigger zero probability gaps!
    jumper => &uniform-distribution.assuming( delta => 15 ) 
);

```

To provide own:

```raku
my $m = Metropolis.new(
    ...,
    
    # discrete decrease of longer jump distance probability
    jumper => sub ( :$mean ) { # mean is current sample position
        
        # roll jump distance within 0..1 range
        my $jump = rand;
        
        # make small jumps less probable by randomly re-rolling
        $jump max= rand if $jump < 0.5;
        
        # return new sampling point
        # remember output must have equal chance to go both ways!
        return $mean + (1, -1).pick * $jump;
    }
);
```

# CONTACT

You can find me on irc.freenode.net #raku channel as **bbkr**.
