#lang info
(define collection 'multi) 
(define deps '("base"))
               
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/net/statsd.scrbl" ())))
(define pkg-desc "statsd client for Racket")
(define version "0.0")
(define pkg-authors '(apg))
