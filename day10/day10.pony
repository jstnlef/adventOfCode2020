use "collections"
use "debug"
use "files"


actor Main
  new create(env: Env) =>
    try
      let input = parse_input(env.root as AmbientAuth)

      let all_adapters = JoltCalc.use_all_adapters(input)
      env.out.print("All adapters: " + all_adapters.string())
    end

  fun parse_input(auth: AmbientAuth): Array[USize] =>
    let input = Array[USize]
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          input.push((consume line).usize()?)
        end
      end
      input
    else
      input
    end


primitive JoltCalc
  fun use_all_adapters(adapters: Array[USize]): USize =>
    let sorted_adapters = Sort[Array[USize], USize](adapters)

    var ones: USize = 0
    // The highest 1 will always be a 3
    var threes: USize = 1
    var previous: USize = 0

    for joltage in sorted_adapters.values() do
      let delta = joltage - previous

      if delta == 1 then
        ones = ones + 1
      end

      if delta == 3 then
        threes = threes + 1
      end

      previous = joltage
    end

    ones * threes
