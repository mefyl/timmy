/// A time within a specific day, between 00:00 and 23:59:59.
export class Daytime {
  /// Create a Daytime. Components default to 0.
  constructor (hours?: number, minutes?: number, seconds?: number);
  /// The hours component.
  readonly hours: number;
  /// The minutes component.
  readonly minutes: number;
  /// The seconds component.
  readonly seconds: number;
}
