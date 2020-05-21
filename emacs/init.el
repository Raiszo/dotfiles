(package-initialize)
(setq package-check-signature nil)

(require 'package)
;;Add melpa repository
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
			 ("melpa-stable" . "http://stable.melpa.org/packages/")
			 ("melpa" . "http://melpa.org/packages/")) )

(setq package-list '(js2-mode monokai-theme farmhouse-theme darkokai-theme exec-path-from-shell use-package nginx-mode))

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-refresh-contents)
    (package-install package)))

;; macos only stuff >:v, pice of crap
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize)
  (setq mac-right-option-modifier 'none))

;; (defun my-insert-tab-char ()
;;	"Insert a tab char. (ASCII 9, \t)"
;;	(interactive)
;;	  (insert "\t"))
;; (global-set-key [tab] 'tab-to-tab-stop) ; same as Ctrl+i


;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/intento1.el")
;;(load-theme 'monokai-theme)
;; (add-hook 'after-init-hook (lambda () (load-theme 'darkokai)))
;; (setq darkokai-mode-line-padding 1)
;; (load-theme 'darkokai t)

(use-package doom-themes
  :ensure t
  :init
  (load-theme 'doom-dracula t)
  (setq doom-themes-enable-bold t)
  (setq doom-themes-enable-italic t)
  :config
  (progn
    ;; (doom-themes-treemacs-config)
    (doom-themes-org-config)))

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

(use-package nodejs-repl
  :ensure t)

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1))

(use-package all-the-icons
  :ensure t)

(use-package multiple-cursors
  :ensure t
  :bind (("C-c C-v" . 'mc/edit-lines)
	 ("C-<" . 'mc/mark-next-like-this)
	 ("C->" . mc/mark-previous-like-this)
	 ("C-c C-q" . mc/mark-all-like-this)))

(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))

(use-package zoom-window
  :ensure t
  :bind ("C-x 4" . zoom-window-zoom)
  :custom
  (zoom-window-mode-line-color "DarkViolet" "Distinctive color when using zoom"))

(use-package highlight-indent-guides
  :ensure t
  :hook ((prog-mode yaml-mode) . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character)
  (highlight-indent-guides-mode 1))

(use-package multi-term
  :ensure t
  :config
  ;; want to use Ace-window here, so delete it from the alist
  (delete* "M-o" term-bind-key-alist :test 'equal :key 'car)
  ;; No need to add-to-list, just to be clear with the new functionality :D
  (add-to-list 'term-bind-key-alist '("M-o" . ace-window)))


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
  :hook (org-mode . (lambda () (org-bullets-mode 1))))


(org-babel-do-load-languages
 'org-babel-load-languages
 '((lisp . t)
	 (C . t)
	 (emacs-lisp . t)
	 (latex . t)))
(setq org-confirm-babel-evaluate nil)

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
  (emojify-mode-line-mode 1))

;; Use DejaVu Sans Mono Nerd Font

