(deftheme solarized-dark
  "Created 2011-08-17.")

(custom-theme-set-variables
 'solarized-dark
 )

(custom-theme-set-faces
 'solarized-dark
 '(cursor ((t (:foreground "#708183" :background "#042028" :inverse-video t))))
 '(fringe ((t (:foreground "#465a61" :background "#0a2832"))))
 '(header-line ((t (:foreground "#708183" :background "#e9e2cb"))))
 '(highlight ((t (:background "#0a2832"))))
 '(isearch ((t (:foreground "#a57705" :inverse-video t))))
 '(lazy-highlight ((t (:background "#e9e2cb" :foreground "#52676f"))))
 '(link ((t (:foreground "#5859b7" :underline t))))
 '(link-visited ((t (:foreground "#c61b6e" :underline t))))
 '(menu ((t (:foreground "#708183" :background "#0a2832"))))
 '(minibuffer-prompt ((t (:foreground "#2075c7"))))
 '(mode-line ((t (:foreground "#81908f" :background "#0a2832" :box (:line-width 1 :color "#81908f")))))
 '(mode-line-buffer-id ((t (:foreground "#81908f"))))
 '(mode-line-inactive ((t (:foreground "#708183" :background "#0a2832" :box (:line-width 1 :color "#0a2832")))))
 '(region ((t (:background "#0a2832"))))
 '(secondary-selection ((t (:background "#0a2832"))))
 '(trailing-whitespace ((t (:foreground "#c60007" :inverse-video t))))
 '(vertical-border ((t (:foreground "#708183"))))
 '(custom-button ((t (:background "#0a2832" :box (:line-width 2 :style released-button)))))
 '(custom-button-mouse ((t (:inherit custom-button :foreground "#81908f"))))
 '(custom-button-pressed ((t (:inherit custom-button-mouse :box (:line-width 2 :style pressed-button)))))
 '(custom-comment-tag ((t (:background "#0a2832"))))
 '(custom-documentation ((t (:inherit default))))
 '(custom-group-tag ((t (:foreground "#bd3612" :weight bold))))
 '(custom-link ((t (:foreground "#5859b7"))))
 '(custom-state ((t (:foreground "#728a05"))))
 '(custom-variable-tag ((t (:foreground "#bd3612" :weight bold))))
 '(font-lock-builtin-face ((t (:foreground "#728a05"))))
 '(font-lock-comment-face ((t (:foreground "#465a61" :slant italic))))
 '(font-lock-constant-face ((t (:foreground "#259185"))))
 '(font-lock-function-name-face ((t (:foreground "#2075c7"))))
 '(font-lock-keyword-face ((t (:foreground "#728a05"))))
 '(font-lock-string-face ((t (:foreground "#259185"))))
 '(font-lock-type-face ((t (:foreground "#a57705"))))
 '(font-lock-variable-name-face ((t (:foreground "#2075c7"))))
 '(font-lock-warning-face ((t (:foreground "#c60007" :weight bold))))
 '(font-lock-doc-face ((t (:foreground "#259185" :slant italic))))
 '(font-lock-comment-delimiter-face ((t (:foreground "#465a61" :weight bold))))
 '(font-lock-preprocessor-face ((t (:foreground "#bd3612"))))
 '(font-lock-negation-char-face ((t (:foreground "#c60007"))))
 '(font-lock-regexp-grouping-construct ((t (:foreground "#bd3612"))))
 '(font-lock-regexp-grouping-backslash ((t (:foreground "#a57705"))))
 '(widget-field ((t (:box (:line-width 1 :color "#52676f") :inherit default))))
 '(widget-single-line-field ((t (:inherit widget-field))))
 '(default ((t (:foreground "#708183" :background "#042028")))))

(provide-theme 'solarized-dark)
