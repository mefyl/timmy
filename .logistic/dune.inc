(env
 (dev
  (flags
   (:standard -warn-error -A -warn-error +partial-match)))
 (release
  (flags
   (:standard -warn-error +A -w +unused-constructor))))
