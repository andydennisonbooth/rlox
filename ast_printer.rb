
class AstPrinter
  def print(expr)
    expr.accept(self)
  end

  def visit_binary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_grouping_expr(expr)
    parenthesize('group', expr.expression)
  end

  def visit_literal_expr(expr)
    expr.value || 'nil'
  end

  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  private

  def parenthesize(name, *exprs)
    "(#{name} #{exprs.map { |expr| expr.accept(self) }.join(' ')})"
  end
end

if __FILE__ == $0
  require_relative 'expr'
  require_relative 'token'
  puts AstPrinter.new.print(
    Binary.new(
      Unary.new(
        Token.new(:minus, '-', nil, 1),
        Literal.new(123)
      ),
      Token.new(:star, '*', nil, 1),
      Grouping.new(
        Literal.new(45.67)
      )
    )
  )
end
