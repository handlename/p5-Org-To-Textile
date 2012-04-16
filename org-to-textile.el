(defvar org-to-textile-buffer "*org-to-textile*")
(defvar org-to-textile-command "org2textile.pl")

(defun org-to-textile-process-filter (process string)
  (if (not (buffer-live-p (get-buffer org-to-textile-buffer)))
      (get-buffer-create org-to-textile-buffer))
  (with-current-buffer org-to-textile-buffer
    (insert string)))

(defun org-to-textile-region (start end)
  (set-process-filter
   (let ((process-connection-type nil))
     (start-process "org-to-textile" nil org-to-textile-command (buffer-substring start end)))
   'org-to-textile-process-filter))

(defun org-to-textile ()
  (interactive)
  (if (not (buffer-live-p (get-buffer org-to-textile-buffer)))
      (get-buffer-create org-to-textile-buffer))
  (with-current-buffer org-to-textile-buffer (erase-buffer))
  (if (and transient-mark-mode mark-active)
      (org-to-textile-region (region-beginning) (region-end))
    (org-to-textile-region (point-min) (point-max)))
  (switch-to-buffer-other-window org-to-textile-buffer))

(provide 'org-to-textile)
