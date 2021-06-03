#lang racket/base

(provide
 log!
 log-error!)

(require
 racket/exn
 "datetime.rkt")

(define (log! str [nl? #t])
  (display
   (string-append
    "["
    (seconds->iso-8601-string/utc (current-seconds))
    "] "
    str
    (if nl? "\n" ""))))

(define (log-error! err)
  (log! (string-append (exn->string err)) #f))
