;;; lui.el --- Linewise User Interface

;; Copyright (C) 2005 - 2012  Jorgen Schaefer

;; Version: 1.0
;; Author: Jorgen Schaefer <forcer@forcix.cx>
;; URL: https://github.com/jorgenschaefer/circe/wiki/Lui

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Lui is a library for other Emacs Lisp programs and not useful by
;; itself.

;; This major mode provides a user interface for applications. The
;; user interface is quite simple, consisting of an input line, a
;; prompt, and some output area, but Lui includes a lot of common
;; options, such as time stamps, filling, colorization, etc.

;; Application programs should create modes derived from lui-mode.

;; The application API consists of:

;; lui-mode
;; lui-set-prompt
;; lui-insert
;; lui-input-function
;; lui-completion-function
;; and the 'lui-fool and 'lui-do-not-track text properties

;;; Code:

(defvar lui-version "1.0 devel"
  "Lui version string.")

(require 'ring)
(require 'flyspell)
(require 'ispell)
(require 'button)
(require 'tracking)

(when (featurep 'xemacs)
  (require 'lui-xemacs))


;;;;;;;;;;;;;;;;;;;;;
;;; Customization ;;;
;;;;;;;;;;;;;;;;;;;;;

(defgroup lui nil
  "The Linewise User Interface."
  :prefix "lui-"
  :group 'applications)

(defcustom lui-scroll-behavior 'post-output
  "Set the behavior lui should exhibit for scrolling.

The following values are possible. If in doubt, use post-output.

nil
  Use default Emacs scrolling.

t, post-command
  Keep the input line at the end of the window if point is
  after the input mark.

post-output
  Keep the input line at the end of the window only after output.

post-scroll
  Keep the input line at the end of the window on every scroll
  event. Careful, this might interact badly with other functions
  on `window-scroll-functions'.


It would be entirely sensible for Emacs to provide a setting to
do this kind of scrolling by default in a buffer. It seems rather
intuitive and sensible. But as noted on emacs-devel:

  [T]hose who know the code know that it's going to be a pain to
  implement, especially if you want acceptable performance. IOW,
  patches welcome

The full discussion can be found here:

https://lists.gnu.org/archive/html/emacs-devel/2012-10/msg00652.html

These settings are all hacks that try to give the user the choice
between most correct behavior (post-scroll) and most compliant
behavior (post-output)."
  :type '(choice (const :tag "Post Command" t)
                 (const :tag "Post Output" post-output)
                 (const :tag "Post Scroll" post-scroll)
                 (const :tag "Use default scrolling" nil))
  :group 'lui)
(defvaralias 'lui-scroll-to-bottom-p 'lui-scroll-behavior)

(defcustom lui-flyspell-p nil
  "Non-nil if Lui should spell-check your input.
See the function `flyspell-mode' for more information."
  :type 'boolean
  :group 'lui)

(defcustom lui-flyspell-alist nil
  "Alist of buffer dictionaries.

This is a list of mappings from buffers to dictionaries to use
for the function `flyspell-mode'. The appropriate dictionary is
automatically used when Lui is activated in a buffer with a
matching buffer name.

The entries are of the form (REGEXP DICTIONARY), where REGEXP
must match a buffer name, and DICTIONARY specifies an existing
dictionary for the function `flyspell-mode'. See
`ispell-local-dictionary-alist' and `ispell-dictionary-alist' for
a valid list of dictionaries."
  :type 'string
  :group 'lui)

(defcustom lui-highlight-keywords nil
  "A list of keywords to highlight.
This specifies a list of keywords that Lui should highlight. Each
entry is of one of the following forms (similar to
`font-lock-keywords'):

  REGEXP
    Highlight every match in `lui-highlight-face'
  (REGEXP SUBMATCH)
    Highlight the SUBMATCH (a number) in REGEXP in
    `lui-highlight-face'
  (REGEXP FACE)
    Highlight everything matching REGEXP in FACE (a symbol)
  (REGEXP SUBMATCH FACE)
    Highlight the SUBMATCH in REGEXP in FACE

In all of these cases, the FACE can also be a property list which
is then associated with the match."
  :type '(repeat (choice
                  (string :tag "Regular Expression")
                  (list :tag "Submatch"
                        (string :tag "Regular Expression")
                        (integer :tag "Submatch"))
                  (list :tag "Regular Expression in Specific Face"
                        (string :tag "Regular Expression")
                        (face :tag "Face"))
                  (list :tag "Submatch in Specific Face"
                        (string :tag "Regular Expression")
                        (integer :tag "Submatch")
                        (face :tag "Face"))))
  :group 'lui)

(defcustom lui-buttons-list
  `((,(rx (or (and (or "http"
                       "https"
                       "ftp"
                       "irc")
                   "://"
                   (* (not (any "()<> \n")))
                   (any "a-zA-Z0-9/"))
              (and "www."
                   (* (any "a-zA-Z0-9./?~-"))
                   (any "a-zA-Z0-9/"))))
     0 browse-url 0)
    ("`\\([A-Za-z0-9+=*/-]+\\)'" 1 lui-button-elisp-symbol 1)
    ("RFC ?\\([0-9]+\\)" 0 lui-button-rfc 1)
    ("SRFI[- ]?\\([0-9]+\\)" 0 lui-button-srfi 1))
  "The list of buttons to buttonize.
This consists of lists of four elements each:

  (REGEXP SUBMATCH FUNCTION ARG-MATCH)

Whenever REGEXP is found, SUBMATCH is marked as a button. When
that button is activated, FUNCTION is called with the match
ARG-MATCH as its sole argument."
  :type '(repeat (list (regexp :tag "Regular expression")
                       (integer :tag "Submatch to buttonize")
                       (function :tag "Function to call for this button")
                       (integer :tag "Submatch to pass as an argument")))
  :group 'lui)

(defcustom lui-fill-type "    "
  "How Lui should fill its output.
This can be one of the following values:

  A string
      This is used as the fill prefix
  'variable
      The first sequence of non-whitespace characters in the
      output is used as an alignment, and the rest is filled with
      spaces.
  A number
      The first sequence of non-whitespace characters is
      right-aligned at this column, and the rest is filled to
      this column.
  nil
      Turn filling off."
  :type '(choice (string :tag "Fill Prefix")
                 (const :tag "Variable Fill Prefix" variable)
                 (integer :tag "Fill Column")
                 (const :tag "No filling" nil))
  :group 'lui)

(defcustom lui-fill-column 70
  "The column at which Lui should break output.
See `fill-column'."
  :type 'integer
  :group 'lui)

(defcustom lui-fill-remove-face-from-newline t
  "Non-nil when filling should remove faces from newlines.
Faces on a newline extend to the end of the displayed line, which
is often not was is wanted."
  :type 'boolean
  :group 'lui)

(defcustom lui-time-stamp-format "[%H:%M]"
  "The format of time stamps.
See `format-time-string' for a full description of available
formatting directives."
  :type 'string
  :group 'lui)

(defcustom lui-time-stamp-position 'right
  "Where Lui should put time-stamps.
This can be one of the following values:

  A number
      At this column of the first line of output
  'right
      At a column just right to `lui-fill-column'
  'left
      At the left side of the output. The output is thereby moved
      to the right.
  'right-margin
      In the right margin.  You will need to set `right-margin-width'
      in all circe buffers.
  'left-margin
      In the left margin.  You will need to set `left-margin-width'
      in all circe buffers.
  nil
      Do not add any time stamp."
  :type '(choice (const :tag "Right" right)
                 (integer :tag "Column")
                 (const :tag "Left" left)
                 (const :tag "Right Margin" right-margin)
                 (const :tag "Left Margin" left-margin)
                 (const :tag "None" nil))
  :group 'lui)

(defcustom lui-time-stamp-only-when-changed-p t
  "Non-nil if Lui should only add a time stamp when the time changes.
If `lui-time-stamp-position' is 'left, this will still add the
necessary whitespace."
  :type 'boolean
  :group 'lui)

(defcustom lui-read-only-output-p t
  "Non-nil if Lui should make the output read-only.
Switching this off makes copying (by killing) easier for some."
  :type 'boolean
  :group 'lui)

(defcustom lui-max-buffer-size nil
  "Non-nil if Lui should truncate the buffer if it grows too much.
If the buffer size (in characters) exceeds this number, it is
truncated at the top."
  :type '(choice (const :tag "Never Truncate" nil)
                 (integer :tag "Maximum Buffer Size"))
  :group 'lui)

(defcustom lui-input-ring-size 32
  "The size of the input history of Lui.
This is the size of the input history used by
\\[lui-previous-input] and \\[lui-next-input]."
  :type 'integer
  :group 'lui)

(defcustom lui-mode-hook nil
  "The hook run when Lui is started."
  :type 'hook
  :group 'lui)

(defcustom lui-pre-input-hook nil
  "A hook run before Lui interprets the user input.
It is called with the buffer narrowed to the input line.
Functions can modify the input if they really want to, but the
user won't see the modifications, so that's a bad idea."
  :type 'hook
  :group 'lui)

(defcustom lui-pre-output-hook nil
  "The hook run before output is formatted."
  :type 'hook
  :group 'lui)

(defcustom lui-post-output-hook nil
  "The hook run after output has been formatted."
  :type 'hook
  :group 'lui)

(defface lui-time-stamp-face
  '((t (:foreground "SlateBlue" :weight bold)))
  "Lui mode face used for time stamps."
  :group 'lui)

(defface lui-highlight-face
  ;; Taken from `font-lock-keyword-face'
  '((((class grayscale) (background light)) (:foreground "LightGray" :weight bold))
    (((class grayscale) (background dark)) (:foreground "DimGray" :weight bold))
    (((class color) (background light)) (:foreground "Purple"))
    (((class color) (background dark)) (:foreground "Cyan1"))
    (t (:weight bold)))
  "Lui mode face used for highlighting."
  :group 'lui)

(defface lui-button-face
  '((((class color) (background light)) (:foreground "Purple" :underline t))
    (((class color) (background dark)) (:foreground "Cyan" :underline t))
    (t (:underline t)))
  "Default face used for LUI buttons."
  :group 'lui)


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Client interface ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

(defvar lui-input-function nil
  "The function to be called for Lui input.
This function is called with a single argument, the input
string.")
(make-variable-buffer-local 'lui-input-function)

(defvar lui-completion-function 'completion-at-point
  "A function called to actually do completion.")


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Private variables ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar lui-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") 'lui-send-input)
    (define-key map (kbd "TAB") 'lui-next-button-or-complete)
    (define-key map (kbd "<backtab>") 'lui-previous-button)
    (define-key map (kbd "<S-tab>") 'lui-previous-button)
    (define-key map (kbd "M-p") 'lui-previous-input)
    (define-key map (kbd "M-n") 'lui-next-input)
    (define-key map (kbd "C-c C-u") 'lui-kill-to-beginning-of-line)
    (define-key map (kbd "C-c C-i") 'lui-fool-toggle-display)
    map)
  "The key map used in Lui modes.")

(defvar lui-input-marker nil
  "The marker where input should be inserted.")
(make-variable-buffer-local 'lui-input-marker)

(defvar lui-output-marker nil
  "The marker where output should be inserted.
Use `lui-insert' instead of accessing this marker directly.")
(make-variable-buffer-local 'lui-output-marker)

(defvar lui-input-ring nil
  "The input history ring.")
(make-variable-buffer-local 'lui-input-ring)

(defvar lui-input-ring-index nil
  "The index to the current item in the input ring.")
(make-variable-buffer-local 'lui-input-ring-index)


;;;;;;;;;;;;;;
;;; Macros ;;;
;;;;;;;;;;;;;;

(defmacro lui-save-undo-list (&rest body)
  "Run BODY without modifying the undo list."
  (let ((old-marker-sym (make-symbol "old-marker")))
    `(let ((,old-marker-sym (marker-position lui-input-marker))
           (val nil))
       ;; Don't modify the undo list. The undo list is for the user's
       ;; input only.
       (let ((buffer-undo-list t))
         (setq val (progn ,@body)))
       (when (consp buffer-undo-list)
         ;; Not t :-)
         (setq buffer-undo-list (lui-adjust-undo-list buffer-undo-list
                                                      ,old-marker-sym
                                                      (- lui-input-marker
                                                         ,old-marker-sym))))
       val)))


;;;;;;;;;;;;;;;;;;
;;; Major Mode ;;;
;;;;;;;;;;;;;;;;;;

(defun lui-mode ()
  "The Linewise User Interface mode.
This can be used as a user interface for various applications.
Those should define derived modes of this, so this function
should never be called directly.

It can be customized for an application by specifying a
`lui-input-function'."
  (kill-all-local-variables)
  (setq major-mode 'lui-mode
        mode-name "LUI")
  (use-local-map lui-mode-map)
  ;; Buffer-local variables
  (setq lui-input-marker (make-marker)
        lui-output-marker (make-marker)
        lui-input-ring (make-ring lui-input-ring-size)
        lui-input-ring-index nil
        flyspell-generic-check-word-p 'lui-flyspell-check-word-p)
  (set-marker lui-input-marker (point-max))
  (set-marker lui-output-marker (point-max))
  (add-hook 'window-scroll-functions 'lui-scroll-window nil t)
  (add-hook 'post-command-hook 'lui-scroll-post-command)
  (when (fboundp 'make-local-hook)
    ;; needed for xemacs, as it does not treat the LOCAL argument to
    ;; `add-hook' the same as GNU Emacs. It's obsolete in GNU Emacs
    ;; since 21.1.
    (make-local-hook 'change-major-mode-hook))
  (add-hook 'change-major-mode-hook
            'lui-change-major-mode
            nil t)
  (lui-time-stamp-enable-filtering)
  (tracking-mode 1)
  (when lui-flyspell-p
    (require 'flyspell)
    (lui-flyspell-change-dictionary))
  (run-hooks 'lui-mode-hook))

(defun lui-change-major-mode ()
  "Assure that the user really wants to change the major mode.
This is a good value for a buffer-local `change-major-mode-hook'."
  (when (not (y-or-n-p "Really change major mode in a Lui buffer? "))
    (error "User disallowed mode change")))

(defun lui-scroll-window (window display-start)
  "Scroll the input line to the bottom of the WINDOW.

DISPLAY-START is passed by the hook `window-scroll-functions' and
is ignored.

See `lui-scroll-behavior' for how to customize this."
  (when (and (eq lui-scroll-behavior 'post-scroll)
             window
             (window-live-p window))
    (with-selected-window window
      (when (or (>= (point) lui-input-marker)
                (equal (point-max)
                       (window-end nil t)))
        (let ((resize-mini-windows nil))
          (save-excursion
            (goto-char (point-max))
            (recenter -1)))))))

(defun lui-scroll-post-command ()
  "Scroll the input line to the bottom of the window.

This is called from `post-command-hook'.

See `lui-scroll-behavior' for how to customize this."
  (when (and lui-input-marker
             (or (eq lui-scroll-behavior t)
                 (eq lui-scroll-behavior 'post-command)))
    ;; Code from ERC's erc-goodies.el. I think this was originally
    ;; mine anyhow, not sure though.
    (save-restriction
      (when (>= (point) lui-input-marker)
        (save-excursion
          (goto-char (point-max))
          (recenter -1))))))

(defun lui-scroll-post-output ()
  "Scroll the input line to the bottom of the window.

This is called when lui output happens.

See `lui-scroll-behavior' for how to customize this."
  (when (memq lui-scroll-behavior '(post-output
                                    post-command))
    (let ((resize-mini-windows nil))
      (dolist (window (get-buffer-window-list (current-buffer) nil t))
        (when (or (>= (point) lui-input-marker)
                  (equal (point-max)
                         (window-end window)))
          (with-selected-window window
            (save-excursion
              (goto-char (point-max))
              (recenter -1))))))))


;;;;;;;;;;;;;
;;; Input ;;;
;;;;;;;;;;;;;

(defun lui-send-input ()
  "Send the current input to the Lui application.
If point is not in the input area, self-insert."
  (interactive)
  (if (< (point) lui-input-marker)
      (self-insert-command 1)
    (save-restriction
      (narrow-to-region lui-input-marker (point-max))
      (run-hooks 'lui-pre-input-hook))
    (let ((input (buffer-substring lui-input-marker (point-max))))
      (delete-region lui-input-marker (point-max))
      (ring-insert lui-input-ring input)
      (setq lui-input-ring-index nil)
      (if lui-input-function
          (funcall lui-input-function input)
        (error "No input function specified")))
    ;; Clean the undo list. The input is gone, nothing to be undone
    ;; here.
    ;     (setq buffer-undo-list nil)
    ))


;;;;;;;;;;;;;;;
;;; Buttons ;;;
;;;;;;;;;;;;;;;

(define-button-type 'lui-button
  'supertype 'button
  'face 'lui-button-face)

(defun lui-buttonize ()
  "Buttonize the current message.
This uses `lui-buttons-list'."
  (dolist (entry lui-buttons-list)
    (let ((regex (nth 0 entry))
          (submatch (nth 1 entry))
          (function (nth 2 entry))
          (arg-match (nth 3 entry)))
      (goto-char (point-min))
      (while (re-search-forward regex nil t)
        (make-button (match-beginning submatch)
                     (match-end submatch)
                     'type 'lui-button
                     'action 'lui-button-activate
                     'lui-button-function function
                     'lui-button-argument
                     (match-string-no-properties arg-match))))))

(defun lui-button-activate (button)
  "Activate BUTTON.
This calls the function stored in the `lui-button-function'
property with the argument stored in `lui-button-argument'."
  (let ((function (button-get button 'lui-button-function))
        (argument (button-get button 'lui-button-argument)))
    (if (and (functionp function)
             argument)
        (funcall function argument)
      (error "Not a LUI button"))))

(defun lui-next-button-or-complete ()
  "Go to the next button, or complete at point.
When point is in the input line, call `lui-completion-function'.
Otherwise, we move to the next button."
  (interactive)
  (if (>= (point)
          lui-input-marker)
      (funcall lui-completion-function)
    (forward-button 1)))

(defun lui-previous-button ()
  "Go to the previous button."
  (interactive)
  (backward-button 1))

(defun lui-button-elisp-symbol (name)
  "Show the documentation for the symbol named NAME."
  (let ((sym (intern-soft name)))
    (cond
     ((not sym)
      (message "No such symbol %s" name)
      (ding))
     (t
      (help-xref-interned sym)))))

(defun lui-button-rfc (number)
  "Browse the RFC NUMBER."
  (browse-url (format "http://www.ietf.org/rfc/rfc%s.txt"
                      number)))

(defun lui-button-srfi (number)
  "Browse the SRFI NUMBER."
  (browse-url (format "http://srfi.schemers.org/srfi-%s/srfi-%s.html"
                      number number)))


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Input Line Killing ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun lui-kill-to-beginning-of-line ()
  "Kill the input from point to the beginning of the input."
  (interactive)
  (let* ((beg (point-at-bol))
         (end (point))
         (str (buffer-substring beg end)))
    (delete-region beg end)
    (kill-new str)))


;;;;;;;;;;;;;;;;;;;;;
;;; Input History ;;;
;;;;;;;;;;;;;;;;;;;;;

;; FIXME!
;; These need some better algorithm. They clobber input when it is not
;; in the ring!
(defun lui-previous-input ()
  "Cycle through the input history to the last input."
  (interactive)
  (when (> (ring-length lui-input-ring) 0)
    (if (and lui-input-ring-index
             (= (1- (ring-length lui-input-ring))
                lui-input-ring-index))
        ;; last item - insert a single empty line
        (progn
          (lui-replace-input "")
          (setq lui-input-ring-index nil))
      ;; If any input is left, store it in the input ring
      (when (and (null lui-input-ring-index)
                 (> (point-max) lui-input-marker))
        (ring-insert lui-input-ring
                     (buffer-substring lui-input-marker (point-max)))
        (setq lui-input-ring-index 0))
      ;; Increment the index
      (setq lui-input-ring-index
            (if lui-input-ring-index
                (ring-plus1 lui-input-ring-index (ring-length lui-input-ring))
              0))
      ;; And insert the last input
      (lui-replace-input (ring-ref lui-input-ring lui-input-ring-index))
      (goto-char (point-max)))))

(defun lui-next-input ()
  "Cycle through the input history to the next input."
  (interactive)
  (when (> (ring-length lui-input-ring) 0)
    (if (and lui-input-ring-index
             (= 0 lui-input-ring-index))
        ;; first item - insert a single empty line
        (progn
          (lui-replace-input "")
          (setq lui-input-ring-index nil))
      ;; If any input is left, store it in the input ring
      (when (and (null lui-input-ring-index)
                 (> (point-max) lui-input-marker))
        (ring-insert lui-input-ring
                     (buffer-substring lui-input-marker (point-max)))
        (setq lui-input-ring-index 0))
      ;; Decrement the index
      (setq lui-input-ring-index (ring-minus1 (or lui-input-ring-index 0)
                                              (ring-length lui-input-ring)))
      ;; And insert the next input
      (lui-replace-input (ring-ref lui-input-ring lui-input-ring-index))
      (goto-char (point-max)))))

(defun lui-replace-input (str)
  "Replace input with STR."
  (save-excursion
    (goto-char lui-input-marker)
    (delete-region lui-input-marker (point-max))
    (insert str)))


;;;;;;;;;;;;;
;;; Fools ;;;
;;;;;;;;;;;;;

(defun lui-fools ()
  "Propertize the current narrowing according to foolhardiness.
That is, if any part of it has the text property 'lui-fool set,
make the whole thing invisible."
  (when (text-property-any (point-min)
                           (point-max)
                           'lui-fool t)
    (add-text-properties (point-min)
                         (point-max)
                         '(invisible lui-fool))))

(defun lui-fools-hidden-p ()
  "Return whether fools are currently hidden."
  (if (or (eq t buffer-invisibility-spec)
          (memq 'lui-fool buffer-invisibility-spec))
      t
    nil))

(defun lui-fool-toggle-display ()
  "Display what fools have said."
  (interactive)
  (when (eq buffer-invisibility-spec t)
    (add-to-invisibility-spec 'lui-fool))
  (cond
   ((lui-fools-hidden-p)
    (message "Now showing the gibberish of fools")
    (remove-from-invisibility-spec 'lui-fool))
   (t
    (message "Now hiding fools again *phew*")
    (add-to-invisibility-spec 'lui-fool)))
  ;; For some reason, after this, the display does not always update
  ;; (issue #31). Force an update just in case.
  (redisplay))


;;;;;;;;;;;;;;;;
;;; Flyspell ;;;
;;;;;;;;;;;;;;;;

(defun lui-flyspell-change-dictionary (&optional dictionary)
  "*Change flyspell to DICTIONARY.
If DICTIONARY is nil, set a default dictionary according to
`lui-flyspell-alist'.
If it is \"\", disable flyspell."
  (interactive (list (completing-read
                      "Use new dictionary (RET for none, SPC to complete): "
                      (and (fboundp 'ispell-valid-dictionary-list)
                           (mapcar 'list (ispell-valid-dictionary-list)))
                      nil t)))
  (cond
   ((not (fboundp 'flyspell-mode))
    (error "Flyspell mode is not loaded"))
   ((string= dictionary "")
    (flyspell-mode 0))
   (t
    (let ((dictionary (or dictionary
                          (lui-find-dictionary (buffer-name)))))
      (when dictionary
        (when (or (not (boundp 'flyspell-mode))
                  (not flyspell-mode))
          (flyspell-mode 1))
        (ispell-change-dictionary dictionary))))))


(defun lui-find-dictionary (buffer-name)
  "Return a dictionary appropriate for BUFFER-NAME."
  (let ((lis lui-flyspell-alist)
        (result nil))
    (while lis
      (if (string-match (caar lis) buffer-name)
          (setq result (cadr (car lis))
                lis nil)
         (setq lis (cdr lis))))
    result))

(defun lui-flyspell-check-word-p ()
  "Return non-nil when flyspell should verify at this position.
This is the value of Lui for `flyspell-generic-check-word-p'."
  (>= (point)
      lui-input-marker))


;;;;;;;;;;;;;;
;;; Output ;;;
;;;;;;;;;;;;;;

(defun lui-insert (str &optional not-tracked-p)
  "Insert STR into the current Lui buffer.

If NOT-TRACKED-P is given, this insertion won't trigger tracking
of the buffer."
  (lui-save-undo-list
   (save-excursion
     (save-restriction
       (let ((inhibit-read-only t)
             (inhibit-point-motion-hooks t))
         (widen)
         (goto-char lui-output-marker)
         (let ((beg (point))
               (end nil))
           (insert str "\n")
           (setq end (point))
           (set-marker lui-output-marker (point))
           (narrow-to-region beg end))
         (goto-char (point-min))
         (add-text-properties (point-min)
                              (point-max)
                              `(lui-raw-text ,str))
         (run-hooks 'lui-pre-output-hook)
         (lui-highlight-keywords)
         (lui-buttonize)
         (lui-fill)
         (lui-time-stamp)
         (goto-char (point-min))
         (run-hooks 'lui-post-output-hook)
         (lui-fools)
         (goto-char (point-min))
         (let ((faces (lui-faces-in-region (point-min)
                                           (point-max)))
               (foolish (text-property-any (point-min)
                                           (point-max)
                                           'lui-fool t))
               (not-tracked-p
                (or not-tracked-p
                    (text-property-any (point-min)
                                       (point-max)
                                       'lui-do-not-track t))))
           (widen)
           (lui-truncate)
           (lui-read-only)
           (when (and (not not-tracked-p)
                      (not foolish))
             (tracking-add-buffer (current-buffer)
                                  faces)))
         (lui-scroll-post-output))))))

(defun lui-adjust-undo-list (list old-begin shift)
  "Adjust undo positions in list.
LIST is in the format of `buffer-undo-list'.
Only positions after OLD-BEGIN are affected.
The positions are adjusted by SHIFT positions."
  ;; This is necessary because the undo-list keeps exact buffer
  ;; positions.
  ;; Thanks to ERC for the idea of the code.
  ;; ERC's code doesn't take care of an OLD-BEGIN value, which is
  ;; necessary if you allow modification of the buffer.
  (let* ((adjust-position (lambda (pos)
                            (if (and (numberp pos)
                                     ;; After the boundary: Adjust
                                     (>= (abs pos)
                                         old-begin))
                                (* (if (< pos 0)
                                       -1
                                     1)
                                   (+ (abs pos)
                                      shift))
                              pos)))
         (adjust (lambda (entry)
                   (cond
                    ;; POSITION
                    ((numberp entry)
                     (funcall adjust-position entry))
                    ((not (consp entry))
                     entry)
                    ;; (BEG . END)
                    ((numberp (car entry))
                     (cons (funcall adjust-position (car entry))
                           (funcall adjust-position (cdr entry))))
                    ;; (TEXT . POSITION)
                    ((stringp (car entry))
                     (cons (car entry)
                           (funcall adjust-position (cdr entry))))
                    ;; (nil PROPERTY VALUE BEG . END)
                    ((not (car entry))
                     `(nil ,(nth 1 entry)
                           ,(nth 2 entry)
                           ,(funcall adjust-position (nth 3 entry))
                           .
                           ,(funcall adjust-position (nthcdr 4 entry))))
                    ;; (apply DELTA BEG END FUN-NAME . ARGS)
                    ((and (eq 'apply (car entry))
                          (numberp (cadr entry)))
                     `(apply ,(nth 1 entry)
                             ,(funcall adjust-position (nth 2 entry))
                             ,(funcall adjust-position (nth 3 entry))
                             ,(nth 4 entry)
                             .
                             ,(nthcdr 5 entry)))
                    ;; XEmacs: (<extent> start end)
                    ((and (fboundp 'extentp)
                          (extentp (car entry)))
                     (list (nth 0 entry)
                           (funcall adjust-position (nth 1 entry))
                           (funcall adjust-position (nth 2 entry))))
                    (t
                     entry)))))
    (mapcar adjust list)))

(defvar lui-prompt-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<end>") 'lui-prompt-end-of-line)
    (define-key map (kbd "C-e") 'lui-prompt-end-of-line)
    map)
  "Keymap for Lui prompts.
Since \\[end-of-line] can't move out of fields, this DTRT for an
unexpecting user.")

(defun lui-set-prompt (prompt)
  "Set PROMPT as the current Lui prompt."
  (let ((inhibit-read-only t))
    (lui-save-undo-list
     (save-excursion
       (goto-char lui-output-marker)
       (insert prompt)
       (if (> lui-input-marker (point))
           (delete-region (point) lui-input-marker)
         (set-marker lui-input-marker (point)))
       (add-text-properties lui-output-marker lui-input-marker
                            `(read-only t
                                        rear-nonsticky t
                                        field lui-prompt
                                        keymap ,lui-prompt-map
                                        front-sticky t
                                        ;; XEmacs stuff.
                                        start-open t
                                        end-open t
                                        ))))))

(defun lui-prompt-end-of-line (&optional N)
  "Move past the prompt, and then to the end of the line.
This uses `end-of-line'.

The argument N is ignored."
  (interactive "p")
  (goto-char lui-input-marker)
  (call-interactively 'end-of-line))

(defun lui-faces-in-region (beg end)
  "Return a face that describes the region between BEG and END."
  (goto-char beg)
  (let ((faces nil))
    (while (not (= (point) end))
      (let ((face (get-text-property (point) 'face)))
        (dolist (face (if (consp face)
                          face
                        (list face)))
          (when (and face
                     (facep face)
                     (face-differs-from-default-p face))
            (add-to-list 'faces face)))
        (goto-char (next-single-property-change (point) 'face
                                                nil end))))
    faces))



;;;;;;;;;;;;;;;;;;;;
;;; Highlighting ;;;
;;;;;;;;;;;;;;;;;;;;

(defun lui-highlight-keywords ()
  "Highlight the entries in the variable `lui-highlight-keywords'.

This is called automatically when new text is inserted."
  (let ((regex (lambda (entry)
                 (if (stringp entry)
                     entry
                   (car entry))))
        (submatch (lambda (entry)
                    (if (and (consp entry)
                             (numberp (cadr entry)))
                        (cadr entry)
                      0)))
        (properties (lambda (entry)
                      (let ((face (cond
                                   ;; REGEXP
                                   ((stringp entry)
                                    'lui-highlight-face)
                                   ;; (REGEXP SUBMATCH)
                                   ((and (numberp (cadr entry))
                                         (null (cddr entry)))
                                    'lui-highlight-face)
                                   ;; (REGEXP FACE)
                                   ((null (cddr entry))
                                    (cadr entry))
                                   ;; (REGEXP SUBMATCH FACE)
                                   (t
                                    (nth 2 entry)))))
                        (if (facep face)
                            `(face ,face)
                          face)))))
    (dolist (entry lui-highlight-keywords)
      (goto-char (point-min))
      (while (re-search-forward (funcall regex entry) nil t)
        (let* ((exp (funcall submatch entry))
               (beg (match-beginning exp))
               (end (match-end exp)))
          (when (not (text-property-any beg end 'lui-highlight-fontified-p t))
            (add-text-properties beg end
                                 (append (funcall properties entry)
                                         '(lui-highlight-fontified-p t)))))))))


;;;;;;;;;;;;;;;
;;; Filling ;;;
;;;;;;;;;;;;;;;

(defun lui-fill ()
  "Fill the text in the buffer.
This is called automatically when new text is inserted. See
`lui-fill-type' and `lui-fill-column' on how to customize this
function."
  (cond
   ((stringp lui-fill-type)
    (let ((fill-prefix lui-fill-type)
          (fill-column (or lui-fill-column
                           fill-column)))
      (fill-region (point-min) (point-max)
                   nil t)))
   ((eq lui-fill-type 'variable)
    (let ((fill-prefix (save-excursion
                         (goto-char (point-min))
                         (let ((beg (point)))
                           (re-search-forward "\\s-" nil t)
                           (make-string (- (point) beg) ? ))))
          (fill-column (or lui-fill-column
                           fill-column)))
      (fill-region (point-min) (point-max)
                   nil t)))
   ((numberp lui-fill-type)
    (let ((right-end (save-excursion
                       (goto-char (point-min))
                       (let ((beg (point)))
                         (re-search-forward "\\s-" nil t)
                         (- (point)
                            (point-at-bol))))))
      (goto-char (point-min))
      (when (< right-end lui-fill-type)
        (insert (make-string (- lui-fill-type
                                right-end)
                             ? )))
      (let ((fill-prefix (make-string lui-fill-type ? ))
            (fill-column (or lui-fill-column
                             fill-column)))
        (fill-region (point-min) (point-max)
                     nil t)))))
  (when lui-fill-remove-face-from-newline
    (goto-char (point-min))
    (while (re-search-forward "\n" nil t)
      (put-text-property (match-beginning 0)
                         (match-end 0)
                         'face
                         nil))))


;;;;;;;;;;;;;;;;;;;
;;; Time Stamps ;;;
;;;;;;;;;;;;;;;;;;;

(defvar lui-time-stamp-last nil
  "The last time stamp.")
(make-variable-buffer-local 'lui-time-stamp-last)

(defun lui-time-stamp ()
  "Add a time stamp to the current buffer."
  (let ((ts (format-time-string lui-time-stamp-format)))
    (cond
     ;; Time stamps right
     ((or (numberp lui-time-stamp-position)
          (eq lui-time-stamp-position 'right))
      (when (or (not lui-time-stamp-only-when-changed-p)
                (not lui-time-stamp-last)
                (not (string= ts lui-time-stamp-last)))
        (goto-char (point-min))
        (goto-char (point-at-eol))
        (let* ((curcol (current-column))
               (col (if (numberp lui-time-stamp-position)
                        lui-time-stamp-position
                      (+ 2 (or lui-fill-column
                               fill-column
                               (point)))))
               (indent (if (> col curcol)
                           (- col curcol)
                         1))
               (ts-string (propertize
                           (concat (make-string indent ?\s)
                                   (propertize
                                    ts
                                    'face 'lui-time-stamp-face))
                           'lui-time-stamp t))
               (start (point)))
          (insert ts-string)
          (add-text-properties start (1+ (point)) '(intangible t)))))
     ;; Time stamps left
     ((eq lui-time-stamp-position 'left)
      (let ((indent-string (propertize (make-string (length ts) ?\s)
                                       'lui-time-stamp t)))
        (goto-char (point-min))
        (cond
         ;; Time stamp
         ((or (not lui-time-stamp-only-when-changed-p)
              (not lui-time-stamp-last)
              (not (string= ts lui-time-stamp-last)))
          (insert (propertize ts
                              'face 'lui-time-stamp-face
                              'lui-time-stamp t)))
         ;; Just indentation
         (t
          (insert indent-string)))
        (forward-line 1)
        (while (< (point) (point-max))
          (insert indent-string)
          (forward-line 1))))
     ;; Time stamps in margin
     ((or (eq lui-time-stamp-position 'right-margin)
          (eq lui-time-stamp-position 'left-margin))
      (when (or (not lui-time-stamp-only-when-changed-p)
                (not lui-time-stamp-last)
                (not (string= ts lui-time-stamp-last)))
        (goto-char (point-min))
        (goto-char (point-at-eol))
        (let* ((ts (propertize ts 'face 'lui-time-stamp-face))
               (ts-margin (propertize
                           " "
                           'display `((margin ,lui-time-stamp-position)
                                      ,ts)
                           'lui-time-stamp t)))
          (insert ts-margin)))))
    (setq lui-time-stamp-last ts)))

(defun lui-time-stamp-enable-filtering ()
  "Enable filtering of timestamps from copied text."
  (if (boundp 'filter-buffer-substring-functions)
      (set (make-local-variable 'filter-buffer-substring-functions)
           '(lui-filter-buffer-time-stamps))
    ;; Emacs 23
    (set (make-local-variable 'buffer-substring-filters)
         '(lui-time-stamp-buffer-substring))))

(defun lui-filter-buffer-time-stamps (fun beg end delete)
  "Filter text from copied strings.

This is meant for the variable `filter-buffer-substring-functions',
which see for an explanation of the argument FUN, BEG, END and
DELETE."
  (let ((string (funcall fun beg end delete))
        (inhibit-point-motion-hooks t)
        (inhibit-read-only t))
    (with-temp-buffer
      (insert string)
      (let ((start (text-property-any (point-min)
                                      (point-max)
                                      'lui-time-stamp t)))
        (while start
          (let ((end (next-single-property-change start 'lui-time-stamp
                                                  nil (point-max))))
            (delete-region start end)
            (setq start (text-property-any (point-min) (point-max)
                                           'lui-time-stamp t))))
        (buffer-string)))))

(defun lui-time-stamp-buffer-substring (buffer-string)
  "Filter text from copied strings.

This is meant for the variable `buffer-substring-filters',
which see for an explanation of the argument BUFFER-STRING."
  (lui-filter-buffer-time-stamps (lambda (beg end delete)
                                  buffer-string)
                                nil nil nil))


;;;;;;;;;;;;;;;;;;
;;; Truncating ;;;
;;;;;;;;;;;;;;;;;;

(defun lui-truncate ()
  "Truncate the current buffer if it exceeds `lui-max-buffer-size'."
  (when (and lui-max-buffer-size
             (> (point-max)
                lui-max-buffer-size))
    (goto-char (- (point-max)
                  lui-max-buffer-size))
    (forward-line 0)
    (let ((inhibit-read-only t))
      (delete-region (point-min) (point)))))


;;;;;;;;;;;;;;;;;
;;; Read-Only ;;;
;;;;;;;;;;;;;;;;;

(defun lui-read-only ()
  "Make the current output read-only if `lui-read-only-output-p' is non-nil."
  (when lui-read-only-output-p
    (add-text-properties (point-min) lui-output-marker
                         '(read-only t
                           front-sticky t
                           ;; XEmacs stuff.
                           start-open nil))))


(provide 'lui)
;;; lui.el ends here
