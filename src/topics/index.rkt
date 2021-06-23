#lang racket/base

(provide
 topics-update-all!)

(require
 racket/file
 json
 "../util/base-dir.rkt"
 "../util/log.rkt"
 "../topic.rkt"

 (only-in "dns.rkt" [topic-metadata dns-topic-metadata] [topic-status dns-topic-status])
 (only-in "tls.rkt" [topic-metadata tls-topic-metadata] [topic-status tls-topic-status])
 (only-in "web-server.rkt" [topic-metadata web-server-topic-metadata] [topic-status web-server-topic-status]))

(define topics
  (list (list "dns"        dns-topic-metadata        dns-topic-status)
        (list "tls"        tls-topic-metadata        tls-topic-status)
        (list "web-server" web-server-topic-metadata web-server-topic-status)))

(define (data-dir) (simplify-path (build-path (base-dir) "data/")))

(define (topics-update-all!)
  (status-save! (map (λ (t) (apply topic-save! t)) topics))
  (log! "Updated all topics."))

(define (topic-update metadata fn)
  (with-handlers
    ([exn:fail?
      (λ (e)
        (log-error! e)
        (apply topic (cons -1 metadata)))])
    (fn)))

(define (topic-save! id metadata fn)
  (let ([data (topic-update metadata fn)])
    (display-to-file
     (jsexpr->string (topic-serialise data))
     (build-path (data-dir) "topics" (string-append id ".json"))
     #:exists 'replace)
    data))

(define (status-save! topics)
  (display-to-file
   (jsexpr->string (status-serialise topics))
   (build-path (data-dir) "status.json")
   #:exists 'replace))

(define (topic-status->overall-status topics)
  (let ([stati (map topic-status topics)])
    (cond
      [(null? topics)
       -1]

      ; if all numbers are equal: return that number
      [(andmap (λ (n) (= n (car stati))) stati)
       (car stati)]

      ; maintenance: if there's a 3: overall status becomes 3
      [(ormap (λ (n) (= n 3)) stati)
       3]

      ; degraded: if there's a 1 or 2, overall status becomes 1
      [(ormap (λ (n) (or (= n 1) (= n 2))) stati)
       1]

      ; ok: if there's just -1 and 0 left, assume ok
      [else 0])))

(define (topic-serialise data)
  (hash 'status (topic-status data)
        'name (topic-name data)
        'desc (topic-desc data)))

(define (status-serialise topics)
  (hash 'status (topic-status->overall-status topics)
        'topics (map topic-serialise topics)))
