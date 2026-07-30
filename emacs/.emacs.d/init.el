(package-initialize)
;; need to set this so the emacs process follows the symlink (~/.emacs.d) to dotfiles
(setq vc-follow-symlinks t)
(org-babel-load-file "~/.emacs.d/configuration.org")
