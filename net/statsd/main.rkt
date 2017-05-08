#lang racket/base

(require racket/udp)

(provide statsd-client
         make-client
         count
         gauge
         set
         timer)

;; create-client: string -> real -> udp-socket
(define (make-client #:host [host "127.0.0.1"]
                     #:port [port 8125])
  (define socket (udp-open-socket))
  (udp-connect! socket host port)
  socket)

;; By default, this parameter is not initialized. It will be
;; initialized upon the first connect that is made.
(define statsd-client (make-parameter (make-client)))

;; count: string -> real -> bytes
(define (count name
               #:sample-rate [sample-rate 1]
               #:incr [incr 1])
  (udp-send (statsd-client)
            (make-payload name incr #f "c" sample-rate)))


;; gauge: string -> real -> bytes
(define (gauge name value
               #:sample-rate [sample-rate 1]
               #:modifier [modifier #f])
  (udp-send (statsd-client)
            (make-payload name value modifier "g" sample-rate)))

;; set: string -> real -> bytes
(define (set name value #:sample-rate [sample-rate 1])
  (udp-send (statsd-client)
            (make-payload name value #f "s" sample-rate)))

;; timer: string -> real -> bytes
(define (timer name ellapsed #:sample-rate [sample-rate 1])
  (udp-send (statsd-client)
            (make-payload name ellapsed #f "ms" sample-rate)))

;; make-payload: string -> real -> string -> real -> sytes
(define (make-payload name value modifier type sample-rate)
  (define valstr
    (cond
     ((exact? value) (number->string value))
     ((inexact? value) (number->string (real->double-flonum value)))
     ;; TODO: convert these things into contracts!
     (else (raise-argument-error 'make-payload "real?" value))))

  (define modstr
    (if (member modifier '(+ -))
        (symbol->string modifier)
        ""))

  ;; TODO: Ideally we'd not include a sample if it's 1.0
  (define samp (real->double-flonum sample-rate))

  (string->bytes/locale
   (format "~a:~a~a|~a|@~a\n" name modstr valstr type
           (if (= samp 1.0) "1.0" samp))))

;; ---------

(module+ test
  (require rackunit)

  (define tests
    (list
     ;; count
     '(("some.count" 1 #f "c" 1.0) . #"some.count:1|c|@1.0\n")
     '(("some.count" 1 #f "c" 0.1) . #"some.count:1|c|@0.1\n")

     ;; gauge
     '(("some.gauge" 322 #f "g" 1.0) . #"some.gauge:322|g|@1.0\n")
     '(("some.gauge" 4 + "g" 1.0) . #"some.gauge:+4|g|@1.0\n")
     '(("some.gauge" 14 - "g" 1.0) . #"some.gauge:-14|g|@1.0\n")

     ;; set
     '(("some.set" 10 #f "s" 1.0) . #"some.set:10|s|@1.0\n")

     ;; timer
     '(("some.timer" 320 #f "ms" 0.1) . #"some.timer:320|ms|@0.1\n")

     ))

  (for [(test tests)]
    (check-equal? (apply make-payload (car test)) (cdr test))))
