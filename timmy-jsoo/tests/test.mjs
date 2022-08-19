import caml from "./test.bc.js"
import assert from "assert"

const midnight = caml.make(0, 0, 0)
const noon = caml.make(12, 0, 0)
assert(midnight.hours === 0)
assert(midnight.minutes === undefined)
assert(midnight.seconds === undefined)

assert(midnight < noon, "daytime comparison failed")

try {
  const noon = caml.make(24, 0, 0)
  assert(false, "invalid daytime not rejected")
}
catch (e) {}


caml.testSuite()
