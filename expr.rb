require_relative 'ast_class_builder'

build_ast_classes(
  'expr',
  Assign: %i[name value],
  Binary: %i[left operator right],
  Grouping: %i[expression],
  Literal: %i[value],
  Logical: %i[left operator right],
  Unary: %i[operator right],
  Variable: %i[name]
)
