

;; ;; ErgoEmacs
(setq ergoemacs-theme nil) ;; Uses Standard Ergoemacs keyboard theme
(setq ergoemacs-keyboard-layout "dv") ; US Dvorak layout
(require 'ergoemacs-mode)

;; ;; turn on minor mode ergoemacs-mode
(ergoemacs-mode 1)

;; Keyboard Shortcuts
(define-key ergoemacs-user-keymap (kbd "M-g") 'backward-word)

(global-set-key (kbd "C-z") 'suspend-frame) ; ctrl+z
(global-set-key "\M-/" 'hippie-expand)
(global-set-key "\M-m" 'transpose-chars)
(global-set-key "\M-M" 'transpose-words) ;
(global-set-key "\M-0" 'pop-to-mark-command)



 ;; EXUBERANT ctags not normal ctags
(setq path-to-ctags "/usr/local/Cellar/universal-ctags/HEAD-f6234d0/bin/ctags") ;; <- your exuberant ctags path here
(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-format
   (s "%f -command %s/TAGS -R %s" path-to-ctags dir-name (directory-file-name dir-name))) ;
  )

;; 
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (package-initialize)
  ;; If there are no archived package contents, refresh them

  (when (not package-archive-contents) 
    (package-refresh-contents))
  ;; Installs packages
  ;;
  ;; myPackages contains a list of package names
  (defvar myPackages
    '(better-defaults                 ;; Set up some better Emacs defaults
      material-theme                  ;; Theme
      tide
      unfill
      typescript-mode
      dockerfile-mode
      racer
      ix
      logview
      yaml-mode
      flycheck-yamllint
      smart-mode-line
      org-jira
      ivy
      discover
      yafolding
      json-mode
      json-reformat
      ssh-agency
      ssh
      w3m
      elpy
      py-autopep8                     ;; Run autopep8 on save
      blacken                         ;; Black formatting on save
      org-journal
      web-mode
      flycheck
      magit
      writeroom-mode
      pastebin
      markdown-mode
      flycheck-package
      csv-mode
      company
      projectile
      smex
      wc-mode
      )
    )
  ;; Scans the list in myPackages
  ;; If the package listed is not already installed, install it
  (mapc #'(lambda (package)
            (unless (package-installed-p package)
              (package-install package)))
        myPackages)
  )


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(diff-hl projectile csv-mode flycheck-package markdown-mode pastebin writeroom-mode magit web-mode org-journal blacken py-autopep8 elpy w3m ssh ssh-agency exec-path-from-shell json-reformat json-mode yafolding discover ivy org-jira smart-mode-line flycheck-yamllint yaml-mode logview ix racer dockerfile-mode typescript-mode unfill tide material-theme better-defaults ergoemacs-mode))
 '(tramp-verbose 6))

(put 'narrow-to-region 'disabled nil)

(setq c-default-style "bsd")

(load-theme 'solarized-dark t)

;; =================================
;; python setup
;; =================================
(elpy-enable)

;; Enable Flycheck
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; Enable autopep8
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-mode)
;; go forward with M-( and backwards with M-*
(add-hook 'elpy-mode-hook (lambda () (define-key elpy-mode-map (kbd "M-(") 'elpy-goto-definition)))


;; Org-mode settings
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)

;; Use cperl-mode instead of the default perl-mode
(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm]\\|al\\)\\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))

;;menu of recent files m-xrecentf-open-files
;;(recentf-mode 1)
(global-font-lock-mode 1)

;; Save desktop each time you shut down
(desktop-save-mode)
(desktop-read)

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history        . 100)
                (grep-history             . 30)
                (compile-history          . 30)
                (minibuffer-history       . 50)
                (query-replace-history    . 60)
                (read-expression-history  . 60)
                (regexp-history           . 60)
                (regexp-search-ring       . 20)
                (search-ring              . 20)
                (shell-command-history    . 50)
                tags-file-name
                register-alist)))

(column-number-mode 1)

