let current = ref Timmy.Time.epoch
let forward span = current := Timmy.Time.(!current + span)
let get () = !current
