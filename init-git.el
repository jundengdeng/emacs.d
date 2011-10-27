;;(setq load-path (cons (expand-file-name "/usr/share/doc/git-core/contrib/emacs") load-path))
;; Downloaded from http://git.kernel.org/?p=git/git.git ;a=tree;hb=HEAD;f=contrib/emacs
(require 'vc-git)
(when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(autoload 'git-blame-mode "git-blame" "Minor mode for incremental blame for Git." t)


(require 'magit)
(setq magit-save-some-buffers nil)
(setq magit-process-popup-time 4)
(setq magit-completing-read-function 'magit-ido-completing-read)

(defun magit-status-somedir ()
  (interactive)
  (let ((current-prefix-arg t))
    (magit-status default-directory)))

(global-set-key [(meta f12)] 'magit-status)
(global-set-key [(shift meta f12)] 'magit-status-somedir)

(when *is-a-mac*
  (add-hook 'magit-mode-hook (lambda () (local-unset-key [(meta h)]))))

(require 'magit-svn)
(require 'rebase-mode)
(require 'diff-git)

;;----------------------------------------------------------------------------
;; git-svn conveniences
;;----------------------------------------------------------------------------
(eval-after-load "compile"
  '(progn
     (mapcar (lambda (defn) (add-to-list 'compilation-error-regexp-alist-alist defn))
             (list '(git-svn-updated "^\t[A-Z]\t\\(.*\\)$" 1 nil nil 0 1)
                   '(git-svn-needs-update "^\\(.*\\): needs update$" 1 nil nil 2 1)))
     (mapcar (lambda (defn) (add-to-list 'compilation-error-regexp-alist defn))
             (list 'git-svn-updated 'git-svn-needs-update))))

(defun git-svn (dir)
  (interactive "DSelect directory: ")
  (let* ((default-directory (git-get-top-dir dir))
         (compilation-buffer-name-function (lambda (major-mode-name) "*git-svn*")))
    (compile (concat "git svn "
                     (ido-completing-read "git-svn command: "
                                          (list "rebase" "dcommit" "fetch" "log") nil t)))))






(eval-after-load "gist"
  ;; Fix from https://github.com/defunkt/gist.el/pull/16
  '(defun gist-region (begin end &optional private &optional callback)
     "Post the current region as a new paste at gist.github.com
Copies the URL into the kill ring.

With a prefix argument, makes a private paste."
     (interactive "r\nP")
     (let* ((file (or (buffer-file-name) (buffer-name)))
            (name (file-name-nondirectory file))
            (ext (or (cdr (assoc major-mode gist-supported-modes-alist))
                     (file-name-extension file)
                     "txt")))
       (gist-request
        (format "https://%s@gist.github.com/gists" 
                (or (car (github-auth-info)) ""))
        (or callback 'gist-created-callback)
        `(,@(if private '(("action_button" . "private")))
          ("file_ext[gistfile1]" . ,(concat "." ext))
          ("file_name[gistfile1]" . ,name)
          ("file_contents[gistfile1]" . ,(buffer-substring begin end)))))))





(provide 'init-git)
