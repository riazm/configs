 ;; EXUBERANT ctags not normal ctags
(setq path-to-ctags "/usr/local/Cellar/universal-ctags/HEAD-f6234d0/bin/ctags") ;; <- your exuberant ctags path here
(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   (format "%s -f %s/TAGS -R %s" path-to-ctags dir-name (directory-file-name dir-name)))
  )

(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
  (package-initialize)
  )


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-url-text-browser "emacs")
 '(canlock-password "41fca07147d8079925eb3f447acd09118c25942c")
 '(custom-safe-themes
   '("8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "117284df029007a8012cae1f01c3156d54a0de4b9f2f381feab47809b8a1caef" "e9460a84d876da407d9e6accf9ceba453e2f86f8b86076f37c08ad155de8223c" "12b6c73d2985afdc01619d8b527483cfcdaf01300b0d6a7ee821e8aa5d1944d8" "abba1c64e90bcfc6288c62bed95cc00dfa058cd9" default))
 '(electric-pair-mode t)
 '(flycheck-python-flake8-executable "python3")
 '(flycheck-python-pycompile-executable "python3")
 '(flycheck-python-pylint-executable "python3")
 '(global-company-mode t)
 '(global-flycheck-mode t)
 '(logview-additional-timestamp-formats
   '(("logcat datetime"
      (java-pattern . "dd-MM HH:mm:ss.SSS"))))
 '(package-selected-packages
   '(solarized-theme tide unfill typescript-mode dockerfile-mode racer flycheck-rust cargo rust-mode ix logview yaml-mode flycheck-yamllint color-theme-solarized smart-mode-line org-jira ivy discover yafolding json-mode json-reformat atom-dark-theme color-theme-modern confluence company-tern exec-path-from-shell tern js3-mode ssh-agency ssh w3m elpy org-journal web-mode js2-mode flycheck magit writeroom-mode pastebin markdown-mode flycheck-tcl flycheck-package ctags csv-mode company))
 '(tcl-auto-newline nil))

(put 'narrow-to-region 'disabled nil)

(setq c-default-style "bsd")

(load-theme 'solarized-dark t)

;;(setq sml/theme 'solarized-dark)
;;(sml/setup)

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
(setq desktop-save 'if-exists)
(desktop-save-mode 1)

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

;; ErgoEmacs
(setenv "ERGOEMACS_KEYBOARD_LAYOUT" "dv") ; US Dvorak layout

;; load ErgoEmacs keybinding
(load "~/.emacs.d/ergoemacs-keybindings-5.3.3/ergoemacs-mode")

;; turn on minor mode ergoemacs-mode
(ergoemacs-mode 1)

;; Keyboard Shortcuts
(global-set-key (kbd "C-z") 'suspend-frame) ; ctrl+z
(global-set-key (kbd "M-b") 'goto-line) ; gotoline
(define-key global-map "\M-b" 'goto-line)
(global-set-key "\M-/" 'hippie-expand)
(global-set-key "\M-m" 'transpose-chars)
(global-set-key "\M-M" 'transpose-words)
(global-set-key "\M-0" 'pop-to-mark-command)

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
(global-set-key (kbd "M-a") 'smex)
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
(add-hook 'after-init-hook #'global-flycheck-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(javascript-jshint)))

;; use  js2 mode instead of javascript mode
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(setq-default js2-basic-offset 2)
(setq-default js-indent-level 2)

;; pulled it from a stack overflow
(defun my/use-eslint-from-node-modules () 
  (let* ((root (locate-dominating-file 
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint
          (and root
               (expand-file-name "node_modules/.bin/eslint"
                                 root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

;; set typescript indent
(setq-default typescript-indent-level 2)

;; path to 'which tern'
 
(setenv "PATH" (concat (getenv "PATH") ":/Users/riaz.moola/.nvm/versions/node/v10.12.0/bin"))
    (setq exec-path (append exec-path '(":/Users/riaz.moola/.nvm/versions/node/v10.12.0/bin")))
;; path to 'tern.el'
(add-to-list 'load-path "/Users/riaz.moola/bin/tern/emacs/")
(autoload 'tern-mode "tern.el" nil t)
(add-hook 'js-mode-hook (lambda () (tern-mode t)))

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
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

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

;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(default ((t (:inherit nil :stipple nil :background "#042028" :foreground "#708183" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "unknown" :family "Ubuntu Mono"))))
;;  '(p4-diff-ins-face ((t (:foreground "yellow"))) t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
