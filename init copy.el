;;
;; ---- #happymacs --------------------
;;  "cheerful emacs for modern humans"
;;  created: 01/08/2015
;; ------------------------------------
;;

;; --- TODO ---
;;
;; • modeline line nums are borked sometimes in brew emacs (not railwaycat)
;; • prevent copy from clearing region
;; • tabs
;; • fix indenting - use tabs
;; • lisp paren cuddling - change formatting?
;; • show total line count in modeline
;; • shortcut key for reindent region
;; • autocomplete / etags
;; • spell checking
;; • move into dropbox
;; • shortcuts for window/frame movement
;; • function lists/jumps
;; • docco for symbol under cursor
;; • change minimap line hl color from yellow to light gray
;; • add pre and post init.el calls
;; • happimacs
;; • swap ctrl and super on win and linux then remove custom ctrl bindings
;; • load user packages from prehook
;; • custom super key in prehook (eg for tablet kbs)
;; • switch between standard LISP indenting and javaish indeting in prehook
;; • switch between spaces and tabs for indenting in prehook
;; • esc to quit help windows (act as q)
;; • fix backward kill word to not kill past SOL
;; • turn off/hide cursor in minimap
;; • add irony for C mode
;; • when SOL, alt-right should move to first non-whitespace character
;; • remap meta-x to something better
;; • remap esc to quit
;; • flycheck, flyspell
;; • fix weird line duplication flakes

;; -- TODO done
;;
;; • del current line
;; • dupe current line
;; • highilght current line in fringe?
;; • ctrl s to save file
;; • ctrl o to open file
;; • start of line / eol shortcut keys
;; • speedbar / goog-nav
;; • project mgmt - helm?

;; --- Preloads ---

;;(setq hm-home "~/workspac /")
(load-file "~/workspace/.happymacs/init-pre.el")
(message "#happymacs: init-pre.el complete")

;; --- Foundation ---


;; -- autovivify folders (otherwise emacs will error when creating a file in a new folder)
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
	(let ((dir (file-name-directory filename)))
	  (unless (file-exists-p dir)
		(make-directory dir)))))

(add-hook 'before-save-hook
          (lambda ()
            (when buffer-file-name
              (let ((dir (file-name-directory buffer-file-name)))
                (when (and (not (file-exists-p dir))
                           (y-or-n-p (format "Directory %s does not exist. Create it?" dir)))
                  (make-directory dir t))))))

;; --- Package management ---
;;

