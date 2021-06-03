#lang racket/base

(provide
 request-is?
 respond
 respond/html
 respond/json
 url-path->file-extension
 mime-types)

(require
 racket/path
 net/url
 web-server/http
 web-server/http/response-structs)

(define (request-is? req m path-match)
  (let ([method-actual (bytes->string/utf-8 (request-method req))]
        [method-match (symbol->string m)]
        [path-actual (url->string (request-uri req))]
        [path-fn (if (regexp? path-match) regexp-match? string=?)])
    (and (string=? method-actual method-match)
         (path-fn path-match path-actual))))

(define (respond body
                 #:code [code 200]
                 #:mime mime
                 #:headers [headers null])
  (response/full
   code #f
   (current-seconds)
   (if mime (hash-ref mime-types mime) #f)
   headers
   (list body)))

(define (respond/html html-body
                      #:code [code 200]
                      #:headers [headers null])
  (respond html-body
           #:code code
           #:mime 'html
           #:headers headers))

(define (respond/json json-body
                      #:code [code 200]
                      #:headers [headers null])
  (respond json-body
           #:code code
           #:mime 'json
           #:headers headers))

(define url-path->file-extension
  (compose1 string->symbol
            (λ (s) (substring s 1))
            bytes->string/utf-8
            path-get-extension))

(define mime-types
  (hasheq 'html  #"text/html; charset=utf-8"
          'css   #"text/css; charset=utf-8"
          'js    #"text/javascript; charset=utf-8"

          'md    #"text/markdown; charset=utf-8"
          'txt   #"text/plain; charset=utf-8"
          'json  #"application/json; charset=utf-8"
          'xml   #"application/xml; charset=utf-8"
          'rss   #"text/xml; charset=utf-8"
          'zip   #"application/zip"

          'svg   #"image/svg+xml; charset=utf-8"
          'jpg   #"image/jpeg"
          'png   #"image/png"
          'gif   #"image/gif"
          'webp  #"image/webp"
          'ico   #"image/vnd.microsoft.icon"

          'otf   #"font/otf"
          'ttf   #"font/ttf"
          'woff  #"font/woff"
          'woff2 #"font/woff2"

          'bin   #"application/octet-stream"))
