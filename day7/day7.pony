use "collections"
use "debug"
use "files"
use "itertools"
use "regex"


actor Main
  new create(env: Env) =>
    try
      let rules = parse_input(env.root as AmbientAuth)
      env.out.print(rules.bags_that_can_contain_target("shiny gold").string())
      env.out.print(rules.number_of_bags("shiny gold").string())
    end

  fun parse_input(auth: AmbientAuth): Rules =>
    let input = Rules
    try
      let path = FilePath(auth, "input.txt")?
      with file = File(path) do
        for line in file.lines() do
          input.add_rule(Rule(consume line))
        end
      end
      input
    else
      input
    end


// Directed graph of rules
class Rules
  let inner: Map[Bag, Array[BagWithAmount]]

  new create() =>
    inner = Map[Bag, Array[BagWithAmount]](600)

  fun ref add_rule(rule: Rule) =>
    inner.insert(rule.bag, rule.contained)

  fun number_of_bags(target_bag: Bag): USize =>
    0

  fun bags_that_can_contain_target(target_bag: Bag): USize =>
    var count: USize = 0

    for bag in inner.keys() do
      if (bag != target_bag) and _find_target(bag, target_bag) then
        count = count + 1
      end
    end

    count

  fun _find_target(start: Bag, target: Bag): Bool =>
    let discovered = Set[Bag]
    let queue = List[Bag]
    queue.push(start)

    while queue.size() > 0 do
      try
        let bag = queue.shift()?

        if bag == target then
          return true
        end

        for neighbour in inner(bag)?.values() do
          let neighbour_bag = neighbour.bag
          if not discovered.contains(neighbour_bag) then
            discovered.set(neighbour_bag)
            queue.push(neighbour_bag)
          end
        end
      end
    end
    false


class Rule
  var bag: Bag = ""
  var contained: Array[BagWithAmount] = Array[BagWithAmount](5)

  new create(line: String) =>
    let s = line.split_by(" bags contain ")
    try
      bag = s(0)?
      contained = Iter[String](s(1)?.split_by(", ").values())
        .map[BagWithAmount]({(s)? => BagWithAmount(s)?})
        .collect(Array[BagWithAmount](5))
    end



type Bag is String

class BagWithAmount
  let regex: Regex = Regex("^(\\d+) ([\\w ]+) (bags?\\.?)$")?

  var number: USize = 0
  var bag: Bag = ""

  new create(line: String)? =>
    let matched = regex(line)?
    number = matched(1)?.usize()?
    bag = matched(2)?