(require 'package)

(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
;;(add-to-list 'package-archives '("melpa" . "http://melpa-stable.milkbox.net/packages/") t)
;;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
;;(add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/") t)

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

;; TODO this seems to flake out on new packages sometimes, need to debug

(defvar my-packages
  '(
	cider
	clang-format
	clojure-mode
	clojure-mode-extra-font-locking
	color-theme-sanityinc-tomorrow
	company
;; ergoemacs-mode
	;; eldoc
	exec-path-from-shell
	flx
	flx-ido
	;; flyspell
	git-gutter
	git-gutter-fringe
	helm
helm-projectile
;; icicles
	ido-ubiquitous
	;;	  ido-completing-read
	;;	  neotree
	minimap ;; sublime-stye minimap, toggle with <f5>
	org ;; everyone seems to love org-mode
	paredit ;; better sexp editing for clojure etc
	project-explorer
	projectile
	rainbow-delimiters ;; show nested parens with matching colors
	rainbow-mode ;; pretty syntax for hex colors eg #0000ff
	redo+ ;; modern undo/redo - less powerful than emacs native but easier to use
	saveplace ;; restore last known cursor location in current file on focus
	;; project-persist-drawer
	;; ppd-sr-speedbar
	smex
	;;	  smooth-scrolling
	tabbar
	;; windmove
	;;	  tagedit
	magit
	))

;; ;; fix shell on osx
;; (if (eq system-type 'darwin)
;; 	(add-to-list 'my-packages 'exec-path-from-shell))

(dolist (p my-packages)
  (when (not (package-installed-p p))
	(package-install p)))

;; --- Local packages ---

(add-to-list 'load-path "~/workspace/.happymacs/local-packages")
(load "nyan-mode/nyan-mode.el")
(load "uncrustify/uncrustify.el")
(load "minimap/minimap.el")

;; (load "emacs-nav/nav.el")
;; (load "sr-speedbar/sr-speedbar.el")

;; (load "sublimity/sublimity.el")
;; (load "sublimity/sublimity-scroll.el")
;; (load "sublimity/sublimity-map.el")
;; (load "sublimity/sublimity-attractive.el")

(message "#happymacs: Package setup complete.")

;; --- Environment config ---
;;

;; -- backups
;; (setq make-backup-files nil)
(setq backup-directory-alist '(("." . "~/workspace/.happymacs/tmp/backups")))
(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-file-name-transforms '((".*" "~/workspace/.happymacs/tmp/auto-save-list/" t)))

;; -- sessions
(setq desktop-dirname		  "~/workspace/.happymacs/tmp/desktop/"
	  desktop-base-file-name	  "emacs.desktop"
	  desktop-base-lock-name	  "lock"
	  desktop-path		  (list desktop-dirname)
	  desktop-save		  t
	  desktop-files-not-to-save	  "^$" ;reload tramp paths
	  desktop-load-locked-desktop nil)
(desktop-save-mode 1) ; save session on quit
(add-hook 'auto-save-hook (lambda () (desktop-save-in-desktop-dir))) ; autosave sessions

(message "#happymacs: environment setup complete.")

;; --- Editing ---
;;

(transient-mark-mode 1)
(delete-selection-mode 1) ; type over selections
(define-key global-map (kbd "RET") 'newline-and-indent) ; auto indent newlines

;; -- indenting
;; (global-set-key (kbd "s-/") 'comment-dwim)
(global-set-key (kbd "s-/") 'comment-or-uncomment-region) ;; modern-style region commenting
(setq-default indent-tabs-mode t) ;; use tabs not spaces
(setq tab-width 4)
(setq indent-tabs-mode t)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)
(setq default-tab-width 4)
(setq c-basic-indent 4)
(setq c-basic-offset 4)

(superword-mode 1)

;;/usr/local/Cellar/clang-format/2015-07-31/bin
(load "/usr/local/Cellar/clang-format/2015-07-31/share/clang/clang-format.el")
(global-set-key (kbd "C-F") 'clang-format-region)

(defun pprint (form &optional output-stream)
  (princ (with-temp-buffer
           (cl-prettyprint form)
           (buffer-string))
         output-stream))


(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (tabify (point-min) (point-max)))


;; -- searching
(global-set-key (kbd "s-f") 'isearch-forward-regexp)
(define-key isearch-mode-map (kbd "s-f") 'isearch-repeat-forward)
(define-key isearch-mode-map (kbd "<return>") 'isearch-repeat-forward)
(global-set-key (kbd "s-F") 'isearch-backward-regexp)
(define-key isearch-mode-map (kbd "s-F") 'isearch-repeat-backward)
;; (define-key isearch-mode-map (kbd "<up>") 'isearch-repeat-backward)

;; automatically wrap isearch at EOF (instead of displaying "failing search" message)
(defadvice isearch-search (after isearch-no-fail activate)
  (unless isearch-success
	(ad-disable-advice 'isearch-search 'after 'isearch-no-fail)
	(ad-activate 'isearch-search)
	(isearch-repeat (if isearch-forward 'forward))
	(ad-enable-advice 'isearch-search 'after 'isearch-no-fail)
	(ad-activate 'isearch-search)))

;; -- moving around lines

;; ;; experimental...
;; (defun back-to-indentation-then-sol () (interactive) ; jump to indent first then sol
;;	  (if (= (point) (progn (back-to-indentation) (point)))
;;	  (beginning-of-line)))

;; (global-set-key (kbd "s-<left>") 'back-to-indentation-then-sol)

;; (defun fwd-past-indentation-then-eol () (interactive)
;;	  (if (= (point) (progn (forward-to-indentation) (point)))
;;	  (end-of-line)))

(defvar lawlist-movement-syntax-table
  (let ((st (make-syntax-table)))
    ;; ` default = punctuation
    ;; ' default = punctuation
    ;; , default = punctuation
    ;; ; default = punctuation
    (modify-syntax-entry ?{ "." st)  ;; { = punctuation
    (modify-syntax-entry ?} "." st)  ;; } = punctuation
    (modify-syntax-entry ?\" "." st) ;; " = punctuation
    (modify-syntax-entry ?\\ "_" st) ;; \ = symbol
    (modify-syntax-entry ?\$ "_" st) ;; $ = symbol
    (modify-syntax-entry ?\% "_" st) ;; % = symbol
    st)
  "Syntax table used while executing custom movement functions.")

(defun lawlist-forward-entity ()
"http://stackoverflow.com/q/18675201/2112489"
(interactive "^")
  (with-syntax-table lawlist-movement-syntax-table
    (cond
      ((eolp)
        (forward-char))
      ((and
          (save-excursion (< 0 (skip-chars-forward " \t")))
          (not (region-active-p)))
        (skip-chars-forward " \t"))
      ((and
          (save-excursion (< 0 (skip-chars-forward " \t")))
          (region-active-p))
        (skip-chars-forward " \t")
        (cond
          ((save-excursion (< 0 (skip-syntax-forward "w")))
            (skip-syntax-forward "w"))
          ((save-excursion (< 0 (skip-syntax-forward ".")))
            (skip-syntax-forward "."))
          ((save-excursion (< 0 (skip-syntax-forward "_()")))
            (skip-syntax-forward "_()"))))
      ((save-excursion (< 0 (skip-syntax-forward "w")))
        (skip-syntax-forward "w")
        (if (and
              (not (region-active-p))
              (save-excursion (< 0 (skip-chars-forward " \t"))))
          (skip-chars-forward " \t")))
      ((save-excursion (< 0 (skip-syntax-forward ".")))
        (skip-syntax-forward ".")
        (if (and
              (not (region-active-p))
              (save-excursion (< 0 (skip-chars-forward " \t"))))
          (skip-chars-forward " \t")))
      ((save-excursion (< 0 (skip-syntax-forward "_()")))
        (skip-syntax-forward "_()")
        (if (and
              (not (region-active-p))
              (save-excursion (< 0 (skip-chars-forward " \t"))))
          (skip-chars-forward " \t"))))))

(defun lawlist-backward-entity ()
"http://stackoverflow.com/q/18675201/2112489"
(interactive "^")
  (with-syntax-table lawlist-movement-syntax-table
    (cond
      ((bolp)
        (backward-char))
      ((save-excursion (> 0 (skip-chars-backward " \t")) (bolp))
        (skip-chars-backward " \t"))
      ((save-excursion (> 0 (skip-chars-backward " \t")) (> 0 (skip-syntax-backward "w")))
        (skip-chars-backward " \t")
        (skip-syntax-backward "w"))
      ((save-excursion (> 0 (skip-syntax-backward "w")))
        (skip-syntax-backward "w"))
      ((save-excursion (> 0 (skip-syntax-backward ".")))
        (skip-syntax-backward "."))
      ((save-excursion (> 0 (skip-chars-backward " \t")) (> 0 (skip-syntax-backward ".")))
        (skip-chars-backward " \t")
        (skip-syntax-backward "."))
      ((save-excursion (> 0 (skip-syntax-backward "_()")))
        (skip-syntax-backward "_()"))
      ((save-excursion (> 0 (skip-chars-backward " \t")) (> 0 (skip-syntax-backward "_()")))
        (skip-chars-backward " \t")
        (skip-syntax-backward "_()")))))

(add-hook 'text-mode-hook 'superword-mode)
(add-hook 'prog-mode-hook 'superword-mode)

(defvar xah-brackets nil "string of brackets")
(setq xah-brackets "()[]{}（）［］｛｝⦅⦆〚〛⦃⦄“”‘’‹›«»「」〈〉《》【】〔〕⦗⦘『』〖〗〘〙｢｣⟦⟧⟨⟩⟪⟫⟮⟯⟬⟭⌈⌉⌊⌋⦇⦈⦉⦊❛❜❝❞❨❩❪❫❴❵❬❭❮❯❰❱❲❳〈〉⦑⦒⧼⧽﹙﹚﹛﹜﹝﹞⁽⁾₍₎⦋⦌⦍⦎⦏⦐⁅⁆⸢⸣⸤⸥⟅⟆⦓⦔⦕⦖⸦⸧⸨⸩｟｠⧘⧙⧚⧛⸜⸝⸌⸍⸂⸃⸄⸅⸉⸊᚛᚜༺༻༼༽⏜⏝⎴⎵⏞⏟⏠⏡﹁﹂﹃﹄︹︺︻︼︗︘︿﹀︽︾﹇﹈︷︸")

(defvar
  xah-left-brackets
  '("(" "{" "[" "<" "〔" "【" "〖" "〈" "《" "「" "『" "“" "‘" "‹" "«" )
  "List of left bracket chars.")
(progn
  (setq xah-left-brackets '())
  (dotimes (x (- (length xah-brackets) 1))
    (message "%s" x)
    (when (= (% x 2) 0)
      (push (char-to-string (elt xah-brackets x))
            xah-left-brackets)))
  (setq xah-left-brackets (reverse xah-left-brackets)))

(defvar
  xah-right-brackets
  '(")" "]" "}" ">" "〕" "】" "〗" "〉" "》" "」" "』" "”" "’" "›" "»")
  "List of right bracket chars.")
(progn
  (setq xah-right-brackets '())
  (dotimes (x (- (length xah-brackets) 1))
    (message "%s" x)
    (when (= (% x 2) 1)
      (push (char-to-string (elt xah-brackets x))
            xah-right-brackets)))
  (setq xah-right-brackets (reverse xah-right-brackets)))
(defun xah-backward-left-bracket ()
  "Move cursor to the previous occurrence of left bracket.
The list of brackets to jump to is defined by `xah-left-brackets'.
URL `http://ergoemacs.org/emacs/emacs_navigating_keys_for_brackets.html'
Version 2015-03-24"
  (interactive)
  (search-backward-regexp (eval-when-compile (regexp-opt xah-left-brackets)) nil t))

(defun xah-forward-right-bracket ()
  "Move cursor to the next occurrence of right bracket.
The list of brackets to jump to is defined by `xah-right-brackets'.
URL `http://ergoemacs.org/emacs/emacs_navigating_keys_for_brackets.html'
Version 2015-03-24"
  (interactive)
  (search-forward-regexp (eval-when-compile (regexp-opt xah-right-brackets)) nil t))

(global-set-key (kbd "M-C-<left>") 'xah-backward-left-bracket)
(global-set-key (kbd "M-C-<right>") 'xah-forward-right-bracket)


(global-set-key (kbd "M-<up>") 'backward-paragraph)
(global-set-key (kbd "M-<down>") 'forward-paragraph)
(global-set-key (kbd "M-<left>") 'lawlist-backward-entity)
(global-set-key (kbd "M-<right>") 'lawlist-forward-entity)

(global-set-key (kbd "s-<left>") 'beginning-of-line)
(global-set-key (kbd "s-<right>") 'end-of-line)
(global-set-key (kbd "s-<up>") 'beginning-of-buffer)
(global-set-key (kbd "s-<down>") 'end-of-buffer)

(global-set-key (kbd "s-o") 'ido-find-file)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-w") 'kill-this-buffer)
(global-set-key (kbd "s-q") 'save-buffers-kill-terminal)
(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-Z") 'redo)
(global-set-key (kbd "s-y") 'redo)
(global-set-key (kbd "s-a") 'mark-whole-buffer) ;; TODO retain scroll position
;; TODO how to clear the mark / select none?

;; -- buffers, windows, frames
(global-set-key (kbd "s-b") 'ido-switch-buffer)
(global-set-key (kbd "S-s-<left>") 'previous-buffer)
(global-set-key (kbd "S-s-<right>") 'next-buffer)
(global-set-key (kbd "<C-tab>") 'bury-buffer)
;; mapping C-; to other-window (cycling through windows)
;; mapping C-' to other-frame

;; -- launch "apps"
(global-set-key (kbd "s-1") 'eshell)
;; (global-set-key (kbd "s-2") 'org)
(global-set-key (kbd "s-3") 'calendar)
;; (global-set-key (kbd "s-4") 'email)
;; (global-set-key (kbd "s-5") 'web)
;; (global-set-key (kbd "s-6") 'chat)


;; create new buffer
(defun new-empty-buffer ()
  "Opens a new empty buffer."
  (interactive)
  (switch-to-buffer (generate-new-buffer "untitled"))
  (funcall initial-major-mode)
  (put 'buffer-offer-save 'permanent-local t)
  (setq buffer-offer-save t))
(global-set-key (kbd "s-n") 'new-empty-buffer)

;; -- set modifier keys for osx
(when (equal system-type 'darwin)
  (setq mac-option-modifier 'meta) ;; Bind meta to alt
  (setq mac-command-modifier 'super) ;; Bind apple/command to super
  ;;  (setq mac-function-modifier 'hyper)) ;; Bind function key to hyper
  )

;; -- super keys for windows + osx
(setq w32-pass-lwindow-to-system nil)
(setq w32-lwindow-modifier 'super) ; left windows key
(setq w32-pass-rwindow-to-system nil)
(setq w32-rwindow-modifier 'super) ; right windows key

;; -- delete backwards by word
(defun backward-kill-word-or-kill-region (&optional arg)
  (interactive "p")
  (if (region-active-p)
	  (kill-region (region-beginning) (region-end))
	(backward-kill-word arg)))

;;(global-set-key (kbd "C-w") 'backward-kill-word-or-kill-region)
;;(global-set-key (kbd "<M-backspace>") 'backward-kill-word-or-kill-region)
(global-set-key (kbd "<M-backspace>") 'backward-kill-word)
;;(global-set-key "\M-\d" 'backward-kill-word-or-kill-region)

;; -- lines

;; FIXME: this is a bit flaky, maybe clear region
(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (move-beginning-of-line 1)
  (yank)
  )
(global-set-key (kbd "s-d") 'duplicate-line)
(global-set-key (kbd "s-D") 'kill-whole-line)
(global-set-key (kbd "s-D") 'kill-whole-line)

;; -- Minibuffer
;;

(setq savehist-file "~/workspace/.happymacs/tmp/mb-history") ; save history to this location
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
(savehist-mode 1)

(message "#happymacs: editing setup complete.")

;; --- UI ---
;;

;; -- general ux
(setq-default cursor-type 'bar) ; use bar instead of box for cursor
(setq gdb-many-windows t) ; enable gui mode for gdb
(setq ring-bell-function 'ignore) ; don't beep
										;(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1)) ; hide toolbar
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1)) ; hide scrollbars
;; (when (display-graphic-p) (tool-bar-mode 0)) ; hide toolbar
(show-paren-mode 1) ; show matching parens
;; (setq show-paren-style 'expression) ; highlight entire bracket expression
(setq inhibit-splash-screen t) ; hide splash screen
(fset 'yes-or-no-p 'y-or-n-p) ; ask shorter questions
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "s--") 'text-scale-decrease)
(setq echo-keystrokes 0.0)
;; (setq use-dialog-box nil)

;; open these things in the same window instead of a "popup"
(setq same-window-regexps (quote ("\*vc\-.+\*" "\*magit.+\*" "grep" "\*compilation\*\(\|<[0-9]+>\)" "\*Help\*\(\|<[0-9]+>\)" "\*Shell Command Output\*\(\|<[0-9]+>\)" "\*dictem.*")))

;; -- line highlight
(global-hl-line-mode 1) ; highlight current line
;; (set-face-background 'hl-line "#3e4446")
;; (set-face-foreground 'highlight nil) ; retain syntax hl

;; -- theme
(load-theme 'sanityinc-tomorrow-eighties t)

;; -- line numbers
(global-linum-mode t)
(set-face-attribute 'fringe nil :background "#2D2D2D")
(set-face-attribute 'linum nil :foreground "gray40" :background "#2D2D2D")

(defun display-startup-echo-area-message () (message ""))

(setq initial-scratch-message "")

;; ;; -- suppress pointless minibuff messages

;; (defadvice message (around my-message-filter activate)
;;   (unless (string-match "Text is read-only" (or (ad-get-arg 0) ""))
;;     ad-do-it))

;; (setq minibuffer-prompt-properties
;;    (quote
;; 	(read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt)))

(plist-put minibuffer-prompt-properties 'point-entered 'minibuffer-avoid-prompt)

;; fonts & colors
(set-face-attribute 'default nil
					:family "Inconsolata"
					:family "Menlo"
					:height 140
					:weight 'normal
					:width 'normal)

(when (functionp 'set-fontset-font)
  (set-fontset-font "fontset-default"
					'unicode
					(font-spec :family "DejaVu Sans Mono"
							   :width 'normal
							   :size 12.4
							   :weight 'normal)))


;; ;; TODO: make this update the application title
;; ;; automatically save buffers associated with files on buffer switch
;; ;; and on windows switch
;; (defadvice switch-to-buffer (before save-buffer-now activate)
;;	 (when buffer-file-name (save-buffer)))
;; (defadvice other-window (before other-window-now activate)
;;	 (when buffer-file-name (save-buffer)))
;; (defadvice windmove-up (before other-window-now activate)
;;	 (when buffer-file-name (save-buffer)))
;; (defadvice windmove-down (before other-window-now activate)
;;	 (when buffer-file-name (save-buffer)))
;; (defadvice windmove-left (before other-window-now activate)
;;	 (when buffer-file-name (save-buffer)))
;; (defadvice windmove-right (before other-window-now activate)
;;	 (when buffer-file-name (save-buffer)))

(message "#happymacs: UI setup complete.")

;; --- Package config ---
;;

;; -- org mode
;;(require 'org)
;; (setq org-base-path (expand-file-name "~/org"))

;; (setq org-default-notes-file-path (format "%s/%s" org-base-path "notes.org")
;;	 todo-file-path			 (format "%s/%s" org-base-path "gtd.org")
;;	 journal-file-path		 (format "%s/%s" org-base-path "journal.org")
;;	 today-file-path		 (format "%s/%s" org-base-path "2010.org"))

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; -- ido mode
(ido-mode 1)
(ido-everywhere 1)
;;(require 'ido-ubiquitous)
(ido-ubiquitous-mode 1)
;;(setq org-completion-use-ido t)
;;(setq magit-completing-read-function 'magit-ido-completing-read)
;;(setq gnus-completing-read-function 'gnus-ido-completing-read)

;; -- rainbow delims
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; -- paredit mode
;; (add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
;; (add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
;;(global-rainbow-delimiters-mode)
;;(rainbow-delimiters-mode)

;; ;; -- smooth scrolling
;; (setq scroll-margin 5 scroll-conservatively 9999 scroll-step 1)

;; -- minimap
(when (display-graphic-p)
  (message "#happymacs: gui present, enabling minimap")
  (setq minimap-window-location 'right
		minimap-hide-fringes t
		minimap-highlight-line -1 ; broken, bug in package
		minimap-update-delay 0.3) ; slower updates for smoother scrolling

  (add-hook 'minimap-sb-mode-hook (lambda ()
									(setq mode-line-format nil)
									(hl-line-mode -1)
										; fix hardcoded ugly yellow line highlight
									(setq minimap-line-overlay (make-overlay (point) (1+ (point)) nil t))
									;; (overlay-put minimap-line-overlay 'face '(:background "gray40" :foreground "gray40"))
									(overlay-put minimap-line-overlay 'priority 7)
										; TODO disable buffer cursor or change cursor color
									))
  ;; (add-hook 'minimap-mode-hook (lambda () (setq mode-line-format nil) (hl-line-mode -1)))
  (global-set-key (kbd "<f6>") 'minimap-mode)
  (minimap-mode)
  )

;; ;; -- emacs-nav
;; (require 'nav)
;; ;; (nav-disable-overeager-window-splitting)
;; (global-set-key (kbd "<f8>") 'nav-toggle)

;; -- nyanyanyan cat!!
(nyan-mode 1)

;; -- rainbow mode (display colors for hex strings etc)
(define-globalized-minor-mode my-global-rainbow-mode rainbow-mode
  (lambda () (rainbow-mode 1)))
(my-global-rainbow-mode 1)

;; -- sr-speedbar
;; (setq speedbar-use-images nil)
;; (make-face 'speedbar-face)
;; (set-face-font 'speedbar-face "Inconsolata-12")
;; (setq speedbar-mode-hook '(lambda () (buffer-face-set 'speedbar-face)))

;; -- project-explorer sidebar
(global-set-key (kbd "<f5>") 'project-explorer-toggle)

;; -- tabbar
										;(tabbar-mode)

;; -- redo+
(setq undo-no-redo t) ;; discard the old undo branch immediately

;; -- projectile
(projectile-global-mode)
;; (add-hook 'ruby-mode-hook 'projectile-mode)

;; -- git-gutter-fringe+
(global-git-gutter-mode t)
(git-gutter:linum-setup)
;; (git-gutter:update-interval 30)

(setq git-gutter:added-sign " + "
	  git-gutter:deleted-sign " - "
	  git-gutter:modified-sign " > "
	  git-gutter:update-interval 30)

(set-face-attribute 'git-gutter:added nil :foreground "#5C97CF" :weight 'normal)
(set-face-attribute 'git-gutter:modified nil :foreground "#5C97CF" :weight 'normal)
(set-face-attribute 'git-gutter:deleted nil :foreground "#CD93A8" :weight 'normal)

;; TODO hunk navigations
;; (global-set-key (kbd "C-x C-g") 'git-gutter:toggle)
;; (global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)
;; (global-set-key (kbd "C-x p") 'git-gutter:previous-hunk)
;; (global-set-key (kbd "C-x n") 'git-gutter:next-hunk)
;; (global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
;; (global-set-key (kbd "C-x v r") 'git-gutter:revert-hunk)

;; -- company mode & autocomplete
(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 0.3) ;; delay in s, t for no delay
(with-eval-after-load 'company
  (define-key company-active-map (kbd "ESC") 'company-abort)
  (define-key company-active-map (kbd "<tab>") 'company-complete))

;; (define-key company-active-map (kbd "\C-n") 'company-select-next)
;; (define-key company-active-map (kbd "\C-p") 'company-select-previous)
;; (define-key company-active-map (kbd "\C-d") 'company-show-doc-buffer)
;; (define-key company-active-map (kbd "<tab>") 'company-complete)

(global-set-key (kbd "s-.") 'hippie-expand)

;; uncrustify
(setq uncrustify-uncrustify-cfg-file "~/workspace/.happymacs/uncrustify.cfg")

;; --- Key config ---
;;

;; -- fix escape key

;; TODO: make escape clear marked region

;; (defadvice top-level (around top-level activate)
;; (message "Modified (top-level)...")
;;	 )

;; (defun my-top-level ()
;;	 (if (mark-active) (setq deactivate-mark t))
;;	 (top-level)
;; )

;; ;; (defun my-minibuffer-top-level ()
;; ;;	"Abort recursive edit.
;; ;; In Delete Selection mode, if the mark is active, just deactivate it;
;; ;; then it takes a second \\[keyboard-quit] to abort the minibuffer."
;; ;;	(interactive)
;; ;;	(if (and delete-selection-mode transient-mark-mode mark-active)
;; ;;		(setq deactivate-mark  t)
;; ;;	  (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
;; ;;	  (abort-recursive-edit))
;; ;;	(my-top-level)
;; ;;  )

;; TODO add keyboard-quit stuff in here

;; (global-set-key [escape] 'top-level) ;; breaks <esc> in company mode
(define-key minibuffer-local-map [escape] 'top-level)
(define-key minibuffer-local-ns-map [escape] 'top-level)
(define-key minibuffer-local-completion-map [escape] 'top-level)
(define-key minibuffer-local-must-match-map [escape] 'top-level)
(define-key minibuffer-local-isearch-map [escape] 'top-level)

;; -- symbols
;; TODO these shortcuts kinda suck
(progn
  (define-key key-translation-map (kbd "M-s-3") (kbd "•")) ; bullet
  (define-key key-translation-map (kbd "M-s-4") (kbd "◇")) ; white diamond
  (define-key key-translation-map (kbd "M-s-5") (kbd "†")) ; dagger
  )
(message "#happymacs: package config complete.")

;; --- Version control

(defun git-add-current-buffer ()
  "call 'git add [current-buffer]'"      
  (interactive)
  (let* ((buffile (buffer-file-name))
         (output (shell-command-to-string
                  (concat "git add " (buffer-file-name)))))
    (message (if (not (string= output ""))
                 output
               (concat "Added " buffile)))))

;; TODO prompt for commit message and push after current buffer added

(defun git-commit ()
  "call 'git commit'"
  
  (interactive)
  (async-shell-command "git commit"))

(defun git-add-commit ()

  (git-add-current-buffer)
  (git-commit)

  )


;; --- Modeline
(load-file "~/workspace/.happymacs/modeline.el")
(message "#happymacs: modeline config complete.")

;; --- User post config
(load-file "~/workspace/.happymacs/init-post.el")
(message "#happymacs: init-post.el complete")

;; (eval-after-load 'project-explorer
;;	 '(progn
;;	project-explorer-open
;;	))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;; '(git-gutter:added-sign " + ")
 ;; '(git-gutter:deleted-sign " - ")
 ;; '(git-gutter:modified-sign " > ")
 ;; '(git-gutter:update-interval 30)
 '(pe/width 30))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;; '(git-gutter:added ((t (:foreground "lawn green" :weight bold))))
 ;; '(git-gutter:deleted ((t (:foreground "red" :weight bold))))
 ;; '(git-gutter:modified ((t (:foreground "orange red" :weight bold))))
 '(minimap-active-region-background ((t (:background "#393939")))))
