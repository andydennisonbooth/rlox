require_relative 'ast_class_builder'

build_ast_classes(
  'stmt',
  Block: %i[statements],
  Expression: %i[expression],
  If: %i[condition then_branch else_branch],
  Print: %i[expression],
  Var: %i[name initializer],
  While: %i[condition body]
)
