#lang racket/base

(provide
 write-status-page!)

(require
 racket/file
 racket/path
 json
 "../util/base-dir.rkt"
 "../util/log.rkt"
 "../topic.rkt"
 "html.tpl.rkt")

(define (data-dir) (simplify-path (build-path (base-dir) "data/")))
(define (htdocs-dir) (simplify-path (build-path (base-dir) "htdocs/")))

(define (write-status-page!)
  (display-to-file (render-html (make-view-bag))
                   (build-path (htdocs-dir) "index.html")
                   #:exists 'replace)
  (log! "Status page html written."))

(define (make-view-bag)
  (let ([status (string->jsexpr (file->string (build-path (data-dir) "status.json")))]
        [topics (directory-list (build-path (data-dir) "topics")
                                #:build? #t)])
    (hasheq
     'overall-status
     (hash-ref status 'status)

     'message-html
     (if (file-exists? (build-path (data-dir) "message.html"))
         (file->string (build-path (data-dir) "message.html"))
         "")

     'topics
     (for/list ([filename topics]
                #:when (path-has-extension? filename #".json"))
       (let ([json (string->jsexpr (file->string filename))])
         (topic (hash-ref json 'status)
                (hash-ref json 'name)
                (hash-ref json 'desc)))))))
