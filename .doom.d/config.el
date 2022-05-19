;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Mateusz Milian"
      user-mail-address "mateusz.milian@gmail.com")

(setq doom-theme 'doom-one)

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…")               ; Unicode ellispis are nicer than "...", and also save /precious/ space

(display-time-mode 1)                             ; Enable time in the mode-line

(if (equal "Battery status not available"
           (battery))
    (display-battery-mode 1)                        ; On laptops it's nice to know how much power you have
  (setq password-cache-expiry nil))               ; I can trust my desktops ... can't I? (no battery = desktop)

(global-subword-mode 1)                           ; Iterate through CamelCase words

(setq evil-vsplit-window-right t
      evil-split-window-below t)

(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (+ivy/switch-buffer))

(setq +ivy-buffer-preview t)

(map! :map evil-window-map
      "SPC" #'rotate-layout
      ;; Navigation
      "<left>"     #'evil-window-left
      "<down>"     #'evil-window-down
      "<up>"       #'evil-window-up
      "<right>"    #'evil-window-right
      ;; Swapping windows
      "C-<left>"       #'+evil/window-move-left
      "C-<down>"       #'+evil/window-move-down
      "C-<up>"         #'+evil/window-move-up
      "C-<right>"      #'+evil/window-move-right)

(setq projectile-project-search-path '("~/dev/play" "~/dev/my-projects" "~/dev/ledger"))

(setq org-directory "~/.gdrive/Roam")
(add-hook 'org-mode-hook (lambda ()
                             (setq-local time-stamp-active t
                                         time-stamp-start "#\\+modified:[ \t]*"
                                         time-stamp-end "$"
                                         time-stamp-format "%Y-%m-%d T%H:%M:%S")
                             (add-hook 'before-save-hook 'time-stamp nil 'local)))

(use-package! md-roam
  :after org-roam
  :config
  (set-company-backend! 'markdown-mode 'company-capf) ; add company-capf as company backend in markdown buffers
  (setq org-roam-file-extensions '("org" "md")) ; enable Org-roam for a markdown files
  ;;(setq md-roam-use-org-file-links nil)
  ;;(setq md-roam-use-markdown-file-links t)
  (md-roam-mode 1) ; md-roam-mode needs to be active before org-roam-db-sync
  ;;(org-roam-db-autosync-mode 1)
  (add-to-list 'org-roam-capture-templates
               '("m" "Markdown" plain "" :target
                 (file+head "%<%Y-%m-%dT%H%M%S>-${slug}.md"
                            "---\ntitle: ${title}\nid: %<%Y-%m-%dT%H%M%S>\ncategory: \n---\n")
                 :unnarrowed t)))

(use-package! org-roam
  :init
  (map! :leader
        :prefix "n"
        :desc "org-roam" "l" #'org-roam-buffer-toggle
        :desc "org-roam-node-insert" "i" #'org-roam-node-insert
        :desc "org-roam-node-find" "f" #'org-roam-node-find
        :desc "org-roam-ref-find" "r" #'org-roam-ref-find
        :desc "org-roam-show-graph" "g" #'org-roam-show-graph
        :desc "org-roam-capture" "c" #'org-roam-capture
        :desc "org-roam-dailies-capture-today" "j" #'org-roam-dailies-capture-today
        :desc "org-roam" "l" #'org-roam-buffer-toggle)
  (setq org-roam-directory (file-truename "~/.gdrive/Roam")
        org-roam-db-gc-threshold most-positive-fixnum
        org-id-link-to-org-use-id t)
:config
   (set-popup-rules!
    `((,(regexp-quote org-roam-buffer) ; persistent org-roam buffer
       :side right :width .33 :height .5 :ttl nil :modeline nil :quit nil :slot 1)
      ("^\\*org-roam: " ; node dedicated org-roam buffer
       :side right :width .33 :height .5 :ttl nil :modeline nil :quit nil :slot 2)))
  (add-hook 'org-roam-mode-hook #'turn-on-visual-line-mode)
 (setq org-roam-capture-templates
        '(("d" "default" plain
           "%?"
           :if-new (file+head "${slug}.org"
                              "#+title: ${title}\n#+created: %<%Y-%m-%d>\n#+modified: \n#+filetags: \n")
           :immediate-finish t
           :unnarrowed t)))
  (setq org-roam-capture-ref-templates
        '(("r" "ref" plain
           "%?"
           :if-new (file+head "${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t))))

(after! ispell
  ;; Configure `LANG`, otherwise ispell.el cannot find a 'default
  ;; dictionary' even though multiple dictionaries will be configured
  ;; in next line.
  (setenv "LANG" "en_US.UTF-8")
  ;; Configure.
  (setq ispell-hunspell-dict-paths-alist
    '(("en_US" "C:/Hunspell/en_US.aff")
      ("pl_PL" "C:/Hunspell/pl_PL.aff")))

  (setq ispell-dictionary "en_US")
  ;; ispell-set-spellchecker-params has to be called
  ;; before ispell-hunspell-add-multi-dic will work
  ;; (ispell-set-spellchecker-params)
  ;;(ispell-hunspell-add-multi-dic "pl_PL,en_US"))
  ;; For saving words to the personal dictionary, don't infer it from
  ;; the locale, otherwise it would save to ~/.hunspell_pl_PL.
  (setq ispell-personal-dictionary "~/.emacs.d/.packages/.hunspell_personal"))
  ;; (setq ispell-program-name "~/.emacs.d/.packages/hunspell.exe"))
;; The personal dictionary file has to exist, otherwise hunspell will
;; silently not use it.
;;(unless (file-exists-p ispell-personal-dictionary)
;;  (write-region "" nil ispell-personal-dictionary nil 0))

(setq yas-snippet-dirs (append yas-snippet-dirs '("~/.doom.d/snippets")))

;; (setq clojure-toplevel-inside-comment-form 't)
