let now () = Clock_virtual.get ()
let timezone_local = Timmy.Timezone.utc
let today () = Timmy.Date.of_time ~timezone:timezone_local @@ now ()