;; better regex builder
(setq reb-re-syntax 'string)

;; highlight paren
(load-library "paren")
(show-paren-mode 1)
;; highlight current line
(global-hl-line-mode 1)

;; Smart tabs or w/e for c, c++ cc modes
(setq-default indent-tabs-mode nil) 
(setq-default tab-width 2) ; or any other preferred value
(setq-default standard-indent 2)

;; Ctags
(global-set-key (kbd "M-(") 'find-tag)      ; search ctags
(global-set-key (kbd "M-)") 'pop-tag-mark)      ; return to search area


;; ido modo
(require 'ido)
(ido-mode 1)
(setq ido-enable-flex-matching t)

(setq temporary-file-directory "~/.autosaves/")
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq auto-save-interval 50)

;;(global-set-key
;; "\M-a"
(add-to-list 'load-path "~/.emacs.d/smex")
(require 'smex)
(smex-initialize)
(define-key ergoemacs-user-keymap (kbd "M-a") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(defun xsteve-ido-choose-from-recentf ()
  "Use ido to select a recently opened file from the `recentf-list'."
  (interactive)
  (let ((home (expand-file-name (getenv "HOME"))))
    (find-file
     (ido-completing-read "Recentf open: "
                          (mapcar (lambda (path)
                                    (replace-regexp-in-string home "~" path))
                                  recentf-list)
                          nil t))))

(global-set-key [(meta f11)] 'xsteve-ido-choose-from-recentf)

; add newline above line
(defun vi-open-line-above ()
  "Insert a newline above the current line and put point at beginning."
  (interactive)
  (unless (bolp)
    (beginning-of-line))
  (newline)
  (forward-line -1)
  (indent-according-to-mode))
(global-set-key (kbd "M-RET") 'vi-open-line-above) 
(global-set-key (kbd "C-j") 'comment-indent-new-line) 

;; stuff to get fancy flycheck working
;; use web-mode for .jsx files
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))

;; http://www.flycheck.org/manual/latest/index.html
(require 'flycheck)

;; turn on flychecking globally
;;(add-hook 'after-init-hook #'global-flycheck-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(javascript-jshint)))

;; use  js2 mode instead of javascript mode
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(setq-default js2-basic-offset 2)
(setq-default js-indent-level 2)



;; set typescript indent
(setq-default typescript-indent-level 2)



;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(json-jsonlist)))

;; https://github.com/purcell/exec-path-from-shell
;; only need exec-path-from-shell on OSX OR IF USING NVM
;; this hopefully sets up path and other vars better


(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x pgtk))
    (exec-path-from-shell-initialize)))

(defun m-eshell-hook ()
; define control p, control n and the up/down arrow in eshell
  (define-key eshell-mode-map (kbd "M-m") 'eshell-previous-matching-input-from-input)
  (define-key eshell-mode-map (kbd "M-w") 'eshell-next-matching-input-from-input)
 
  (define-key eshell-mode-map [up] 'previous-line)
  (define-key eshell-mode-map [down] 'next-line)
)

(add-hook 'eshell-mode-hook 'm-eshell-hook)

;; Window Switchings
(defun select-next-window ()
  "Switch to the next window" 
  (interactive)
  (select-window (next-window)))

(defun select-previous-window ()
  "Switch to the previous window" 
  (interactive)
  (select-window (previous-window)))

(global-set-key (kbd "M-<right>") 'select-next-window)
(global-set-key (kbd "M-<left>")  'select-previous-window)

;; easier smerge command
(setq smerge-command-prefix "\C-cv")


;; server mode
(server-start)

;; Kill the menu bar, toolbar
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

;; CYBERPUNK CURSOR
(defvar blink-cursor-colors (list  "#92c48f" "#6785c5" "#be369c" "#d9ca65")
  "On each blink the cursor will cycle to the next color in this list.")

(setq blink-cursor-count 0)
(defun blink-cursor-timer-function ()
  "Cyberpunk variant of timer `blink-cursor-timer'. OVERWRITES original version in `frame.el'.

This one changes the cursor color on each blink. Define colors in `blink-cursor-colors'."
  (when (not (internal-show-cursor-p))
    (when (>= blink-cursor-count (length blink-cursor-colors))
      (setq blink-cursor-count 0))
    (set-cursor-color (nth blink-cursor-count blink-cursor-colors))
    (setq blink-cursor-count (+ 1 blink-cursor-count))
    )
  (internal-show-cursor nil (not (internal-show-cursor-p)))
  )


(setq ring-bell-function 'ignore)

;; turn on longlines when you turn on text mode
(defun turn-on-visual-line () (visual-line-mode 1))
(add-hook 'text-mode-hook 'turn-on-visual-line)

;; turn on wc mode when you turn on text mode
(require 'wc-mode)
(defun turn-on-wc () (wc-mode 1))
(add-hook 'text-mode-hook 'turn-on-wc)




(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#042028" :foreground "#708183" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 95 :width normal :foundry "PfEd" :family "DejaVu Sans Mono")))))


;; =================================
;; C/C++ LSP Setup (clangd + eglot)
;; =================================

;; Start eglot automatically for C and C++
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)

;; You already have 'company' installed via myPackages.
;; Enable it for C/C++ so you get the nice visual dropdowns:
(add-hook 'c-mode-common-hook 'company-mode)
(setq company-minimum-prefix-length 1)
(setq company-idle-delay 0.1)

;; (Optional) Format code on save using your project's .clang-format rules

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode)
                 . ("clangd"
                    "--query-driver=**/*arm-none-eabi*"
                    "--header-insertion=iwyu"))))


;; Lsp / Code Navigation Shortcuts
(define-key ergoemacs-user-keymap (kbd "C-.") 'xref-find-definitions)
(define-key ergoemacs-user-keymap (kbd "C-,") 'xref-go-back)
(define-key ergoemacs-user-keymap (kbd "<f2>") 'eglot-rename)
(define-key ergoemacs-user-keymap (kbd "M-?") 'xref-find-references)


;; =================================
;; Build & Error Tracking
;; =================================
;; Set the default build command
(setq compile-command "ninja -C build/Debug")

;; Use the native project-wide compile command
(define-key ergoemacs-user-keymap (kbd "<f5>") 'project-compile)

;; Error jumping (these remain the same)
(define-key ergoemacs-user-keymap (kbd "<f6>") 'next-error)
(define-key ergoemacs-user-keymap (kbd "<S-f6>") 'previous-error)

;; =================================
;; Git Margin Indicators (VSCode style)
;; =================================
(use-package diff-hl
  :ensure t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode))
