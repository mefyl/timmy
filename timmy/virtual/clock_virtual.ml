let cb : (Timmy.Time.t -> unit) ref = ref (fun _ -> ())
let set_callback v = cb := v
let current = ref Timmy.Time.epoch

let forward span =
  (current := Timmy.Time.(!current + span));
  !cb !current

let get () = !current
