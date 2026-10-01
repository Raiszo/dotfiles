;;; ob-awsdac.el --- Org Babel support for AWS Diagram-as-Code -*- lexical-binding: t; -*-

;; Copyright (C) 2026

;; Author: raiszo
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1") (org "9.4"))
;; Keywords: literate programming, outlines, tools

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Render AWS Diagram-as-Code YAML in Org Babel source blocks by using
;; the awsdac command-line program.
;;
;; A block must specify its output with a `:file' header argument:
;;
;;   #+begin_src awsdac :file images/architecture.png
;;   Diagram:
;;     Resources:
;;       Canvas:
;;         Type: AWS::Diagram::Canvas
;;         Children:
;;           - User
;;       User:
;;         Type: AWS::Diagram::Resource
;;         Preset: User
;;   #+end_src
;;
;; Optional header arguments are `:width', `:height',
;; `:allow-untrusted-definitions', `:template', and `:cmdline'.

;;; Code:

(require 'ob)
(require 'subr-x)

(defgroup ob-awsdac nil
  "Org Babel support for AWS Diagram-as-Code."
  :group 'org-babel)

(defcustom ob-awsdac-cli-path nil
  "Path to the awsdac executable.

When nil, find awsdac using `executable-find'."
  :group 'ob-awsdac
  :type '(choice (const :tag "Find awsdac in exec-path" nil)
                 (file :tag "awsdac executable")))

(defvar org-babel-default-header-args:awsdac
  '((:results . "file graphics replace")
    (:exports . "results"))
  "Default header arguments for awsdac source blocks.")

(add-to-list 'org-src-lang-modes '("awsdac" . yaml))

(defun ob-awsdac--executable ()
  "Return the configured awsdac executable or signal an error."
  (let ((executable (or ob-awsdac-cli-path
                        (executable-find "awsdac"))))
    (unless executable
      (user-error
       "Could not find awsdac; customize `ob-awsdac-cli-path' or add it to exec-path"))
    (unless (file-executable-p executable)
      (user-error "The awsdac executable is not executable: %s" executable))
    executable))

(defun ob-awsdac--enabled-p (value)
  "Return non-nil when header argument VALUE enables an option."
  (member (downcase (format "%s" value)) '("yes" "true" "t" "1")))

(defun ob-awsdac--arguments (input output params)
  "Build awsdac arguments for INPUT, OUTPUT, and Babel PARAMS."
  (let ((width (cdr (assq :width params)))
        (height (cdr (assq :height params)))
        (allow-untrusted (cdr (assq :allow-untrusted-definitions params)))
        (template (cdr (assq :template params)))
        (cmdline (cdr (assq :cmdline params))))
    (append
     (list input "--output" output "--force")
     (when width (list "--width" (format "%s" width)))
     (when height (list "--height" (format "%s" height)))
     (when (ob-awsdac--enabled-p allow-untrusted)
       (list "--allow-untrusted-definitions"))
     (when (ob-awsdac--enabled-p template)
       (list "--template"))
     (when (and cmdline (not (string-empty-p cmdline)))
       (split-string-and-unquote cmdline)))))

;;;###autoload
(defun org-babel-execute:awsdac (body params)
  "Render awsdac YAML BODY according to Babel PARAMS.

The `:file' header argument is required.  Return nil after awsdac
writes that file so Org Babel inserts the corresponding file link."
  (let ((file-param (cdr (assq :file params))))
    (unless (and file-param (not (string-empty-p file-param)))
      (user-error "An awsdac block requires a :file header argument"))
    (let* ((output (expand-file-name file-param))
           (input (org-babel-temp-file "awsdac-" ".yaml"))
           (executable (ob-awsdac--executable)))
      (make-directory (file-name-directory output) t)
      (unwind-protect
          (progn
            (with-temp-file input
              (insert (org-babel-expand-body:generic body params)))
            (with-temp-buffer
              (let ((status
                     (apply #'process-file executable nil
                            (list (current-buffer) t) nil
                            (ob-awsdac--arguments input output params))))
                (unless (zerop status)
                  (error "Awsdac failed with exit code %d:\n%s"
                         status (string-trim (buffer-string))))))
            (unless (file-exists-p output)
              (error "Awsdac succeeded but did not create %s" output)))
        (when (file-exists-p input)
          (delete-file input)))
      nil)))

(defun org-babel-prep-session:awsdac (_session _params)
  "Signal that awsdac does not support Babel sessions."
  (user-error "Awsdac does not support sessions"))

(provide 'ob-awsdac)

;;; ob-awsdac.el ends here
