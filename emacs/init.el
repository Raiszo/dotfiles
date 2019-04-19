(package-initialize)
(setq package-check-signature nil)

;; (set-frame-parameter (selected-frame) 'alpha '(85 . 50))
;; (add-to-list 'default-frame-alist '(alpha . (85 . 50)))

(require 'package)
;;Add melpa repository
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
													("melpa" . "http://melpa.milkbox.net/packages/")) )

(setq package-list '(js2-mode undo-tree company-tern company ace-window neotree multiple-cursors multi-term monokai-theme powerline magit highlight-indent-guides ob-mongo zoom-window nyan-mode farmhouse-theme yasnippet zoom-window emojify org-bullets org-trello all-the-icons expand-region telephone-line markdown-mode darkokai-theme phi-search nodejs-repl exec-path-from-shell ob-sql-mode elpy use-package projectile persp-projectile dockerfile-mode nginx-mode yaml-mode))

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


(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/intento1.el")
;;(load-theme 'monokai-theme)
(add-hook 'after-init-hook (lambda () (load-theme 'darkokai)))
(setq darkokai-mode-line-padding 1)
(load-theme 'darkokai t)

(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'on-after-init)

;;Custom tab length
;; (setq-default tab-width 2)
(add-hook 'after-init-hook 'global-company-mode)


;; (setq-default tab-always-indent t)
;; make return key also do indent, globally
(electric-indent-mode 1)

;;(global-set-key "\M-[1;5C"    'forward-word)      ; Ctrl+right   => forward word
;;(global-set-key "\M-[1;5D"    'backward-word)     ; Ctrl+left    => backward word

;;(require 'auto-complete)
;;(require 'auto-complete-config)
;;(ac-config-default)
;;(add-hook 'js2-mode-hook 'ac-js2-mode)



;; js-mode
;; (setq js-indent-level 2)

;; js2-mode
(setq js2-strict-missing-semi-warning nil)
(setq js2-include-node-externs t)

;; LSP mode config
(use-package lsp-mode
  :commands lsp
	:init
	(setq lsp-enable-indentation nil)
	(setq lsp-prefer-flymake nil)
	)
(add-hook 'python-mode-hook #'lsp)
(require 'company-lsp)
(push 'company-lsp company-backends)

;; js-mode
;; (setq js-indent-level 2)

(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
(setq-default js2-basic-offset 4)

(require 'undo-tree)
(global-undo-tree-mode)

(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
;; (setq neo-smart-open t)

(require 'all-the-icons)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(require 'multiple-cursors)
(global-set-key (kbd "C-c C-v") 'mc/edit-lines)
(global-set-key (kbd "C-<") 'mc/mark-next-like-this)
(global-set-key (kbd "C->") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-q") 'mc/mark-all-like-this)

(require 'ace-window)
(global-set-key (kbd "M-o") 'ace-window)
(require 'zoom-window)
(global-set-key (kbd "C-x 4") 'zoom-window-zoom)
(setq zoom-window-mode-line-color "DarkViolet")


(require 'nyan-mode)
(nyan-mode t)
(nyan-start-animation)
(nyan-toggle-wavy-trail)

(require 'highlight-indent-guides)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)

(require 'multi-term)
;; want to use Ace-window here, so delete it from the alist
(delete* "M-o" term-bind-key-alist :test 'equal :key 'car)
;; (delete* "M-^?" term-bind-key-alist :test 'equal :key 'car)
;; No need to add-to-list, just to be clear with the new functionality :D
(add-to-list 'term-bind-key-alist '("M-o" . ace-window))
;; (assoc "M-o" term-bind-key-alist)

(when (version<= "26.0.50" emacs-version )
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (set-face-attribute 'line-number-current-line nil :background "#7fffd4" :foreground "black" :weight 'bold))

;; (global-linum-mode t)
;; (setq linum-format "%d")
(show-paren-mode)
(electric-pair-mode)
(ido-mode t)
;; (setq web-mode-enable-auto-closing t)
(global-hl-line-mode +1)


;; Setting transparency, not working like urxvt
(set-frame-parameter (selected-frame) 'alpha '(85 85))
(add-to-list 'default-frame-alist '(alpha 85 85))

(require 'yasnippet)
(yas-load-directory "~/.emacs.d/snippets")
(yas-reload-all)
(add-hook 'js2-mode-hook #'yas-minor-mode)

(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))


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

(require 'org-trello)
(setq org-trello-files (directory-files "~/Documents/trello" t "\\.org$"))


(require 'emojify)
(add-hook 'after-init-hook #'global-emojify-mode)
(setq emojify-user-emojis '((":trollface:" . (("name" . "Troll Face")
																							("image" . "~/.emacs.d/emojis/custom/trollface.png")
                                              ("style" . "github")))
														(":kappa:" . (("name". "Kappa")
																					("image" . "~/.emacs.d/emojis/custom/kappa.png")
																					("style" . "github")))
														))
;; If emojify is already loaded refresh emoji data
(when (featurep 'emojify)
  (emojify-set-emoji-data))
(emojify-mode-line-mode)

;; Use DejaVu Sans Mono Nerd Font

(set-face-attribute 'default nil :font "DejaVuSansMono Nerd Font Mono")
(set-face-attribute 'default nil :height 135)
;; (require 'powerline)
;; (powerline-default-theme)
;; (setq powerline-default-separator 'wave)

(require 'expand-region)
(if (memq window-system '(mac ns x))
		(global-set-key (kbd "C-=") 'er/expand-region)
	(global-set-key (kbd "C-¿") 'er/expand-region))



(require 'telephone-line)
(defface my-indianRed '((t (:foreground "white" :background "IndianRed1"))) "")
(defface my-gold '((t (:foreground "black" :background "gold"))) "")

;; this not working yet D:
(telephone-line-defsegment* s1 ()
	":dagger:")

(setq telephone-line-faces
			'((indianGold . (my-gold . my-indianRed))
				(accent . (telephone-line-accent-active . telephone-line-accent-inactive))
				(nil . (mode-line . mode-line-inactive))))
(setq telephone-line-lhs
      '((indianGold . (telephone-line-process-segment
											telephone-line-vc-segment
											telephone-line-erc-modified-channels-segment))
        (nil			. (telephone-line-buffer-segment
										 telephone-line-major-mode-segment
										 telephone-line-nyan-segment))))
(setq telephone-line-rhs
      '((nil    . (telephone-line-misc-info-segment))
        (accent . (telephone-line-minor-mode-segment))
        (indianGold   . (telephone-line-airline-position-segment))))
(telephone-line-mode 1)

;; Magit
(global-set-key [f5] 'magit-status)
;; ibuffer, I like to kill buffers :)
(global-set-key [f6] 'ibuffer)



(require 'phi-search)
(global-set-key (kbd "C-s") 'phi-search)
(global-set-key (kbd "C-r") 'phi-search-backward)

;; Python
(elpy-enable)
;; (global-flycheck-mode)
;; (when (require 'flycheck nil t)
;;   (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
;;   (add-hook 'elpy-mode-hook 'flycheck-mode))
(add-hook 'elpy-mode-hook (lambda () (highlight-indentation-mode -1)))

;; persp-mode
(projectile-mode +1)
(persp-mode)
(require 'persp-projectile)
(define-key projectile-mode-map (kbd "C-c p") 'persp-switch)

(defun my-web-mode-hook ()
  (setq web-mode-markup-indent-offset 2)
  (web-mode-use-tabs)
  (setq-default tab-width 4)
)
(use-package web-mode
  :mode (("\\.html$" . web-mode)
	 ("\\.ejs$" . web-mode))
  :init
  (add-hook 'web-mode-hook  'my-web-mode-hook)
  )

(use-package emmet-mode
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'web-mode-hook 'emmet-mode)
  )

(use-package restclient-mode
  :mode (("\\.http$" . restclient-mode))
  )

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1)
  )

(use-package rainbow-delimiters
  :ensure t
  :config
  (rainbow-delimiters-mode 1)
  )
