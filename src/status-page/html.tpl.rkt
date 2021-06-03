#lang racket/base

(provide
 render-html)

(require
 racket/string
 html-template
 "../util/datetime.rkt"
 "../topic.rkt")

(define product-title "Status Example App")
(define product-desc "Service status for example.org")

(define (render-html bag)
  (let ([str (open-output-string)]
        [var (λ (k) (hash-ref bag k))]
        [now (current-seconds)])

    (html-template
     #:port str

     (html (@ (lang "en"))
      (head
       (meta (@ (charset "utf-8")))
       (title (% product-title))
       (meta (@ (name "viewport") (content "width=device-width")))
       (link (@ (rel "stylesheet") (href "/static/style.css"))))

      (body
       (h1 (% product-title)
           ": "
           (span (@ (class "status-" (% (status->string (var 'overall-status)))))
                 (% (status->string (var 'overall-status)))))
       (p (em "Last updated: "
              (time (@ (datetime (% (last-updated now))))
                    (% (last-updated-human-readable now)))
              " UTC"))
       (p (% product-desc))

       (%write
        (when (not (string=? "" (var 'message-html)))
          (html-template
           (div (@ (class "message"))
            (%verbatim (var 'message-html))))))

       (%write
        (for-each
         (λ (t)
           (html-template
            (div
             (h2 (% (topic-name t))
                 ": "
                 (span (@ (class "status-" (% (status->string (topic-status t)))))
                       (% (status->string (topic-status t)))))
             (p (% (topic-desc t))))))
         (var 'topics))))))

    (string-append "<!doctype html>\n" (get-output-string str))))

(define (status->string n)
  (case n
    [(-1) "unknown"]
    [(0) "ok"]
    [(1) "degraded"]
    [(2) "outage"]
    [(3) "maintenance"]))

(define (last-updated seconds)
  (let ([sec (- seconds (modulo seconds 60))])
    (seconds->iso-8601-string/utc sec)))

(define (last-updated-human-readable seconds)
  (substring (string-replace (last-updated seconds) "T" " ") 0 16))
