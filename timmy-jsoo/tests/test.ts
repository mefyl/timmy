import assert from "assert"
import { Daytime } from "../bin/timmy.js"

const midnight = new Daytime()
const noon = new Daytime (12, 0, 0)
assert(midnight.hours === 0)
assert(midnight.minutes === undefined)
assert(midnight.seconds === undefined)

assert(midnight < noon, "daytime comparison failed")

try {
  new Daytime(24, 0, 0)
  assert(false, "invalid daytime not rejected")
}
catch (e) {}
