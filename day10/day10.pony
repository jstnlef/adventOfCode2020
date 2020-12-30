use "collections"
use "debug"
use "files"


actor Main
  new create(env: Env) =>
    try
      let input = parse_input(env.root as AmbientAuth)

      let all_adapters = JoltCalc.use_all_adapters(input)
      env.out.print("All adapters: " + all_adapters.string())

      let arrangements = JoltCalc.all_arrangements(input)?
      env.out.print("All arrangments: " + arrangements.string())
    else
      env.err.print("There was a bug")
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
      let sorted = Sort[Array[USize], USize](input)
      sorted.insert(0, 0)?
      sorted.push(sorted(sorted.size() - 1)? + 3)
      sorted
    else
      input
    end


primitive JoltCalc
  fun use_all_adapters(adapters: Array[USize]): USize =>
    var ones: USize = 0
    // The highest 1 will always be a 3
    var threes: USize = 0
    var previous: USize = 0

    for joltage in adapters.values() do
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

  fun all_arrangements(adapters: Array[USize]): USize? =>
    let dp = Array[USize](adapters.size())
    dp.push(1)
    for i in Range(1, adapters.size()) do
      dp.push(0)
      for j in Range(i, -1, -1) do
        if (adapters(i)? - adapters(j)?) > 3 then
          break
        end
        let n = dp(i)?
        let m = dp(j)?
        dp.update(i, n + m)?
      end
    end
    dp(dp.size() - 1)?
