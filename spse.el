(define-derived-mode spse2-mode
  freekbs2-knowledge-editor-mode "SPSE2"
  "Major mode for SPSE2 Knowledge Bases.
\\{spse2-mode-map}"
  (setq case-fold-search nil)
  (define-key freekbs2-knowledge-editor-mode-map "n" 'freekbs2-knowledge-editor-next-formula)
  ;; (suppress-keymap freekbs2-knowledge-editor-mode-map)
  )

