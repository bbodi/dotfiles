;; Alapvető csomagkezelés
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Evil Mode
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  ;; Normal mód keybindingek
  (define-key evil-normal-state-map (kbd "l") 'evil-first-non-blank)
  (define-key evil-normal-state-map (kbd "y") 'evil-end-of-line)
  (define-key evil-normal-state-map (kbd "u") 'evil-previous-line)
  (define-key evil-normal-state-map (kbd "e") 'evil-next-line)
  (define-key evil-normal-state-map (kbd "n") 'evil-backward-char)
  (define-key evil-normal-state-map (kbd "i") 'evil-forward-char)
  (define-key evil-normal-state-map (kbd "N") 'evil-backward-word-begin)
  (define-key evil-normal-state-map (kbd "I") 'evil-forward-word-end)
  (define-key evil-normal-state-map (kbd "C-s") 'save-buffer)
  (define-key evil-normal-state-map (kbd "x") 'evil-visual-char)
  (define-key evil-normal-state-map (kbd "X") 'evil-visual-line)
  (define-key evil-normal-state-map (kbd "h") 'evil-insert)
  (define-key evil-normal-state-map (kbd "<escape>") 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "SPC b") 'ivy-switch-buffer)
  (define-key evil-normal-state-map (kbd "SPC f") 'projectile-find-file)
  (define-key evil-normal-state-map (kbd "SPC F") 'find-file)
  (define-key evil-normal-state-map (kbd "d") 'evil-delete-char)
  (define-key evil-normal-state-map (kbd "D") 'evil-delete)
  (define-key evil-normal-state-map (kbd "c") 'evil-yank)
  (define-key evil-normal-state-map (kbd "p") 'evil-paste-before)
  (define-key evil-normal-state-map (kbd "C-u") (lambda () (interactive) (evil-previous-line 4)))
  (define-key evil-normal-state-map (kbd "C-e") (lambda () (interactive) (evil-next-line 4)))
  (define-key evil-normal-state-map (kbd "O") 'evil-search-previous)
  (define-key evil-normal-state-map (kbd "o") 'evil-search-next)
  (define-key evil-normal-state-map (kbd ",") 'evil-repeat-find-char)
  (define-key evil-normal-state-map (kbd "B") 'evil-jump-forward)
  (define-key evil-normal-state-map (kbd "b") 'evil-jump-backward)
  (define-key evil-normal-state-map (kbd "a") 'er/expand-region)
  (define-key evil-normal-state-map (kbd "A") 'er/contract-region)
  (define-key evil-normal-state-map (kbd "m") 'evil-jump-item)
  (define-key evil-normal-state-map (kbd "(") 'evil-surround-region)
  (define-key evil-normal-state-map (kbd ")") 'evil-surround-delete)
  (define-key evil-normal-state-map (kbd "=") 'evil-surround-change)
  (define-key evil-normal-state-map (kbd "H") (lambda () (interactive) (evil-delete-line) (evil-insert)))
  (define-key evil-normal-state-map (kbd "RET") 'evil-append)
  (define-key evil-normal-state-map (kbd "_") 'evil-change)
  (define-key evil-normal-state-map (kbd "-") 'evil-replace)
  (define-key evil-normal-state-map (kbd "z") 'undo-tree-undo)
  (define-key evil-normal-state-map (kbd "Z") 'undo-tree-redo)
  (define-key evil-normal-state-map (kbd "j") 'evil-open-above)
  (define-key evil-normal-state-map (kbd "k") 'evil-open-below)
  (define-key evil-normal-state-map (kbd "J") 'evil-open-above)
  (define-key evil-normal-state-map (kbd "K") 'evil-open-below)

  ;; Org-Mode
  (evil-define-key 'normal org-mode-map (kbd "M-i") 'org-do-demote)
  (evil-define-key 'normal org-mode-map (kbd "M-n") 'org-do-promote)
  (evil-define-key 'normal org-mode-map (kbd "M-u") 'org-move-subtree-up)
  (evil-define-key 'normal org-mode-map (kbd "M-e") 'org-move-subtree-down)
  ;; Visual mód keybindingek
  (define-key evil-visual-state-map (kbd "w") 'evil-visual-char)
  (define-key evil-visual-state-map (kbd "C-s") (lambda () (interactive) (evil-normal-state) (save-buffer)))
  (define-key evil-visual-state-map (kbd "<escape>") 'evil-normal-state)
  (define-key evil-visual-state-map (kbd "l") 'evil-first-non-blank)
  (define-key evil-visual-state-map (kbd "y") 'evil-end-of-line)
  (define-key evil-visual-state-map (kbd "u") 'evil-previous-line)
  (define-key evil-visual-state-map (kbd "e") 'evil-next-line)
  (define-key evil-visual-state-map (kbd "n") 'evil-backward-char)
  (define-key evil-visual-state-map (kbd "i") 'evil-forward-char)
  (define-key evil-visual-state-map (kbd "N") 'evil-backward-word-begin)
  (define-key evil-visual-state-map (kbd "I") 'evil-forward-word-end)
  (define-key evil-visual-state-map (kbd "d") 'evil-delete-char)
  (define-key evil-visual-state-map (kbd "D") 'evil-delete)
  (define-key evil-visual-state-map (kbd "c") 'evil-yank)
  (define-key evil-visual-state-map (kbd "p") 'evil-paste-before)
  (define-key evil-visual-state-map (kbd "C-u") (lambda () (interactive) (evil-previous-line 4)))
  (define-key evil-visual-state-map (kbd "C-e") (lambda () (interactive) (evil-next-line 4)))
  (define-key evil-visual-state-map (kbd "O") 'evil-search-previous)
  (define-key evil-visual-state-map (kbd "o") 'evil-search-next)
  (define-key evil-visual-state-map (kbd ",") 'evil-repeat-find-char)
  (define-key evil-visual-state-map (kbd "a") 'er/expand-region)
  (define-key evil-visual-state-map (kbd "A") 'er/contract-region)
  (define-key evil-visual-state-map (kbd "m") 'evil-jump-item)
  (define-key evil-visual-state-map (kbd "(") 'evil-surround-region)
  (define-key evil-visual-state-map (kbd ")") 'evil-surround-delete)
  (define-key evil-visual-state-map (kbd "=") 'evil-surround-change)
  (define-key evil-visual-state-map (kbd "_") 'evil-change)
  (define-key evil-visual-state-map (kbd "-") 'evil-replace)
  (define-key evil-visual-state-map (kbd "z") 'undo-tree-undo)
  (define-key evil-visual-state-map (kbd "Z") 'undo-tree-redo)
  (define-key evil-visual-state-map (kbd "j") 'evil-open-above)
  (define-key evil-visual-state-map (kbd "k") 'evil-open-below)
  ;; Ablakkezelési parancsok (Helix [keys.normal.W])
  (define-key evil-normal-state-map (kbd "W I") 'evil-window-vsplit)
  (define-key evil-normal-state-map (kbd "W E") 'evil-window-split)
  (define-key evil-normal-state-map (kbd "W q") 'evil-window-delete)
  (define-key evil-normal-state-map (kbd "W k") 'delete-other-windows)
  (define-key evil-normal-state-map (kbd "W i") 'evil-window-right)
  (define-key evil-normal-state-map (kbd "W e") 'evil-window-down)
  (define-key evil-normal-state-map (kbd "W u") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "W n") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "W w") 'evil-window-rotate-downwards)

  ;; Opcionális: ugyanazok a kötések visual módban
  (define-key evil-visual-state-map (kbd "W I") 'evil-window-vsplit)
  (define-key evil-visual-state-map (kbd "W E") 'evil-window-split)
  (define-key evil-visual-state-map (kbd "W q") 'evil-window-delete)
  (define-key evil-visual-state-map (kbd "W k") 'delete-other-windows)
  (define-key evil-visual-state-map (kbd "W i") 'evil-window-right)
  (define-key evil-visual-state-map (kbd "W e") 'evil-window-down)
  (define-key evil-visual-state-map (kbd "W u") 'evil-window-up)
  (define-key evil-visual-state-map (kbd "W n") 'evil-window-left)
  (define-key evil-visual-state-map (kbd "W w") 'evil-window-rotate-downwards)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W I") 'evil-window-vsplit)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W E") 'evil-window-split)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W q") 'evil-window-delete)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W k") 'delete-other-windows)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W i") 'evil-window-right)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W e") 'evil-window-down)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W u") 'evil-window-up)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W n") 'evil-window-left)
  (evil-define-key 'motion org-agenda-mode-map (kbd "W w") 'evil-window-rotate-downwards)


  ; (global-set-key (kbd "C-c a") 'org-agenda)
  ;; Org-Mode
  (evil-define-key 'normal org-mode-map (kbd "C-t l") 'org-clock-in)
  (evil-define-key 'normal org-mode-map (kbd "C-t L") 'org-clock-out)
  (evil-define-key 'normal org-mode-map (kbd "C-t g") 'org-clock-goto)
  (evil-define-key 'normal org-mode-map (kbd "C-t a") 'org-agenda)
  (evil-define-key 'normal org-mode-map (kbd "C-t N") 'org-add-note)
  (evil-define-key 'normal org-mode-map (kbd "C-t K") 'org-insert-heading-respect-content)
  (evil-define-key 'normal org-mode-map (kbd "C-t J") (lambda () (interactive) (evil-previous-line) (end-of-line) (org-insert-heading-respect-content)))
  (evil-define-key 'normal org-mode-map (kbd "C-t /") 'counsel-org-goto)
  (evil-define-key 'normal org-mode-map (kbd "C-t o") 'org-todo-list)

  (evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle)
)

;; Expand Region csomag
(use-package expand-region
  :commands (er/expand-region er/contract-region))

;; Evil Surround csomag
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

;; Undo Tree csomag
(use-package undo-tree
  :config
  (global-undo-tree-mode 1))

;; Ivy csomag buffer tallózáshoz
(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) "))

;; Counsel az Ivy-ra épülve, fuzzy kereséshez
(use-package counsel
  :after ivy  ; Biztosítja, hogy Ivy után töltődjön be
  :config
  (counsel-mode 1))  ; Aktiválja a Counsel módot

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(package-selected-packages nil)
 '(safe-local-variable-values '((eval add-to-list 'org-agenda-files (buffer-file-name)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Evil Collection a Dired és más módok jobb integrációjához
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init '(dired org))
)

(find-file "~/Documents/new/todo.org")
