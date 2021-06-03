#lang racket/base

(provide
 seconds->iso-8601-string/utc)

(require
 racket/date
 tzinfo)

(when (not (system-tzid))
  (error "(system-tzid) could not determine system timezone!"))

(define (seconds->iso-8601-string/utc seconds)
  (let ([offset (tzoffset-utc-seconds
                 (local-seconds->tzoffset (system-tzid) seconds))])
    (date-display-format 'iso-8601)
    (date->string (seconds->date (- seconds offset)) #t)))
