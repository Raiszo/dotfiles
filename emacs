(package-initialize)
(setq package-check-signature nil)
(setq-default tab-width 2)

(setq package-list '(js2-mode undo-tree company company-tern ace-window neotree multiple-cursors multi-term monokai))

(dolist (package package-list)
	(unless (package-installed-p package)
		    (package-install package)))


(custom-set-variables
 ;;custom-set-variables was added by Custom.
 ;;If you edit it by hand, you could mess it up, so be careful.
 ;;Your init file should contain only one such instance.
 ;;If there is more than one, they won't work right.
 '(ansi-color-faces-vector
	 [default default default italic underline success warning error])
 '(ansi-color-names-vector
	 ["#272822" "#F92672" "#A6E22E" "#E6DB74" "#66D9EF" "#FD5FF0" "#A1EFE4" "#F8F8F2"])
 '(compilation-message-face (quote default))
 '(custom-enabled-themes (quote (monokai)))
 '(custom-safe-themes
	 (quote
		("615516da346650578b4e81f1d53fc5a93a6fa65cfa4729d09b9a37778524e717" "938d8c186c4cb9ec4a8d8bc159285e0d0f07bad46edf20aa469a89d0d2a586ea" "ed317c0a3387be628a48c4bbdb316b4fa645a414838149069210b66dd521733f" "6de7c03d614033c0403657409313d5f01202361e35490a3404e33e46663c2596" "9b402e9e8f62024b2e7f516465b63a4927028a7055392290600b776e4a5b9905" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "551596f9165514c617c99ad6ce13196d6e7caa7035cea92a0e143dbe7b28be0e" "e269026ce4bbd5b236e1c2e27b0ca1b37f3d8a97f8a5a66c4da0c647826a6664" "3629b62a41f2e5f84006ff14a2247e679745896b5eaa1d5bcfbc904a3441b0cd" "4e4d9f6e1f5b50805478c5630be80cce40bee4e640077e1a6a7c78490765b03f" "4cbec5d41c8ca9742e7c31cc13d8d4d5a18bd3a0961c18eb56d69972bbcf3071" default)))
 '(fci-rule-color "#3C3D37")
 '(highlight-changes-colors (quote ("#FD5FF0" "#AE81FF")))
 '(highlight-tail-colors
	 (quote
		(("#3C3D37" . 0)
		 ("#679A01" . 20)
		 ("#4BBEAE" . 30)
		 ("#1DB4D0" . 50)
		 ("#9A8F21" . 60)
		 ("#A75B00" . 70)
		 ("#F309DF" . 85)
		 ("#3C3D37" . 100))))
 '(js-indent-level 2)
 '(magit-diff-use-overlays nil)
 '(package-archives
	 (quote
		(("gnu" . "http://elpa.gnu.org/packages/")
		 ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(pos-tip-background-color "#FFFACE")
 '(pos-tip-foreground-color "#272822")
 '(term-default-bg-color "#000000")
 '(term-default-fg-color "#dddd00")
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
	 (quote
		((20 . "#F92672")
		 (40 . "#CF4F1F")
		 (60 . "#C26C0F")
		 (80 . "#E6DB74")
		 (100 . "#AB8C00")
		 (120 . "#A18F00")
		 (140 . "#989200")
		 (160 . "#8E9500")
		 (180 . "#A6E22E")
		 (200 . "#729A1E")
		 (220 . "#609C3C")
		 (240 . "#4E9D5B")
		 (260 . "#3C9F79")
		 (280 . "#A1EFE4")
		 (300 . "#299BA6")
		 (320 . "#2896B5")
		 (340 . "#2790C3")
		 (360 . "#66D9EF"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
	 (unspecified "#272822" "#3C3D37" "#F70057" "#F92672" "#86C30D" "#A6E22E" "#BEB244" "#E6DB74" "#40CAE4" "#66D9EF" "#FB35EA" "#FD5FF0" "#74DBCD" "#A1EFE4" "#F8F8F2" "#F8F8F0")))

(require 'package)

(defun my-insert-tab-char ()
	"Insert a tab char. (ASCII 9, \t)"
	(interactive)
	  (insert "\t"))
(global-set-key [tab] 'tab-to-tab-stop) ; same as Ctrl+i
;;(global-set-key (kbd "TAB") 'my-insert-tab-char) ; same as Ctrl+i
;; make tab key call indent command or insert tab character, depending on cursor position
;; (setq-default tab-always-indent nil)
;; make return key also do indent, globally
(electric-indent-mode 1)
;; (setq tab-stop-list (number-sequence 2 200 2))

;; (require 'auto-complete)
;; (require 'auto-complete-config)
;; (ac-config-default)
;; (add-hook 'js2-mode-hook 'ac-js2-mode)



(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
(add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2)))

(require 'company)
(require 'company-tern)
(add-hook 'after-init-hook 'global-company-mode)
(add-to-list 'company-backends 'company-tern)
(add-hook 'js2-mode-hook (lambda()
													 (tern-mode t)
													 (company-mode)))
(setq js2-strict-missing-semi-warning nil)

(setq company-dabbrev-downcase 0)
(setq company-idle-delay 0)

(require 'undo-tree)
(global-undo-tree-mode)


(require 'multiple-cursors)
(global-set-key (kbd "C-c C-v") 'mc/edit-lines)
(global-set-key (kbd "C-c <") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c >") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-q") 'mc/mark-all-like-this)

(global-set-key (kbd "M-o") 'ace-window)

(setq highlight-indent-guides-method 'character)
(global-linum-mode t)
(show-paren-mode)
(electric-pair-mode)
(ido-mode t)
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(setq web-mode-enable-auto-closing t)
(global-hl-line-mode +1)

(require 'neotree)
(global-set-key [f8] 'neotree-toggle)

(require 'multi-term)
       ;; foreground color (yellow)


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 1 :width normal :foundry "default" :family "default")))))
