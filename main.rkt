#lang racket/base

(require
 racket/runtime-path
 "src/util/base-dir.rkt"
 "src/util/log.rkt"
 "src/util/on-interval.rkt"
 "src/topics/index.rkt"
 "src/status-page/index.rkt"
 "src/backup.rkt"
 "src/web-server.rkt")

(define-runtime-path runtime-base-dir ".")
(base-dir runtime-base-dir)

(register-topics)

(backup-restore)
(topics-update-all!)
(write-status-page!)

(void (thread server-start))

(with-handlers
  ([exn:break? (λ (_) (exit))]
   [exn:fail? (λ (e) (log-error! e))])

  (thread
   (on-interval
    (* 60 10) ; 10 minutes
    (topics-update-all!)
    (write-status-page!)
    (backup-now))))
