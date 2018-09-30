require_relative 'ast_class_builder'

build_ast_classes(
  'expr',
  Binary: %i[left operator right],
  Grouping: %i[expression],
  Literal: %i[value],
  Unary: %i[operator right],
  Variable: %i[name]
)
