import _ from "lodash"
import assert from "assert"
import { Daytime } from "../bin/timmy.js"

const midnight = new Daytime()
assert(midnight.hours === 0)
assert(midnight.minutes === 0)
assert(midnight.seconds === 0)
assert(_.isEqual(Object.getOwnPropertyNames(midnight), ["hours"]))
const noon = new Daytime (12, 0, 0)
assert(noon.hours === 12)
assert(noon.minutes === 0)
assert(noon.seconds === 0)
assert(_.isEqual(Object.getOwnPropertyNames(noon), ["hours"]))
const time = new Daytime (13, 14, 15)
assert(time.hours === 13)
assert(time.minutes === 14)
assert(time.seconds === 15)
assert(_.isEqual(Object.getOwnPropertyNames(time), ["hours", "minutes", "seconds"]))

assert(midnight < noon, "daytime comparison failed")

assert.throws(() => new Daytime(24, 0, 0));
