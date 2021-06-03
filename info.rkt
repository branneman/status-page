#lang info

(define name "status-page")
(define version "1.0")
(define pkg-authors '(branneman))
(define pkg-desc "Communicate service status to your users via a web page.")

(define deps
  '("html-template"
    "markdown"
    "tzinfo"))
