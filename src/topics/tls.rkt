#lang racket/base

(provide
 topic-metadata
 topic-status)

(require
 "../topic.rkt")

(define topic-metadata
  '("TLS" "HTTPS certificate validity and connectivity"))

(define (topic-status)
  (apply topic (cons 1 topic-metadata)))