;; (set-face-attribute 'default nil :font "DejaVuSansMono Nerd Font Mono")
;; (set-face-attribute 'default nil :height 135)

(use-package expand-region
  :ensure t
  :bind ("C-=" . 'er/expand-region))

;; (use-package telephone-line
;;   :ensure t
;;   :config
;;   (defface my-indianRed '((t (:foreground "white" :background "IndianRed1"))) "")
;;   (defface my-gold '((t (:foreground "black" :background "gold"))) "")
;;   (setq telephone-line-faces
;; 	'((indianGold . (my-gold . my-indianRed))
;; 	  (accent . (telephone-line-accent-active . telephone-line-accent-inactive))
;; 	  (nil . (mode-line . mode-line-inactive))))
;;   (setq telephone-line-lhs
;; 	'((indianGold . (telephone-line-vc-segment
;; 			 telephone-line-erc-modified-channels-segment
;; 			 telephone-line-process-segment))
;; 	  (nil . (telephone-line-major-mode-segment
;; 		  telephone-line-buffer-segment))
;; 	  ;; when splitting the window it gets trimmed to 1 ;'v
;; 	  ;; refer to this issue https://github.com/dbordak/telephone-line/issues/41
;; 	  (nil . (telephone-line-nyan-segment))
;; 	  ))
;;   (setq telephone-line-rhs
;; 	'((nil . (telephone-line-misc-info-segment))
;; 	  (accent . (telephone-line-minor-mode-segment))
;; 	  (indianGold . (telephone-line-airline-position-segment))
;; 	  ))
;;   (telephone-line-mode 1))

;; this not working yet D:
;; (telephone-line-defsegment* s1 ()
;;	":dagger:")

(use-package magit
  :ensure t
  :bind ("<f5>" . magit-status))

;; ibuffer, I like to kill buffers :)
(global-set-key [f6] 'ibuffer)


(use-package phi-search
  :ensure t
  :bind (("C-s" . phi-search)
	 ("C-r" . phi-search-backward)))

;; (use-package helm
;;   :ensure t
;;   :pin melpa-stable
;;   ;; when using helm-M-x emacs breaks (14% CPU)
;;   ;; gonna wait for WSL 2.0, maybe it helps :'v
;;   ;; :bind (("M-x" . helm-M-x)
;;   ;; 	 ("C-x C-f" . helm-find-files))
;;   :bind (("C-x C-f" . helm-find-files))
;;   :config
;;   (bind-keys :map helm-map
;; 	     ("TAB" . helm-execute-persistent-action))
;;   (setq helm-split-window-in-side-p t)
;;   ;; (use-package helm-projectile
;;   ;;   :ensure t
;;   ;;   :config
;;   ;;   (helm-projectile-on))
;;   (helm-autoresize-mode 1)
;;   (helm-mode 1))

(use-package projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))
  ;; (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map))
  ;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; (use-package perspective
;;   :ensure t
;;   :config
;;   (persp-mode))

