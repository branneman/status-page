#lang racket/base

(provide
 topic
 topic-status
 topic-name
 topic-desc)

(struct topic
  (status ; int -1=unknown 0=ok 1=degraded 2=outage 3=maintenance
   name   ; string
   desc)  ; string
  #:transparent)
