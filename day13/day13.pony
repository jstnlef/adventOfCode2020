use "debug"
use "files"


actor Main
  new create(env: Env) =>
    try
      let notes = parse_input(env.root as AmbientAuth)
      let earliest = Scheduling.find_earliest_bus(notes)
      env.out.print("Earliest Bus: " + earliest.string())
    else
      env.err.print("Unrecoverable error")
    end

  fun parse_input(auth: AmbientAuth): BusNotes =>
    let notes = BusNotes
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        let lines = file.lines()
        let start_time = lines.next()?
        notes.set_earliest_start_time((consume start_time).usize()?)

        let bus_times = lines.next()?
        notes.set_bus_times(consume bus_times)?
      end
      notes
    else
      notes
    end


primitive Scheduling
  fun find_earliest_bus(notes: BusNotes): USize =>
    var start_time: USize = notes.earliest_time
    var time: USize = start_time
    var id: USize = 0

    while id == 0 do
      time = time + 1
      for bus in notes.buses.values() do
        if bus.will_depart(time) then
          id = bus.id
          break
        end
      end
    end

    id * (time - start_time)


class BusNotes
  var earliest_time: USize = 0
  var buses: Array[Bus] = Array[Bus](10)

  new create() => None

  fun ref set_earliest_start_time(time: USize) =>
    earliest_time = time

  fun ref set_bus_times(line: String)? =>
    let bus_ids = line.split(",")

    for id in (consume bus_ids).values() do
      if id != "x" then
        buses.push(Bus(id.usize()?))
      end
    end


class Bus
  let id: USize

  new create(_id: USize) =>
    id = _id

  fun will_depart(timestamp: USize): Bool =>
    (timestamp % id) == 0
