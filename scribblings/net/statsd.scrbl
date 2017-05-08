#lang scribble/manual
@require[@for-label[net/statsd
                    racket/base]]

@title{statsd: A statsd client for racket}
@author{Andrew Gwozdziewycz}

@defmodule[net/statsd]

@hyperlink["https://github.com/etsy/statsd"]{Statsd} is a daemon for
simple aggreation of stats, useful for monitoring distributed systems.

This package implements a statsd client useful for sending metrics to
a statsd instance.

@section{Install}

To install from the package server, run:
@racketblock[
  raco pkg install statsd
]

To install from source, run:
@racketblock[
  git clone https://github.com/apg/statsd
  raco pkg install ./statsd
]

@section{Usage}

Most functions take a @racket[#:sample-rate] parameter. This defaults to
1, but will be utilized by the statsd server to augment the value
passed in.

@defproc[(make-client [#:host string? any/c "127.0.0.1"]
                      [#:port integer? any/c 8125])
         udp-socket?]{

"Connects" to @racket[host] at @racket[port].}

@defparam[statsd-client udp-socket udp-socket?
          #:value localhost-8125]{

The UDP socket that will be used to send metrics with. By default, it
uses 127.0.0.1:8125, the default bind in statsd.}

@defproc[(count [name string?]
                [#:sample-rate real? any/c 1.0]
                [#:incr integer? any/c 1])
          void?]{

Increments a statsd counter named @racket[name] by @racket[incr].}


@defproc[(gauge [name string?]
                [value real?]
                [#:sample-rate real? any/c 1.0]
                [#:modifier symbol? any/c #f])
          void?]{

Sets the value of a statsd gauge named @racket[name] to 
Increments a statsd counter named @racket[name] by @racket[incr].

When @racket[#:modifier] is provided, as @racket['+] or @racket['-],
the value will be added, or subtracted to the current value of the
gauge in the statsd server. A value of @racket[#f] will replace it,
instead.}


@defproc[(set [name string?]
              [value real?]
              [#:sample-rate real? any/c 1.0])
          void?]{

Creates a set value in statsd.}


@defproc[(timer [name string?]
                [ellapsed real?]
                [#:sample-rate real? any/c 1.0])
          void?]{

Sends the ellapsed as a timer for @racket[name].}



