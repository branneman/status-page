#lang racket/base

(provide
 server-start)

(require
 racket/file
 net/url
 markdown
 web-server/http
 web-server/servlet-env
 web-server/managers/none
 "util/base-dir.rkt"
 "util/log.rkt"
 "util/path.rkt"
 "util/web-server.rkt")

(define (data-dir) (simplify-path (build-path (base-dir) "data/")))
(define (htdocs-dir) (simplify-path (build-path (base-dir) "htdocs/")))
(define (data-file f) (file->bytes (build-path (data-dir) f)))
(define (htdocs-file f) (file->bytes (build-path (htdocs-dir) f)))

(define (server-start)
  (log! "Server running at port 8000")
  (log! "Ctrl-C or SIGINT to exit.")
  (serve/servlet
   dispatcher
   #:listen-ip #f
   #:port 8000
   #:stateless? #t
   #:manager (create-none-manager #f)
   #:command-line? #t
   #:banner? #f
   #:servlet-regexp #rx""
   #:servlets-root (data-dir)
   #:server-root-path (data-dir)))

(define (dispatcher req)
  (with-handlers
    ([exn:fail?
      (λ (e)
        (log-error! e)
        (respond/html #:code 500 (htdocs-file "500.html")))])

    (let ([req-is? (λ (m p) (request-is? req m p))]
          [method (request-method req)]
          [path (url->string (request-uri req))]
          [path1 (substring (url->string (request-uri req)) 1)])

      (log! (string-append (bytes->string/utf-8 method) " " path))

      (cond

        [(req-is? 'GET "/")
         (respond/html (htdocs-file "index.html"))]

        [(req-is? 'GET "/api")
         (respond/json (data-file "status.json"))]

        [(req-is? 'POST "/api")
         (respond #:code (handle-api-post-markdown req)
                  #:mime #f
                  #"")]

        [(and (req-is? 'GET #px"/static/.+")
              (path-prefix? (build-path (htdocs-dir) path1)
                            (build-path (htdocs-dir) "static/")))
         (respond/static path1)]

        [(req-is? 'GET "/favicon.ico")
         (respond #:mime 'ico (htdocs-file "favicon.ico"))]

        [else
         (respond/404)]))))

(define (respond/static path1)
  (let ([filename (build-path (htdocs-dir) path1)])
    (cond
      [(file-exists? filename)
       (respond #:mime (url-path->file-extension filename)
                (htdocs-file path1))]
      [else
       (respond/404)])))

(define (respond/404)
  (respond/html #:code 404 (htdocs-file "404.html")))

(define (handle-api-post-markdown req)
  (sleep 5) ; poor man's brute-force protection

  (with-handlers
    ([exn:fail?
      (λ (e)
        (log-error! e)
        500)])

    (cond
      [(not (is-valid-token? (getenv "TOKEN") req))
       (log! "Invalid token provided.")
       401]

      [(bytes=? #"" (request-post-data/raw req))
       (delete-file/if-exists (build-path (data-dir) "message.html"))
       (log! "Override message cleared.")
       200]

      [else
       (display-to-file (markdown->html (bytes->string/utf-8 (request-post-data/raw req)))
                        (build-path (data-dir) "message.html")
                        #:exists 'replace)
       (log! "Override message updated.")
       200])))

(define (is-valid-token? token req)
  (with-handlers ([exn:fail? (λ (_) #f)])
    (let* ([auth-header (headers-assq* #"authorization" (request-headers/raw req))]
           [val (header-value auth-header)])
      (cond
        [(not auth-header)
         #f]
        [(< (bytes-length val) (bytes-length #"Bearer "))
         #f]
        [(not (bytes=? #"Bearer " (subbytes val 0 7)))
         #f]
        [else
         (bytes=? (string->bytes/utf-8 token)
                  (subbytes val 7))]))))

(define (markdown->html md)
  (let ([xexprs (parse-markdown md)]
        [out (open-output-string)])
    (parameterize ([current-output-port out])
      (map display-xexpr xexprs))
    (get-output-string out)))

(define (delete-file/if-exists f)
  (with-handlers ([exn:fail:filesystem? void])
    (delete-file f)
    (void)))
