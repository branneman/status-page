#lang racket/base

(provide
 topic-metadata
 topic-status)

(require
 net/http-client
 "../topic.rkt")

(define topic-metadata
  '("Web Server" "Web Server responsiveness (200 status code)"))

(define (topic-status)
  (define-values (status _headers _body)
    (http-sendrecv "example.org" "/"
                   #:ssl? #t))
  (if (equal? status #"HTTP/1.1 200 OK")
      (apply topic (cons 0 topic-metadata))
      (apply topic (cons 2 topic-metadata))))
