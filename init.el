;; Reduce garbage collections while loading the configuration.
(defconst my-normal-gc-cons-threshold (* 16 1024 1024)
  "Garbage collection threshold used after Emacs has started.")

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold my-normal-gc-cons-threshold
                  gc-cons-percentage 0.1)))

(use-package which-key
  :ensure nil
  :config
  (which-key-mode 1))

;; Установка темы nord
(add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/themes/"))
(load-theme 'nord t)

;; Disable shitty ring
(setq ring-bell-function 'ignore)

;; Open complie as horizontal separation
(add-to-list
 'display-buffer-alist
 '("\\*compilation\\*"
   (display-buffer-in-side-window)
   (side . bottom)
   (slot . 0)
   (window-height . 0.3)
   (preserve-size . (nil . t))))

;; Font
(set-face-attribute 'default nil
                    :family "Go-Mono"
                    :height 140)


;; Minimal UI
;; Disable top menu bar: File / Edit / Options...
(if (display-graphic-p) (menu-bar-mode -1))
;; Disable toolbar with icons
(if (display-graphic-p) (tool-bar-mode -1))
;; Disable scrollbar
(if (display-graphic-p) (scroll-bar-mode -1))


;; Mouse selection
(xterm-mouse-mode 1)
(setq mouse-drag-copy-region nil) ; выделять, но не копировать сразу
;; чтобы выделение мышью сразу попадало в clipboard, добавь
;; (setq mouse-drag-copy-region t)
;;

;; Clipboard
(setq select-enable-clipboard t)
; Use primary X selection for middle-click
(setq select-enable-primary t)
;;

;; Set tab to 4 spaces    
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default standard-indent 4)
;; 

(defun my-unindent-4-spaces ()
  "Remove up to 4 leading spaces from the current line or region."
  (interactive)
  (if (use-region-p)
      ;; Если выделен регион — сдвигаем все строки региона влево                                          
      (let ((deactivate-mark nil))
	(indent-rigidly (region-beginning) (region-end) -4))
    ;; Если региона нет — удаляем до 4 пробелов в начале текущей строки                                   
    (save-excursion
      (back-to-indentation)
      (let ((col (current-column)))
	(when (>= col 4)
          (delete-region (- (point) 4) (point)))))))

;; Удаление строки по shift + del
(defun my-delete-current-line ()
  "Delete current line without saving it to kill-ring."
  (interactive)
  (delete-region
   (line-beginning-position)
   (min (point-max) (1+ (line-end-position)))))
;;


;; Familiar copy, cut, paste and undo shortcuts.
(cua-mode 1)
;; Do not use CUA rectangle selection.
(setq cua-enable-cua-keys t)

;; Copy / paste / cut
(defun my-copy ()
  "Copy selected region."
  (interactive)
  (if (use-region-p)
      (kill-ring-save (region-beginning) (region-end))
    (message "No region selected")))

(defun my-cut ()
  "Cut selected region."
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (message "No region selected")))

;; ctrl + shift и стрелка вверх/вниз для перемещения строчки
(defun my-move-line-up ()
  "Move current line or selected region up by one line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun my-move-line-down ()
  "Move current line or selected region down by one line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

;;Подсветка текущей строки
;; Line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type t)

;; Highlight current line
(global-hl-line-mode 1)

