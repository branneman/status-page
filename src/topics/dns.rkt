#lang racket/base

(provide
 topic-metadata
 topic-status)

(require
 "../topic.rkt")

(define topic-metadata
  '("DNS" "Domain name resolution"))

(define (topic-status)
  (apply topic (cons -1 topic-metadata)))
