#lang racket/base

(provide
 dotenv-load-if-exists!
 require-env-vars)

(require
 (only-in dotenv dotenv-read)
 "base-dir.rkt")
(module+ test
  (require rackunit))

(define (dotenv-load-if-exists! [filename ".env"])
  (let ([filepath (build-path (base-dir) "./" filename)])
    (when (file-exists? filepath)
      (let ([dotenv-vars (dotenv-read filepath)]
            [current-vars (current-environment-variables)])
        (current-environment-variables
         (inherit-env-vars dotenv-vars current-vars))))))

(define (require-env-vars names)
  (for ([name names])
    (when (not (getenv name))
      (error (string-append
              "Required environment variable is unset: " name)))))

(define (inherit-env-vars parent child)
  (let ([env (make-environment-variables)])

    (for ([name (environment-variables-names parent)])
      (environment-variables-set!
       env
       name
       (environment-variables-ref parent name)))

    (for ([name (environment-variables-names child)])
      (environment-variables-set!
       env
       name
       (environment-variables-ref child name)))

    env))
(module+ test
  (test-case "inherit-env-vars"
    (let ([env (inherit-env-vars
                (make-environment-variables #"foo" #"from-parent")
                (make-environment-variables #"bar" #"from-child"))])
      (check-equal?
       (environment-variables-ref env #"foo") #"from-parent")
      (check-equal?
       (environment-variables-ref env #"bar") #"from-child"))

    (let ([env (inherit-env-vars
                (make-environment-variables #"foo" #"from-parent"
                                            #"bar" #"from-parent")
                (make-environment-variables))])
      (check-equal?
       (environment-variables-ref env #"foo") #"from-parent")
      (check-equal?
       (environment-variables-ref env #"bar") #"from-parent"))

    (let ([env (inherit-env-vars
                (make-environment-variables)
                (make-environment-variables #"foo" #"from-child"
                                            #"bar" #"from-child"))])
      (check-equal?
       (environment-variables-ref env #"foo") #"from-child")
      (check-equal?
       (environment-variables-ref env #"bar") #"from-child"))

    (let ([env (inherit-env-vars
                (make-environment-variables #"foo" #"from-parent")
                (make-environment-variables #"foo" #"from-child"))])
      (check-equal?
       (environment-variables-ref env #"foo") #"from-child"))))
