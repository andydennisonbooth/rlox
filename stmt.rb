require_relative 'ast_class_builder'

build_ast_classes(
  'stmt',
  Expression: %i[expression],
  Print: %i[expression],
  Var: %i[name initializer]
)
