#lang racket/base

(provide
 path-prefix?)

(require
 racket/string)
(module+ test
  (require rackunit))

(define (path-prefix? path path-prefix)
  (string-prefix? (path->string (simplify-path (cleanse-path path)))
                  (path->string (simplify-path (cleanse-path path-prefix)))))
(module+ test
  (test-case "path-prefix?"
    (check-true
     (path-prefix? (build-path "/home/user/status-page/style.css")
                   (build-path "/home/user/status-page")))
    (check-false
     (path-prefix? (build-path "/home/user/style.css")
                   (build-path "/home/user/status-page")))
    (check-false
     (path-prefix? (build-path "/etc/passwd")
                   (build-path "/home/user/status-page")))))