;; Theme-aware current line / line number styling
(set-face-attribute 'hl-line nil
                    :inherit 'highlight)

(set-face-attribute 'line-number nil
                    :inherit 'shadow
                    :background 'unspecified
                    :foreground 'unspecified)

(set-face-attribute 'line-number-current-line nil
                    :inherit '(highlight line-number)
                    :weight 'bold
                    :background 'unspecified
                    :foreground 'unspecified)

;; end



;; Emacs temporary/cache directory
(defvar my-emacs-temp-dir
  (expand-file-name "tmp/" user-emacs-directory)
  "Directory for temporary Emacs files.")

(dolist (dir '("backups/" "autosaves/" "locks/"))
  (make-directory (expand-file-name dir my-emacs-temp-dir) t))

(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups/" my-emacs-temp-dir))))

(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "autosaves/" my-emacs-temp-dir) t)))

(setq lock-file-name-transforms
      `((".*" ,(expand-file-name "locks/" my-emacs-temp-dir) t)))



;; Disable startup screen
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)

;; Start with scratch buffer
(setq initial-buffer-choice nil)
(setq initial-scratch-message nil)

;; Закрытие emacs по ctrl + q 
(defun my-quit-emacs ()
  "Quit Emacs."
  (interactive)
  (save-buffers-kill-terminal))

;; Настройка mode-line
;; Cleaner mode-line
(setq column-number-mode t)
(setq line-number-mode t)
(setq size-indication-mode nil)

(defun my-buffer-char-count ()
  "Return current buffer character count."
  (number-to-string (buffer-size)))

(setq-default mode-line-format
              '("%e"
                mode-line-front-space

                ;; Modified / read-only state
                (:eval
                 (cond
                  (buffer-read-only " RO ")
                  ((buffer-modified-p) " * ")
                  (t " - ")))

                ;; File/buffer name
                (:eval
                 (if buffer-file-name
                     (file-name-nondirectory buffer-file-name)
                   "%b"))

                "  |  "

                ;; Cursor position
                "Ln %l, Col %c"

                "  |  "

                ;; Character count
                (:eval
                 (concat "Chars " (my-buffer-char-count)))

                "  |  "

                ;; Encoding / line endings
                (:eval
                 (let* ((coding buffer-file-coding-system)
                        (eol (coding-system-eol-type coding))
                        (eol-name
                         (cond
                          ((eq eol 0) "LF")
                          ((eq eol 1) "CRLF")
                          ((eq eol 2) "CR")
                          (t "?"))))
                   (format "%s/%s"
                           (coding-system-base coding)
                           eol-name)))

                "  |  "

                ;; Major mode / syntax
                mode-name
                mode-line-end-spaces))



;; Tabs
(tab-bar-mode -1)
;; always show tab bar
;; (setq tab-bar-show -1)
;; (setq tab-bar-new-tab-choice "*scratch*")
;; (setq tab-bar-close-button-show nil)
;; (setq tab-bar-new-button-show nil)
;; (setq tab-bar-tab-hints nil)

;; Optional: nicer tab names
(setq tab-bar-tab-name-function #'tab-bar-tab-name-current)

;; Restore buffers/windows between sessions
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(winner-mode 1)

(setq desktop-dirname user-emacs-directory)
(setq desktop-base-file-name "desktop")
(setq desktop-base-lock-name "desktop.lock")
(setq desktop-path (list user-emacs-directory))

(setq desktop-save t)
(setq desktop-load-locked-desktop t)
(setq desktop-restore-eager 0)
(setq desktop-restore-frames nil)
;; Игнорируем мусорные буфферы
(setq desktop-buffers-not-to-save
      "\\(^ \\|\\*Completions\\*\\|\\*Messages\\*\\|\\*Warnings\\*\\|\\*Help\\*\\|\\*scratch\\*\\)")
(desktop-save-mode 1)



;;;;;;;;;;;;;;;packages from pkg manager

;; External packages are installed automatically when missing.
(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

;; Autocomplete: load Company only when a text or programming buffer needs it.
(use-package company
  :ensure t
  :commands company-complete
  :hook ((prog-mode . company-mode)
         (text-mode . company-mode))
  :init
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1
        company-selection-wrap-around t
        company-tooltip-align-annotations t
        company-backends '((company-dabbrev company-files))
        company-dabbrev-other-buffers t
        company-dabbrev-code-other-buffers t
        company-dabbrev-downcase nil
        company-dabbrev-minimum-length 2
        company-dabbrev-ignore-case t))

;; Better search/completion UI.  These modes are needed from the first
;; minibuffer interaction, so only this small core is loaded eagerly.
(use-package vertico
  :ensure t
  :demand t
  :config
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :after vertico
  :demand t
  :config
  (marginalia-mode 1))

(use-package orderless
  :ensure t
  :demand t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion)))))

(use-package consult
  :ensure t
  :commands (consult-buffer consult-line consult-ripgrep consult-goto-line))

(use-package embark
  :ensure t
  :commands (embark-act embark-dwim embark-bindings)
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :ensure t
  :after (embark consult))

;; Search using ripgrep
(defun my-search-project ()
  "Search in current project or current directory using ripgrep."
  (interactive)
  (consult-ripgrep
   (or (when-let ((project (project-current nil)))
         (project-root project))
       default-directory)))

(defun my-search-directory (directory)
  "Search recursively in DIRECTORY using ripgrep."
  (interactive "DSearch directory: ")
  (consult-ripgrep directory))

(defun load-nordic-midnight ()
  "Load Nordic Midnight on top of Nordic Night."
  (interactive)

  ;; Отключить ранее активированные темы.
  (mapc #'disable-theme custom-enabled-themes)

  ;; Сначала базовая тема, затем переопределения.
  (load-theme 'nordic-night t)
  (load-theme 'nordic-midnight t))


;; C-f       искать в текущем файле
;; C-S-f     искать по проекту/папке
;; C-p       искать команду Emacs по имени
;; Consult ripgrep:
;;hello              найти hello
;; hello world        найти строки, подходящие под оба слова через orderless-фильтрацию
;; #hello world       передать hello world напрямую в ripgrep
;; #TODO -- -g "*.el" искать TODO только в .el файлах


;; Sublime-like multiple cursors.
(use-package multiple-cursors
  :ensure t
  :commands (mc/mark-previous-like-this mc/mark-next-like-this)
  :init
  (setq mc/always-run-for-all t))

;; Использование всплывающего окна (по нажатию ctrl+p)вместо командной строки внизу
;; По аналогии с sublime text
(use-package vertico-posframe
  :ensure t
  :after vertico
  :defer 1
  :custom
  ;; Показывать окно по центру Emacs.
  (vertico-posframe-poshandler
   #'posframe-poshandler-frame-center)

  ;; Небольшая рамка и внутренние отступы.
  (vertico-posframe-border-width 2)
  (vertico-posframe-parameters
   '((left-fringe . 8)
     (right-fringe . 8)))

  :config
  (vertico-posframe-mode 1))


;; Пакет для поведения похожего на ide для удобного перемещения между позициями
;;(use-package dogears
;;  :ensure t
;;
;;  :custom
;;  ;; Запоминать позицию после 1 секунды бездействия.
;;  (dogears-idle 0.5)
;;
;;  ;; Размер истории.
;;  (dogears-limit 200)
;;
;;  :bind
;;  (("M-<left>"  . dogears-back)
;;   ("M-<right>" . dogears-forward))
;;
;;  :config
;;  (dogears-mode 1)

  ;; Запоминать позицию непосредственно перед крупными переходами.
;;  (dolist (command '(switch-to-buffer
;;                     find-file
;;                     beginning-of-buffer
;;                     end-of-buffer
;;                     xref-find-definitions
;;                     xref-find-references))
;;    (unless (advice-member-p #'dogears-remember command)
;;      (advice-add command :before #'dogears-remember))))
;;

;; git
(use-package magit
  :ensure t
  :commands (magit-status magit-dispatch))

;; Автоматическое закрытие скобок итд
(require 'elec-pair)
(setq electric-pair-pairs
      '((?\( . ?\))
        (?\[ . ?\])
        (?\{ . ?\})
        (?\" . ?\")
        (?\' . ?\')
        ))

(electric-pair-mode 1)

;; Make shortcuts work in the Russian keyboard layout.  Loading this shortly
;; after startup keeps it out of the synchronous initialization path.
(use-package reverse-im
  :ensure t
  :defer 1
  :init
  (setq reverse-im-input-methods '("russian-computer")
        reverse-im-modifiers '(control meta))
  :config
  (reverse-im-mode 1))

(use-package gdscript-mode
  :ensure t
  :defer t)


;; (load-file (expand-file-name "cpp-dev.el" user-emacs-directory))
;; (company-mode 1)

(defun kill-other-buffers ()
  "Kill all buffers except the one currently active."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

(add-hook 'gdscript-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (setq tab-width 4)))


(defun open-empty-buffer ()
  "Open a new empty buffer."
  (interactive)
  (let ((buf (generate-new-buffer "*scratch-empty*")))
    (switch-to-buffer buf)
    (funcall initial-major-mode)))

;; more here https://github.com/emacs-tree-sitter/tree-sitter-langs/tree/master/repos
;; do not forget treesit-install-language-grammar
;; Emacs 30 supports grammar ABI up to version 14.  Keep tagged sources pinned:
;; newer grammar revisions can be regenerated with incompatible ABI 15.
;; The GDShader repository has no tags; its small `main' branch is still ABI 14.
(setq treesit-language-source-alist
      '((python
         "https://github.com/tree-sitter/tree-sitter-python"
         "v0.23.6")
        (gdscript
         "https://github.com/PrestonKnopp/tree-sitter-gdscript.git"
         "v2.0.0")
        (gdshader
         "https://github.com/GodOfAvacyn/tree-sitter-gdshader.git"
         "main")
        (c
         "https://github.com/tree-sitter/tree-sitter-c"
         "v0.23.3")
        (cpp
         "https://github.com/tree-sitter/tree-sitter-cpp"
         "v0.23.4")
        (bash
         "https://github.com/tree-sitter/tree-sitter-bash"
         "v0.23.3")
        (rust
         "https://github.com/tree-sitter/tree-sitter-rust.git"
         "v0.23.2")))

(defun my-install-missing-treesit-grammars ()
  "Install every missing tree-sitter grammar during startup."
  (when (treesit-available-p)
    (dolist (entry treesit-language-source-alist)
      (let* ((language (car entry))
             ;; DETAIL avoids a warning while we inspect the failure reason.
             (availability (treesit-language-available-p language t)))
        (unless (car availability)
          (let* ((source (cdr entry))
                 (revision (nth 1 source))
                 (label (if revision
                            (format "%s (%s)" language revision)
                          (symbol-name language)))
                 (grammar-directory
                  (expand-file-name "tree-sitter" user-emacs-directory)))
            (condition-case err
                (progn
                  ;; An already loaded ABI-15 library can survive overwriting.
                  ;; Remove only its user-installed copy before rebuilding.
                  (when (and (eq (cadr availability) 'version-mismatch)
                             (file-directory-p grammar-directory))
                    (dolist
                        (library
                         (directory-files
                          grammar-directory t
                          (format
                           "\\`libtree-sitter-%s\\(?:\\..*\\)?\\'"
                           (regexp-quote (symbol-name language)))))
                      (delete-file library)))
                  (message "Installing tree-sitter grammar %s..." label)
                  (treesit-install-language-grammar language)
                  (message "Tree-sitter grammar %s installed" label))
              (error
               (message "Tree-sitter grammar %s installation failed: %s"
                        label
                        (error-message-string err))))))))))

(my-install-missing-treesit-grammars)


;; ============================================================
;;                         KEYBINDINGS
;; ============================================================

(defun my-reset-text-scale ()
  "Reset text scaling in the current buffer."
  (interactive)
  (text-scale-set 0))

(defun my-identifier-char-p (char)
  "Return non-nil when CHAR is a word character or an underscore."
  (and char
       (or (eq char ?_)
           (eq (char-syntax char) ?w))))

(defun my-forward-token ()
  "Move forward over an identifier, whitespace, or one punctuation mark."
  (interactive "^")
  (when (< (point) (point-max))
    (cond
     ((my-identifier-char-p (char-after))
      (while (my-identifier-char-p (char-after))
        (forward-char 1)))
     ((eq (char-syntax (char-after)) ?\s)
      (skip-syntax-forward " "))
     (t
      (forward-char 1)))))

(defun my-backward-token ()
  "Move backward over an identifier, whitespace, or one punctuation mark."
  (interactive "^")
  (when (> (point) (point-min))
    (cond
     ((my-identifier-char-p (char-before))
      (while (my-identifier-char-p (char-before))
        (backward-char 1)))
     ((eq (char-syntax (char-before)) ?\s)
      (skip-syntax-backward " "))
     (t
      (backward-char 1)))))

(defun my-delete-token-forward ()
  "Delete one identifier, whitespace group, or punctuation mark forward."
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (let ((start (point)))
      (my-forward-token)
      (delete-region start (point)))))

(defun my-delete-token-backward ()
  "Delete one identifier, whitespace group, or punctuation mark backward."
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (let ((end (point)))
      (my-backward-token)
      (delete-region (point) end))))

