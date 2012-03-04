;;; org-defprop.el --- 
;; 
;; Filename: org-defprop.el
;; Description: Define Org Mode variables and settings with a corresponding #+KEYWORDS setting.
;; Author: Neil Smithline
;; Maintainer: I guess me :-)
;; Copyright (C) 2012, Neil Smithline, all rights reserved.
;; Created: Sun Mar  4 13:44:18 2012 (-0500)
;; Version: 1.0-pre1
;; Last-Updated: Sun Mar  4 13:44:18 2012 (-0500)
;;           By: Neil Smithline
;;     Update #: 0
;; URL: 
;; Keywords: org-mode, emacs, gnu-emacs
;; Compatibility: I think all Emacs.
;; 
;; Features that might be required by this library:
;;
;;   custom
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; org-defprop.el is intended to be used with `org-mode' code as well
;; as in extesions to `org-mode'. It two externally usable special
;; forms (ie: macros): `deforgsetting' and `deforgprop'.
;;
;; The special forms are used to declare `org-mode' settings (eg:
;; `defcustom') and properties (eg: `defvar'). Besides replacing the
;; `defcustom' or `defvar' declarations, a #+KEYWORDS keyword is
;; defined and the variable documentation is modified to describe the
;; keyword.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;;      Initial version, 1.0-pre1, Sun Mar  4 13:44:18 2012 (-0500)
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Org setting (ie: `defcustom').
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst deforgsetting-set-message
  "This option can aso be set in a file with a #+KEYWORDS
line such as:")

(defmacro deforgsetting (symbol var option-string value doc &rest args)
  "Create an Org property SYMBOL, customizable via VAR.
SYMBOL can be set with the #+KEYWORDS option OPTION-STRING.
SYMBOL, VAR, VALUE, and ARGS will be passed to `defcustom' as-is.
DOC will be modified to include information about using the
option OPTION-STRING to modify a buffer-local setting."
  (let* ((propname      (concat  (symbol-name symbol)))
         (keyword       (intern (concat ":" propname)))
         (existing      (assoc keyword org-export-plist-vars))
         (new-prop-list (list keyword option-string var)))
    `(if ',existing
         (assert (equal ',existing ',new-prop-list) nil
                 "Illegal remapping of ORG keyword: %s." ',new-prop-list)
       (defcustom ,symbol ,value (format
                                  "%s\n\n%s\n    #+KEYWORDS: %s:%s"
                                  ,doc
                                  ,deforgsetting-set-message
                                  ,propname
                                  ,value)
         ,@args)
       (setq org-export-plist-vars
             (cons ',new-prop-list org-export-plist-vars)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Org property backed by a non-customizable variable (ie: `defvar').
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst deforgprop-set-message
  "It does not make sense to set this globally. It is best set
with a #+KEYWORDS line in a file such as:")

(defmacro deforgprop (symbol var option-string value doc)
  "Create an Org property SYMBOL, defaulting to VAR.
SYMBOL can be set with the #+KEYWORDS option OPTION-STRING.
SYMBOL will be buffer-local with a default value VALUE. SYMBOL's
documentation will consist of DOC followed by a statement
recommending that SYMBOL should only be set in a buffer using
OPTION-STRING."
  (let* ((propname      (concat  (symbol-name symbol)))
         (keyword       (intern (concat ":" propname)))
         (existing      (assoc keyword org-export-plist-vars))
         (new-prop-list (list keyword option-string var)))
    `(if ',existing
         (assert (equal ',existing ',new-prop-list) nil
                 "Illegal remapping of ORG keyword: %s." ',new-prop-list)
       (defvar ,var ,value
         (format
          "%s\n\n%s\n    #+KEYWORDS: %s:%s"
          ,doc
          ,deforgprop-set-message
          ,propname
          ,value))
       (make-variable-buffer-local ',var)
       (setq-default ,var ,value)
       (setq org-export-plist-vars
             (cons ',new-prop-list org-export-plist-vars)))))

(provide 'org-defprop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org-defprop.el ends here
