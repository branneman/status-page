#lang racket/base

(provide
 backup-restore
 backup-now)

; throw (and exit) on error
; rm data/*.json + data/topics/*.json
; download last json files from S3
(define (backup-restore)
  (void))

; dont throw on error (log error, but continue execution)
; upload contents of data folder to S3
(define (backup-now)
  (void))