(defun my-close-current-window ()
  "Close the selected window, including temporary side windows.
For windows created by `display-buffer', fall back to `quit-window'
so that the previous window layout can be restored."
  (interactive)
  (condition-case nil
      (delete-window)
    (error
     (quit-window))))

(defvar my-ctl-x-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map ctl-x-map)
    (keymap-set map "0" #'my-close-current-window)
    (keymap-set map "b" #'consult-buffer)
    map)
  "Keymap derived from `ctl-x-map' and used behind the M-p prefix.")

(defconst my-global-keybindings
  `(("TAB"               . tab-to-tab-stop)
    ("<backtab>"         . my-unindent-4-spaces)
    ("S-TAB"             . my-unindent-4-spaces)
    ("<escape>"          . keyboard-escape-quit)
    ("S-<delete>"        . my-delete-current-line)

    ;; Files, buffers and tabs
    ("C-s"               . save-buffer)
    ("C-n"               . open-empty-buffer)
    ("C-w"               . kill-current-buffer)
    ("C-S-w"             . tab-close)
    ("C-t"               . tab-new)
    ("C-<tab>"           . next-buffer)
    ("C-S-<tab>"         . previous-buffer)
    ("C-S-<iso-lefttab>" . previous-buffer)
    ("C-q"               . my-quit-emacs)

    ;; Commands and the old C-x prefix
    ("C-p"               . execute-extended-command)
    ("M-p"               . ,my-ctl-x-map)

    ;; Search and navigation
    ("C-f"               . consult-line)
    ("C-S-f"             . my-search-project)
    ("C-S-r"             . my-search-directory)
    ("M-g g"             . consult-goto-line)
    ("C-."               . embark-act)
    ("<f2>"              . xref-find-definitions)
    ("S-<f2>"            . xref-go-back)
    ("M-<left>"          . winner-undo)
    ("M-<right>"         . winner-redo)

    ;; Editing
    ("C-SPC"             . company-complete)
    ("C-/"               . comment-line)
    ("C-<left>"          . my-backward-token)
    ("C-<right>"         . my-forward-token)
    ("C-<backspace>"     . my-delete-token-backward)
    ("C-<delete>"        . my-delete-token-forward)
    ("C-S-<up>"          . my-move-line-up)
    ("C-S-<down>"        . my-move-line-down)

    ;; Completion and multiple cursors
    ("M-/"               . company-complete)
    ("M-S-<up>"          . mc/mark-previous-like-this)
    ("M-S-<down>"        . mc/mark-next-like-this)

    ;; Text scaling
    ("C-<wheel-up>"      . text-scale-increase)
    ("C-<wheel-down>"    . text-scale-decrease)
    ("C-="               . text-scale-increase)
    ("C--"               . text-scale-decrease)
    ("C-0"               . my-reset-text-scale))
  "Global keybindings used by this configuration.")

(dolist (binding my-global-keybindings)
  (keymap-global-set (car binding) (cdr binding)))

;; Package-local bindings live here as well.
(with-eval-after-load 'company
  (dolist (binding
           '(("TAB"      . company-complete-selection)
             ("<tab>"    . company-complete-selection)
             ("RET"      . nil)
             ("<return>" . nil)))
    (if (cdr binding)
        (keymap-set company-active-map
                    (car binding)
                    (cdr binding))
      (keymap-unset company-active-map (car binding)))))

(with-eval-after-load 'multiple-cursors
  ;; CUA normally treats these as single commands.  Multiple-cursors must
  ;; execute them separately for every real and fake cursor.
  (dolist (command '(cua-cut-region cua-copy-region cua-paste))
    (setq mc/cmds-to-run-once
          (delq command mc/cmds-to-run-once))
    (add-to-list 'mc/cmds-to-run-for-all command))

  ;; The global `keyboard-escape-quit' does not disable multiple-cursors.
  (keymap-set mc/keymap "<escape>" #'mc/keyboard-quit))

;; ======================= CHEAT SHEET =============
;;   M-p C-f     открыть файл, раньше C-x C-f
;;   M-p C-s     сохранить файл, раньше C-x C-s
;;   M-p b       переключить буфер
;;   M-p k       закрыть буфер
;;   M-p 2       split below
;;   M-p 3       split right
;;   M-p 0       закрыть текущее окно
;;   M-p 1       оставить одно окно
;;  alt +p, ctrl + f - find-file
;;  alt+p, b - список буферов
;;  alt+p, b, RET - переключиться на прошлый буфер
;;  ctr+g - отменить команду
;;

;; ============================================================
;;                      EMACS CHEATSHEET
;; ============================================================
;;
;; Обозначения:
;; C = Ctrl
;; M = Alt / Meta
;; S = Shift
;;
;; ------------------------------------------------------------
;; КОМАНДЫ И ОТМЕНА
;; ------------------------------------------------------------
;;
;; C-p          Найти и выполнить команду (аналог стандартного M-x)
;; C-g          Отменить текущую команду / закрыть minibuffer
;;
;; Пример:
;; C-p  find-file  RET
;;
;; ------------------------------------------------------------
;; ФАЙЛЫ И БУФЕРЫ
;; ------------------------------------------------------------
;;
;; M-p C-f      Открыть или создать файл
;; C-s          Сохранить текущий файл
;; M-p b        Переключиться на другой буфер
;; M-p k        Закрыть буфер
;; M-p C-b      Показать список буферов
;;
;; Файл хранится на диске.
;; Буфер — открытая копия файла внутри Emacs.
;;
;; ------------------------------------------------------------
;; РЕДАКТИРОВАНИЕ
;; ------------------------------------------------------------
;;
;; C-c          Копировать выделенный текст
;; C-x          Вырезать выделенный текст
;; C-v          Вставить
;;
;; C-z          Отменить действие
;; C-S-z        Вернуть отменённое действие
;; S-Delete     Удалить текущую строку
;; C-S-Up       Переместить строку вверх
;; C-S-Down     Переместить строку вниз
;;
;; TAB          Добавить отступ
;; S-TAB        Убрать до 4 пробелов отступа
;;
;; ------------------------------------------------------------
;; ПОИСК
;; ------------------------------------------------------------
;;
;; C-f          Искать в текущем файле через consult-line
;; C-S-f        Искать по проекту или текущей папке через ripgrep
;;
;; Во время поиска:
;; Up / Down     Выбрать результат
;; RET           Перейти к результату
;; C-g           Отменить поиск
;;
;; ------------------------------------------------------------
;; ОКНА
;; ------------------------------------------------------------
;;
;; M-p 2        Разделить экран сверху и снизу
;; M-p 3        Разделить экран слева и справа
;; M-p o        Перейти в другое окно
;; M-p 0        Закрыть текущее окно
;; M-p 1        Оставить только текущее окно
;;
;; Окно — область экрана.
;; Закрытие окна не закрывает буфер.
;;
;; ------------------------------------------------------------
;; ВКЛАДКИ И БУФЕРЫ
;; ------------------------------------------------------------
;;
;; C-t          Создать новую вкладку
;; C-S-w        Закрыть текущую вкладку
;; C-w          Закрыть текущий буфер
;; C-Tab        Следующий буфер
;; C-S-Tab      Предыдущий буфер
;;
;; ------------------------------------------------------------
;; АВТОДОПОЛНЕНИЕ COMPANY
;; ------------------------------------------------------------
;;
;; C-SPC        Вызвать автодополнение
;; M-/          Вызвать автодополнение (дополнительная клавиша)
;;
;; Когда список дополнений открыт:
;; C-n          Следующий вариант
;; C-p          Предыдущий вариант
;; TAB          Принять выбранный вариант
;; RET          Новая строка, не принятие варианта
;;
;; ------------------------------------------------------------
;; НЕСКОЛЬКО КУРСОРОВ
;; ------------------------------------------------------------
;;
;; M-S-Down     Добавить курсор на следующее совпадение
;; M-S-Up       Добавить курсор на предыдущее совпадение
;; C-g          Завершить работу с несколькими курсорами
;;
;; ------------------------------------------------------------
;; СПРАВКА
;; ------------------------------------------------------------
;;
;; C-p describe-key       Узнать, что делает клавиша
;; C-p describe-function  Прочитать описание функции
;; C-p describe-variable  Прочитать описание переменной
;; C-p describe-mode      Узнать текущий major mode
;;
;; Пример:
;; C-p  describe-key  RET  C-f
;;
;; ------------------------------------------------------------
;; ВЫХОД
;; ------------------------------------------------------------
;;
;; C-q          Закрыть Emacs
;;
;; Emacs предложит сохранить изменённые файлы.
;;
;; ------------------------------------------------------------
;; ГЛАВНОЕ НА КАЖДЫЙ ДЕНЬ
;; ------------------------------------------------------------
;;
;; C-p          Выполнить команду
;; M-p C-f      Открыть файл
;; C-s          Сохранить
;; M-p b        Переключить буфер
;; C-f          Поиск в файле
;; C-S-f        Поиск по проекту
;; C-z          Отмена
;; C-g          Прервать команду
;; M-g g        Перейти к строке
;; Если не знаешь клавишу — используй C-p и имя команды.
;; Если Emacs ждёт непонятный ввод — нажми C-g.
;;
;; ============================================================