;; (use-package persp-projectile
;;   :ensure t)
  ;; :config
  ;; (define-key projectile-mode-map (kbd "s-s") 'projectile-persp-switch-project))

;; (use-package persp-mode
;;   :ensure persp-projectile
;;   :init
;;   (persp-mode)
;;   :bind (("M-s" . projectile-persp-switch-project)
;; 	 ("C-c p" . 'persp-switch)))

(use-package treemacs
  :ensure t
  :defer t
  :init
  :bind
  (:map global-map
	("<f8>" . treemacs))
  :config
  (progn
    (setq treemacs-width 25)))

(use-package treemacs-projectile
  :ensure t
  :after treemacs projectile)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

;; (use-package treemacs-icons
;;   :after treemacs
;;   :ensure t)

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

;; (use-package origami
;;   :bind (("C-c TAB" . origami-recursively-toggle-node)
;;          ("C-\\" . origami-recursively-toggle-node)
;;          ("M-\\" . origami-close-all-nodes)
;;          ("M-+" . origami-open-all-nodes))
;;   :init
;;   (global-origami-mode))

;; (use-package pipenv
;;   :hook (python-mode . pipenv-mode)
;;   :init
;;   (setq
;;    pipenv-projectile-after-switch-function
;;    #'pipenv-projectile-after-switch-extended)
;;   (setq pipenv-with-flycheck nil)
;;   )

;; posframe
;; (use-package posframe
;;   :ensure t)

;; LSP mode config
(use-package lsp-mode
  :ensure t
  :commands lsp
  :config
  (setq lsp-enable-indentation nil)
  (setq lsp-prefer-flymake nil)
  (setq lsp-auto-guess-root t))

  ;; :init
  ;; (add-hook 'lsp-mode-hook
  ;;           (lambda ()
  ;;             (when (featurep 'perspective)
  ;;               (ad-deactivate 'set-window-buffer)))))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-ignore-duplicate t)
  (setq lsp-ui-sideline-enable nil))

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
  :custom
  (company-idle-delay 0)
  (company-echo-delay 0)
  (company-minimum-prefix-length 1)
  :diminish company-mode)
(use-package company-quickhelp          ; Documentation popups for Company
  :ensure t
  :defer t
  :init (add-hook 'global-company-mode-hook #'company-quickhelp-mode))
(use-package company-lsp
  :ensure t
  :commands company-lsp)
;; (use-package company-box
;;   :ensure t
;;   :hook (company-mode . company-box-mode))

(use-package lsp-python-ms
  :ensure t
  :init (setq lsp-python-ms-auto-install-server t)
  :hook (python-mode . (lambda ()
  			 (require 'lsp-python-ms)
  			 (lsp))))

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
  :mode ("\\.yaml\\'" "\\.yml\\'")
  :config
  (setq yaml-indent-offset 4)
  :custom-face
  (font-lock-variable-name-face ((t (:foreground "violet")))))

(use-package json-mode
  :ensure t)

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package restclient
  :ensure t
  :mode (("\\.http$" . restclient-mode)))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :hook ((python-mode . rainbow-delimiters-mode)
	 (emacs-lisp-mode . rainbow-delimiters-mode)))

(use-package drag-stuff
  :ensure t
  :init
  (setq drag-stuff-mode t)
  :config
  (drag-stuff-define-keys))

(set-face-attribute 'default nil :font "Fira Code" :height 100)

;; (use-package doom-modeline
;;   :ensure t
;;   :custom
;;   (doom-modeline-minor-modes nil)
;;   :init (doom-modeline-mode 1))

(use-package nyan-mode
  :ensure t
  :config
  (nyan-mode 1)
  (nyan-start-animation)
  (nyan-toggle-wavy-trail)
  :hook
  (doom-modeline-mode . nyan-mode))

;; (use-package doom-modeline
;;   :ensure t
;;   :custom
;;   (doom-modeline-buffer-file-name-style 'truncate-with-project)
;;   (doom-modeline-icon t)
;;   (doom-modeline-major-mode-icon t)
;;   (doom-modeline-minor-modes nil)
;;   :init (doom-modeline-mode 1)
;;   :config
;;   (set-cursor-color "cyan"))

(use-package dockerfile-mode
  :ensure t)

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

(use-package go-mode
  :ensure t
  :custom (gofmt-command "goimports")
  :config
  (add-hook 'before-save-hook #'gofmt-before-save)
  (use-package gotest
    :ensure t)
  (use-package go-tag
    :ensure t
    :config (setq go-tag-args (list "-transform"))))

(use-package elixir-mode
  :ensure t)


(when (window-system)
  (set-frame-font "Fira Code"))
(let ((alist '((33 . ".\\(?:\\(?:==\\|!!\\)\\|[!=]\\)")
               (35 . ".\\(?:###\\|##\\|_(\\|[#(?[_{]\\)")
               (36 . ".\\(?:>\\)")
               (37 . ".\\(?:\\(?:%%\\)\\|%\\)")
               (38 . ".\\(?:\\(?:&&\\)\\|&\\)")
               (42 . ".\\(?:\\(?:\\*\\*/\\)\\|\\(?:\\*[*/]\\)\\|[*/>]\\)")
               (43 . ".\\(?:\\(?:\\+\\+\\)\\|[+>]\\)")
               (45 . ".\\(?:\\(?:-[>-]\\|<<\\|>>\\)\\|[<>}~-]\\)")
               (46 . ".\\(?:\\(?:\\.[.<]\\)\\|[.=-]\\)")
               (47 . ".\\(?:\\(?:\\*\\*\\|//\\|==\\)\\|[*/=>]\\)")
               (48 . ".\\(?:x[a-zA-Z]\\)")
               (58 . ".\\(?:::\\|[:=]\\)")
               (59 . ".\\(?:;;\\|;\\)")
               (60 . ".\\(?:\\(?:!--\\)\\|\\(?:~~\\|->\\|\\$>\\|\\*>\\|\\+>\\|--\\|<[<=-]\\|=[<=>]\\||>\\)\\|[*$+~/<=>|-]\\)")
               (61 . ".\\(?:\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\)\\|[<=>~]\\)")
               (62 . ".\\(?:\\(?:=>\\|>[=>-]\\)\\|[=>-]\\)")
               (63 . ".\\(?:\\(\\?\\?\\)\\|[:=?]\\)")
               (91 . ".\\(?:]\\)")
               (92 . ".\\(?:\\(?:\\\\\\\\\\)\\|\\\\\\)")
               (94 . ".\\(?:=\\)")
               (119 . ".\\(?:ww\\)")
               (123 . ".\\(?:-\\)")
               (124 . ".\\(?:\\(?:|[=|]\\)\\|[=>|]\\)")
               (126 . ".\\(?:~>\\|~~\\|[>=@~-]\\)")
               )
             ))
  (dolist (char-regexp alist)
    (set-char-table-range composition-function-table (car char-regexp)
                          `([,(cdr char-regexp) 0 font-shape-gstring]))))
