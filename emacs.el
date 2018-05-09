(package-initialize)
(setq package-check-signature nil)

(require 'package)
;;Add melpa repository
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
													("melpa" . "http://melpa.milkbox.net/packages/")) )

(setq package-list '(js2-mode undo-tree company-tern company ace-window neotree multiple-cursors multi-term monokai-theme powerline magit))

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-refresh-contents)
    (package-install package)))

;; (defun my-insert-tab-char ()
;; 	"Insert a tab char. (ASCII 9, \t)"
;; 	(interactive)
;; 	  (insert "\t"))
;; (global-set-key [tab] 'tab-to-tab-stop) ; same as Ctrl+i
;; (electric-indent-mode 1)


;;(load-theme 'monokai-theme)
(add-hook 'after-init-hook (lambda () (load-theme 'monokai)))

;;Custom tab length
(setq-default tab-width 2)
(add-hook 'after-init-hook 'global-company-mode)


(setq-default tab-always-indent nil)
;; make return key also do indent, globally
(electric-indent-mode 1)
;;(setq tab-stop-list (number-sequence 2 200 2))

;;(require 'auto-complete)
;;(require 'auto-complete-config)
;;(ac-config-default)
;;(add-hook 'js2-mode-hook 'ac-js2-mode)

(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
(add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2)))


;;tern :D shony
(require 'company)
(require 'company-tern)
(add-to-list 'company-backends 'company-tern)
(add-hook 'js2-mode-hook (lambda ()
													 (tern-mode t)
													 (company-mode)))
(setq js2-strict-missing-semi-warning nil)

(setq company-dabbrev-downcase 0)
(setq company-idle-delay 0)

(require 'undo-tree)
(global-undo-tree-mode)

(require 'neotree) 
(global-set-key [f8] 'neotree-toggle)

(require 'multiple-cursors)
(global-set-key (kbd "C-c C-c") 'mc/edit-lines)
(global-set-key (kbd "C-c <") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c >") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-q") 'mc/mark-all-like-this)

(require 'ace-window)
(global-set-key (kbd "M-o") 'ace-window)

(require 'highlight-indent-guides)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)

(global-linum-mode t)
(setq linum-format "%d ")
(show-paren-mode)
(electric-pair-mode)
(ido-mode t)
;;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(setq web-mode-enable-auto-closing t)
(global-hl-line-mode +1)

(require 'multi-term)

(require 'powerline)
(powerline-center-theme)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
	 (quote
		("9fe1540491fcf692b8c639a3abacd32b29233bc4cb834a12a0fd1e01cbd0a128" "f41ecd2c34a9347aeec0a187a87f9668fa8efb843b2606b6d5d92a653abe2439" "3629b62a41f2e5f84006ff14a2247e679745896b5eaa1d5bcfbc904a3441b0cd" "5f27195e3f4b85ac50c1e2fac080f0dd6535440891c54fcfa62cdcefedf56b1b" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 1 :width normal :foundry "default" :family "default")))))
