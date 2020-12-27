use "collections"
use "files"

actor Main
  new create(env: Env) =>
    try
      let input_array = Array[U32](200)
      let path = FilePath(env.root as AmbientAuth, "input.txt")?
      with file = File(path) do
        let lines = file.lines()
        for line in lines do
          input_array.push((consume line).u32()?)
        end
      end

      env.out.print(find_answer(input_array).string())
    else
      env.out.print("Unable to process file")
    end

  fun find_answer(input: Array[U32]): U32 =>
    for i in input.values() do
      for j in input.values() do
        for k in input.values() do
          if (i + j + k) == 2020 then
            return i * j * k
          end
        end
      end
    end
    -1
