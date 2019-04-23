(package-initialize)
(setq package-check-signature nil)

(require 'package)
;;Add melpa repository
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
													("melpa" . "http://melpa.milkbox.net/packages/")) )

(setq package-list '(js2-mode monokai-theme ob-mongo farmhouse-theme org-trello all-the-icons markdown-mode darkokai-theme phi-search nodejs-repl exec-path-from-shell ob-sql-mode elpy use-package dockerfile-mode nginx-mode yaml-mode))

;; macos only stuff >:v, pice of crap
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize)
  (setq mac-right-option-modifier 'none))


(dolist (package package-list)
  (unless (package-installed-p package)
    (package-refresh-contents)
    (package-install package)))

;; (defun my-insert-tab-char ()
;; 	"Insert a tab char. (ASCII 9, \t)"
;; 	(interactive)
;; 	  (insert "\t"))
;; (global-set-key [tab] 'tab-to-tab-stop) ; same as Ctrl+i


;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/intento1.el")
;;(load-theme 'monokai-theme)
(add-hook 'after-init-hook (lambda () (load-theme 'darkokai)))
(setq darkokai-mode-line-padding 1)
(load-theme 'darkokai t)

(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'on-after-init)

;; (setq-default tab-width 2)
;; (add-hook 'after-init-hook 'global-company-mode)


;; (setq-default tab-always-indent t)
;; make return key also do indent, globally
(electric-indent-mode 1)

;; js2-mode
(setq js2-strict-missing-semi-warning nil)
(setq js2-include-node-externs t)

(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
(setq-default js2-basic-offset 4)

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1)
  )

(use-package all-the-icons
  :ensure t
  )

(use-package multiple-cursors
  :ensure t
  :bind (("C-c C-v" . 'mc/edit-lines)
	 ("C-<" . 'mc/mark-next-like-this)
	 ("C->" . mc/mark-previous-like-this)
	 ("C-c C-q" . mc/mark-all-like-this))
  )

(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window)
  )

(use-package zoom-window
  :ensure t
  :bind ("C-x 4" . zoom-window-zoom)
  :custom
  (zoom-window-mode-line-color "DarkViolet" "Distinctive color when using zoom")
  )

(use-package nyan-mode
  :ensure t
  :config
  (nyan-mode 1)
  (nyan-start-animation)
  (nyan-toggle-wavy-trail)
  )

(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character)
  (highlight-indent-guides-mode 1)
  )

(use-package multi-term
  :ensure t
  :config
  ;; want to use Ace-window here, so delete it from the alist
  (delete* "M-o" term-bind-key-alist :test 'equal :key 'car)
  ;; No need to add-to-list, just to be clear with the new functionality :D
  (add-to-list 'term-bind-key-alist '("M-o" . ace-window))
  )


(when (version<= "26.0.50" emacs-version )
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (set-face-attribute 'line-number-current-line nil
		      :background "#7fffd4"
		      :foreground "black"
		      :weight 'bold))

(show-paren-mode)
(electric-pair-mode)
(ido-mode t)
(global-hl-line-mode +1)


;; Setting transparency, not working like urxvt
(set-frame-parameter (selected-frame) 'alpha '(85 85))
(add-to-list 'default-frame-alist '(alpha 85 85))

(use-package yasnippet
  :ensure t
  :config
  (yas-load-directory "~/.emacs.d/snippets")
  (yas-reload-all)
  (add-hook 'js2-mode-hook #'yas-minor-mode))

(use-package org-bullets
  :ensure t
  :hook (org-mode . (lambda () (org-bullets-mode 1)))
  )



(org-babel-do-load-languages
 'org-babel-load-languages
 '((lisp . t)
	 (C . t)
	 (emacs-lisp . t)
	 (latex . t)
	 (mongo . t)
	 (sql . t)))
(setq org-confirm-babel-evaluate nil)
(require 'ob-js)

;; more space in GUI mode :D
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; (defun on-after-init ()
;;  (unless (display-graphic-p (selected-frame))
;;    (set-face-background 'default "unspecified-bg" (selected-frame))))

;; (add-hook 'window-setup-hook 'on-after-init)

;; (setq org-src-window-setup 'current-window)
(require 'org)
(add-to-list 'org-src-lang-modes '("js" . js2))
(set-face-attribute 'org-meta-line nil :background "black" :foreground "pink")
(set-face-attribute 'org-block-begin-line nil :background "black" :foreground "green")
(set-face-attribute 'org-block-end-line nil :background "black" :foreground "green")

;; (require 'org-trello)
;; (setq org-trello-files (directory-files "~/Documents/trello" t "\\.org$"))


(use-package emojify
  :ensure t
  :hook (after-init . global-emojify-mode)
  :config
  (setq emojify-user-emojis
	'((":trollface:" . (("name" . "Troll Face")
			    ("image" . "~/.emacs.d/emojis/custom/trollface.png")
			    ("style" . "github")))
	  (":kappa:" . (("name". "Kappa")
			("image" . "~/.emacs.d/emojis/custom/kappa.png")
			("style" . "github")))
	  ))
  (when (featurep 'emojify)
    (emojify-set-emoji-data))
  (emojify-mode-line-mode 1)
  )

;; Use DejaVu Sans Mono Nerd Font

(set-face-attribute 'default nil :font "DejaVuSansMono Nerd Font Mono")
(set-face-attribute 'default nil :height 135)

(use-package expand-region
  :ensure t
  :bind ("C-=" . 'er/expand-region)
  )

(use-package telephone-line
  :ensure t
  :config
  (defface my-indianRed '((t (:foreground "white" :background "IndianRed1"))) "")
  (defface my-gold '((t (:foreground "black" :background "gold"))) "")
  (setq telephone-line-faces
  	'((indianGold . (my-gold . my-indianRed))
  	  (accent . (telephone-line-accent-active . telephone-line-accent-inactive))
  	  (nil . (mode-line . mode-line-inactive))))
  (setq telephone-line-lhs
  	'((indianGold . (telephone-line-vc-segment
			 telephone-line-erc-modified-channels-segment
			 telephone-line-process-segment))
  	  (nil . (telephone-line-major-mode-segment
  		  telephone-line-buffer-segment))
	  ;; when splitting the window it gets trimmed to 1 ;'v
	  ;; refer to this issue https://github.com/dbordak/telephone-line/issues/41
	  (nil . (telephone-line-nyan-segment))
	  ))
  (setq telephone-line-rhs
  	'((nil . (telephone-line-misc-info-segment))
  	  (accent . (telephone-line-minor-mode-segment))
  	  (indianGold . (telephone-line-airline-position-segment))
	  ))
  (telephone-line-mode 1)
  )
;; this not working yet D:
;; (telephone-line-defsegment* s1 ()
;; 	":dagger:")

(use-package magit
  :ensure t
  :bind ("<f5>" . magit-status)
  )

;; ibuffer, I like to kill buffers :)
(global-set-key [f6] 'ibuffer)


(use-package phi-search
  :ensure t
  :bind (("C-s" . phi-search)
	 ("C-r" . phi-search-backward))
  )


(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  )

(use-package persp-projectile
  :ensure t
  :bind ("C-c p" . persp-switch)
  :config
  (persp-mode 1)
  )

;; (use-package pipenv
;;   :hook (python-mode . pipenv-mode)
;;   :init
;;   (setq
;;    pipenv-projectile-after-switch-function
;;    #'pipenv-projectile-after-switch-extended)
;;   (setq pipenv-with-flycheck nil)
;;   )

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-sideline-ignore-duplicate t)
  (setq lsp-ui-sideline-enable nil))
(use-package company-lsp
  :ensure t
  :commands company-lsp
  :config
  (setq company-dabbrev-downcase 0)
  (setq company-idle-delay 0))

(use-package company               
  :ensure t
  :defer t
  :init (global-company-mode)
  :config
  (progn
    (setq company-tooltip-align-annotations t
          ;; Easy navigation to candidates with M-<n>
          company-show-numbers t)
    (setq company-dabbrev-downcase nil))
  :diminish company-mode)
(use-package company-quickhelp          ; Documentation popups for Company
  :ensure t
  :defer t
  :init (add-hook 'global-company-mode-hook #'company-quickhelp-mode))

;; LSP mode config
(use-package lsp
  :ensure lsp-mode
  :commands lsp
  :hook ((python-mode . lsp)
	 (js2-mode . lsp))
  :config
  (setq lsp-enable-indentation nil)
  (setq lsp-prefer-flymake nil)
  (setq lsp-auto-guess-root t))

;; (defun my-web-mode-hook ()
;;   (setq web-mode-markup-indent-offset 2)
;;   (web-mode-use-tabs)
;;   (setq-default tab-width 4)
;; )
;; (use-package web-mode
;;   :mode (("\\.html$" . web-mode)
;; 	 ("\\.ejs$" . web-mode))
;;   :init
;;   (add-hook 'web-mode-hook  'my-web-mode-hook)
;;   )

;; (use-package emmet-mode
;;   :config
;;   (add-hook 'sgml-mode-hook 'emmet-mode)
;;   (add-hook 'web-mode-hook 'emmet-mode)
;;   )

(use-package yaml-mode
  :ensure t
  :config
  (setq yaml-indent-offset 4)
  )

(use-package restclient
  :ensure t
  :mode (("\\.http$" . restclient-mode))
  )

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :hook ((python-mode . rainbow-delimiters-mode)
	 (emacs-lisp-mode . rainbow-delimiters-mode)))

(use-package treemacs
  :ensure t
  :defer t
  :init
  :bind
  (:map global-map
	("<f8>" . treemacs-select-window))
 )
(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package drag-stuff
  :ensure t
  :init
  (setq drag-stuff-mode t)
  :config
  (drag-stuff-define-keys))
