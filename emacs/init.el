(package-initialize)
(setq package-check-signature nil)

;; (set-frame-parameter (selected-frame) 'alpha '(85 . 50))
;; (add-to-list 'default-frame-alist '(alpha . (85 . 50)))

(require 'package)
;;Add melpa repository
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
													("melpa" . "http://melpa.milkbox.net/packages/")) )

(setq package-list '(js2-mode undo-tree company-tern company ace-window neotree multiple-cursors multi-term monokai-theme powerline magit highlight-indent-guides zoom-window nyan-mode farmhouse-theme yasnippet zoom-window))

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


(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/intento1.el")
;;(load-theme 'monokai-theme)
(add-hook 'after-init-hook (lambda () (load-theme 'farmhouse-dark)))
(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'on-after-init)

;;Custom tab length
(setq-default tab-width 2)
(add-hook 'after-init-hook 'global-company-mode)


(setq-default tab-always-indent nil)
;; make return key also do indent, globally
(electric-indent-mode 1)
;;(setq tab-stop-list (number-sequence 2 200 2))

;;(global-set-key "\M-[1;5C"    'forward-word)      ; Ctrl+right   => forward word
;;(global-set-key "\M-[1;5D"    'backward-word)     ; Ctrl+left    => backward word

;;(require 'auto-complete)
;;(require 'auto-complete-config)
;;(ac-config-default)
;;(add-hook 'js2-mode-hook 'ac-js2-mode)

(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
(setq-default js2-basic-offset 2)
;;(add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2)))


;;tern :D shonny
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

(global-linum-mode t)
(setq linum-format "%d ")
(show-paren-mode)
(electric-pair-mode)
(ido-mode t)
(setq web-mode-enable-auto-closing t)
(global-hl-line-mode +1)

(require 'multi-term)
;; want to use Ace-window here, so delete it from the alist
(delete* "M-o" term-bind-key-alist :test 'equal :key 'car)
;; No need to add-to-list, just to be clear with the new functionality :D
(add-to-list 'term-bind-key-alist '("M-o" . ace-window))
(assoc "M-o" term-bind-key-alist)

(require 'powerline)
(powerline-center-theme)
(setq powerline-default-separator 'wave)

;; Setting transparency, not working like urxvt
(set-frame-parameter (selected-frame) 'alpha '(85 85))
(add-to-list 'default-frame-alist '(alpha 85 85))

(require 'yasnippet)
(yas-load-directory "~/.emacs.d/snippets")
(yas-reload-all)
(add-hook 'js2-mode-hook #'yas-minor-mode)

;; more space in GUI mode :D
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; (defun on-after-init ()
;;  (unless (display-graphic-p (selected-frame))
;;    (set-face-background 'default "unspecified-bg" (selected-frame))))

;; (add-hook 'window-setup-hook 'on-after-init)

;; Use DejaVu Sans Mono Nerd Font

;; (setq org-src-window-setup 'current-window)
(require 'org)
(set-face-attribute 'org-meta-line nil :background "black" :foreground "pink")
(set-face-attribute 'org-block-begin-line nil :background "black" :foreground "green")
(set-face-attribute 'org-block-end-line nil :background "black" :foreground "green")


(set-face-attribute 'default nil :font "DejaVu Sans Mono Nerd Font")



(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
	 (quote
		("cdd26fa6a8c6706c9009db659d2dffd7f4b0350f9cc94e5df657fa295fffec71" default))))
