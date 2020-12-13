use "debug"
use "files"

actor Main
  new create(env: Env) =>
    try
      let program = parse_program(env.root as AmbientAuth)
      program.run_until_repeated()
      env.out.print(program.accumulator.string())
    end

  fun parse_program(auth: AmbientAuth): Program =>
    let input = Program
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          input.add_instruction(Instruction(consume line))
        end
      end
      input
    else
      input
    end


class Program
  var accumulator: ISize = 0
  var instruction_index: USize = 0
  var instructions: Array[Instruction] = Array[Instruction](605)

  new create() =>
    None

  fun size(): USize =>
    instructions.size()

  fun ref add_instruction(instr: Instruction) =>
    instructions.push(instr)

  fun ref run_until_repeated() =>
    try
      while true do
        Debug.out("accumulator: " + accumulator.string())
        Debug.out("instruction_index: " + instruction_index.string() + "\n")

        let next = instructions(instruction_index)?

        Debug.out("next: " + next.string())

        if next.has_run_once then
          break
        end

        match next.operation
          | "acc" =>
            accumulator = accumulator + next.argument
          | "jmp" =>
            instruction_index = (instruction_index + (next.argument - 1).usize())
        end

        instruction_index = instruction_index + 1

        next.has_run_once = true
      end
    end


class Instruction
  var operation: String = ""
  var argument: ISize = 0
  var has_run_once: Bool = false

  new create(line: String) =>
    try
      let split = line.split(" ")
      operation = split(0)?

      var num = split(1)?
      // XXX: Blegh. Annoying that +12 won't parse as an isize
      if num(0)? == 43 then
        num = num.substring(1)
      end
      argument = num.isize()?
    end

  fun string(): String =>
    "Instruction(" + operation + ", " + argument.string() + ")"

