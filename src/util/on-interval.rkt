#lang racket/base

(provide
 on-interval)

(require
 (for-syntax
  racket/base
  syntax/parse))

(define-syntax (on-interval stx)
  (syntax-parse stx
    [(_ seconds body ...)
     #`(let loop ()
         (sleep seconds)
         body ...
         (loop))]))
