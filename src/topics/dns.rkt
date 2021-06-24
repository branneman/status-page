#lang racket/base

(provide
 topic-metadata
 topic-status)

(require
 racket/string
 net/dns
 "../util/env.rkt"
 "../topic.rkt")

(define topic-metadata
  '("DNS" "Domain name resolution"))

(define (topic-status)
  (require-env-vars '("TOPIC_DNS_NAMES"))

  (with-handlers
    ([exn:fail? (λ (_) (apply topic (cons -1 topic-metadata)))])

    (define stati
      (for/list ([name (string-split (getenv "TOPIC_DNS_NAMES"))])
        (with-handlers
          ([exn:fail? (λ (_) #f)])
          (dns-get-address (dns-find-nameserver) name))))

    (cond
      [(andmap not stati)
       (apply topic (cons 2 topic-metadata))]

      [(ormap not stati)
       (apply topic (cons 1 topic-metadata))]

      [else
       (apply topic (cons 0 topic-metadata))])))
