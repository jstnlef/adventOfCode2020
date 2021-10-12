use "debug"
use "files"
use "itertools"


actor Main
  new create(env: Env) =>
    let auth = try
      env.root as AmbientAuth
    else
      env.err.print("env.root must be AmbientAuth")
      return
    end

    let notes = parse_input(auth)
    try
      let earliest = Scheduling.find_earliest_bus(notes)
      env.out.print("Earliest Bus: " + earliest.string())

      let timestamp = Scheduling.find_subsequent_departures(notes)?
      env.out.print("Subsequent departures at: " + timestamp.string())
    else
      env.err.print("Unrecoverable error")
    end

  fun parse_input(auth: AmbientAuth): BusNotes =>
    let notes = BusNotes
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      let lines = file.lines()
      let start_time = lines.next()?
      notes.set_earliest_start_time((consume start_time).u64()?)

      let bus_times = lines.next()?
      notes.set_bus_times(consume bus_times)?
    end
    notes


primitive Scheduling
  fun find_earliest_bus(notes: BusNotes): Timestamp =>
    var start_time: Timestamp = notes.earliest_time
    var time: Timestamp = start_time - 1
    var id: I64 = 0

    while id == 0 do
      time = time + 1
      for bus in notes.buses.values() do
        if bus.will_depart(time) then
          id = bus.id
          break
        end
      end
    end

    id.u64() * (time - start_time)

  fun find_subsequent_departures(notes: BusNotes): Timestamp? =>
    let offsets = Iter[Bus](notes.buses.values()).map[I64]({ (b) =>
      b.id - b.minute_offset.i64()
    }).collect(Array[I64])

    let ids = Iter[Bus](notes.buses.values()).map[I64]({(b) => b.id}).collect(Array[I64])

    Math.chinese_remainder(offsets, ids)?.u64()


primitive Math
  fun extended_gcd(a: I64, b: I64): (I64, I64, I64) =>
    if a == 0 then
      (b, 0, 1)
    else
      (let gcd, let x, let y) = extended_gcd(b % a, a)
      (gcd, y - ((b / a) * x), x)
    end

  fun modular_inverse(x: I64, n: I64): I64? =>
    (let g, let x1, let _) = extended_gcd(x, n)
    if g == 1 then
      ((x1 % n) + n) % n
    else
      error
    end

  fun chinese_remainder(residues: Array[I64], modulii: Array[I64]): I64? =>
    let prod = Iter[I64](modulii.values())
      .fold[I64](1, {(prod, x) => prod * x })

    var sum: I64 = 0

    for (residue, modulus) in Iter[I64](residues.values()).zip[I64](modulii.values()) do
      let p: I64 = prod / modulus
      sum = sum + (residue * modular_inverse(p, modulus)? * p)
    end

    sum % prod


type Timestamp is U64

class BusNotes
  var earliest_time: Timestamp = 0
  var buses: Array[Bus] = Array[Bus](10)

  new create() => None

  fun ref set_earliest_start_time(time: Timestamp) =>
    earliest_time = time

  fun ref set_bus_times(line: String)? =>
    let bus_ids = line.split(",")

    for (i, id) in (consume bus_ids).pairs() do
      if id != "x" then
        buses.push(Bus(id.i64()?, i.u64()))
      end
    end


class Bus
  let id: I64
  let minute_offset: Timestamp

  new create(_id: I64, _offset: Timestamp) =>
    id = _id
    minute_offset = _offset

  fun will_depart(timestamp: Timestamp): Bool =>
    (timestamp % id.u64()) == 0
