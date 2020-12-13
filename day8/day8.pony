use "collections"
use "debug"
use "files"

actor Main
  new create(env: Env) =>
    try
      let program = parse_program(env.root as AmbientAuth)
      program.run_until_repeated()
      env.out.print("Accumulator after first repeat: " + program.accumulator.string())


      let possible_changes = program.find_nop_and_jmps()
      for instr in possible_changes.values() do
        program.reset()
        if program.run_with_swapped_inst(instr) then
          break
        end
      end
      env.out.print("Accumulator after program terminates: " + program.accumulator.string())
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
        let next = instructions(instruction_index)?

        if next.has_run_once then
          break
        end

        _process_instruction(next)
      end
    end

  // Run the program with the instruction at the index specified swapped. Returns true if this
  // program now terminates.
  fun ref run_with_swapped_inst(index: USize): Bool =>
     try
      while true do
        if instruction_index >= instructions.size() then
          return true
        end

        var next = instructions(instruction_index)?

        if index == instruction_index then
          next = next.swapped()
        end

        // We've run this instruction before so we must be repeating
        if next.has_run_once then
          return false
        end

        _process_instruction(next)
      end
    end
    false

  fun ref _process_instruction(instr: Instruction) =>
    match instr.operation
      | "acc" =>
        accumulator = accumulator + instr.argument
      | "jmp" =>
        instruction_index = (instruction_index + (instr.argument - 1).usize())
    end

    instruction_index = instruction_index + 1
    instr.has_run_once = true

  // Return an array of indexes representing the locations of the nops and jmps.
  fun ref find_nop_and_jmps(): Array[USize] =>
    let locations = Array[USize](300)
    for i in Range(0, instructions.size()) do
      try
        let instruction = instructions(i)?
        if (instruction.operation == "jmp") or (instruction.operation == "nop") then
          locations.push(i)
        end
      end
    end
    locations


  fun ref reset() =>
    accumulator = 0
    instruction_index = 0
    for instr in instructions.values() do
      instr.has_run_once = false
      instr.is_swapped = false
    end


class Instruction
  var operation: String = ""
  var argument: ISize = 0
  var has_run_once: Bool = false
  var is_swapped: Bool = false

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

  new from_args(_operation: String, _argument: ISize, _has_run_once: Bool, _is_swapped: Bool) =>
    operation = _operation
    argument = _argument
    has_run_once = _has_run_once
    is_swapped = _is_swapped

  fun string(): String =>
    "Instruction(" + operation + ", " + argument.string() + ")"

  fun swapped(): Instruction =>
    let new_op = match operation
      | "nop" => "jmp"
      | "jmp" => "nop"
      else operation
    end
    Instruction.from_args(new_op, argument, has_run_once, true)
