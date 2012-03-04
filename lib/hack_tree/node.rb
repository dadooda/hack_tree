module HackTree
  module Node
    # Node (group/hack) regexp without delimiters.
    NAME_REGEXP = /[a-zA-Z_]\w*/

    # Node names which can't be used due to serious reasons.
    FORBIDDEN_NAMES = [
      :inspect,
      :method_missing,
      :to_s,
    ]
  end
end
