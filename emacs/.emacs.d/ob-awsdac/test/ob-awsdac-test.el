;;; ob-awsdac-test.el --- Tests for ob-awsdac -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'ob-awsdac)

(ert-deftest ob-awsdac-requires-file ()
  (should-error (org-babel-execute:awsdac "Diagram: {}" nil)
                :type 'user-error))

(ert-deftest ob-awsdac-builds-supported-arguments ()
  (should
   (equal
    (ob-awsdac--arguments
     "/tmp/input.yaml" "/tmp/output.png"
     '((:width . 1200)
       (:height . "800")
       (:allow-untrusted-definitions . "yes")
       (:template . "true")
       (:cmdline . "--verbose")))
    '("/tmp/input.yaml" "--output" "/tmp/output.png" "--force"
      "--width" "1200" "--height" "800"
      "--allow-untrusted-definitions" "--template" "--verbose"))))

(ert-deftest ob-awsdac-renders-file ()
  (let* ((directory (make-temp-file "ob-awsdac-test-" t))
         (output (expand-file-name "diagram.png" directory))
         (ob-awsdac-cli-path (or (executable-find "true") "/usr/bin/true")))
    (unwind-protect
        (cl-letf (((symbol-function 'process-file)
                   (lambda (_program _infile _destination _display &rest args)
                     (let ((target (cadr (member "--output" args))))
                       (with-temp-file target (insert "image")))
                     0)))
          (should-not
           (org-babel-execute:awsdac
            "Diagram:\n  Resources: {}"
            `((:file . ,output))))
          (should (file-exists-p output)))
      (delete-directory directory t))))

(provide 'ob-awsdac-test)

;;; ob-awsdac-test.el ends here
