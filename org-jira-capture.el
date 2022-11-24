;;; org-jira-capture.el --- Capture for JIRA comment and description       -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'org)

(defvar org-jira-capture-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-c" #'org-jira-capture-finalize)
    (define-key map "\C-c\C-k" #'org-jira-capture-kill)
    map)
  "Keymap for `org-jira-capture-mode', a minor mode.
Use this map to set additional keybindings for when Org mode is used
for a capture buffer.")

(define-minor-mode org-jira-capture-mode
  "Minor mode for org-jira to capture the description or comment"
  :lighter " Cap"
  (setq-local
   header-line-format
   (substitute-command-keys
    "\\<org-jira-capture-mode-map>Capture buffer.  Finish \
`\\[org-jira-capture-finalize]', abort `\\[org-jira-capture-kill]'.")))


(defvar org-jira-capture-window-config-cache nil
  "Cache the window configuration for restore after finalize")

(defvar org-jira-capture-finalize-hook nil
  "Hook when doing finalize")

(defun org-jira-capture (callback)
  (when org-jira-capture-mode
    (error "Have another org-jira-capture"))

  (setq org-jira-capture-window-config-cache (current-window-configuration))
  (setq org-jira-capture-finalize-hook callback)

  (org-switch-to-buffer-other-window (get-buffer-create "*ORG-JIRA-CAPTURE*"))
  (erase-buffer)
  (org-mode)
  (goto-char (point-min))
  (org-jira-capture-mode 1))

(defun org-jira-capture-finalize ()
  (interactive)
  (unless org-jira-capture-mode
    (error "This does not seem to be a capture buffer for Org mode"))
  (let ((content (buffer-string)))
    (kill-buffer (current-buffer))
    (set-window-configuration org-jira-capture-window-config-cache)
    (setq window-config-cache nil)
    (let ((fun org-jira-capture-finalize-hook))
      (setq org-jira-capture-finalize-hook nil)
      (funcall fun content))))

(defun org-jira-capture-kill ()
  (set-window-configuration org-jira-capture-window-config-cache)
  (setq org-jira-capture-window-config-cache nil)
  (setq org-jira-capture-finalize-hook nil))

(provide 'org-jira-capture)
