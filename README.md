# Metropolis generator for [Raku](https://www.raku.org) language

[![Build Status](https://travis-ci.org/bbkr/Metropolis.svg?branch=master)](https://travis-ci.org/bbkr/Metropolis)

[Metropolis–Hastings algorithm](https://en.wikipedia.org/wiki/Metropolis–Hastings_algorithm) is Markov chain Monte Carlo (MCMC) method for generating sequence of random samples from probability distribution function.

It can be used to generate naturally looking data for applications testing and presentation. For example let's assume that you have software for online marketing campaigns. And you have to generate fake traffic (100 000 site visits) that occurred after campaign started 10 days ago to record tutorial for users. It's obvious that such traffic is not constant. After campaign start traffic is low, then it quickly gains momentum, reaches interest peak and slowly fades away.

![Campaign traffic](/images/1.png)

`f( x ) = 2x / ( x^3 + 0.5 ), { x > 0 }` generated using awesome [Desmos calculator](https://www.desmos.com/calculator).

With this module you will be able to generate such random samples with any probability distribution function within given domain.

**Note:** This is raw and fast implementation of Metropolis–Hastings algorithm. You may need to tweak few dials to get best results for your cases.

# TABLE OF CONTENTS


# SYNOPSIS

# METHODS

## CONTACT

You can find me on irc.freenode.net #raku channel as **bbkr**.
