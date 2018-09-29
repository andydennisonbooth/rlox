require_relative 'lox_runtime_error'

class Interpreter
  def interpret!(expr)
    puts evaluate(expr)
  rescue LoxRuntimeError => e
    @lox.runtime_error(e)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when :minus
      check_number_operand!(expr.operator, right)
      -right.to_f
    when :bang then !right
    end
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    # Comparison operators
    when :greater
      check_number_operands!(expr.operator, left, right)
      left.to_f > right.to_f
    when :greater_equal
      check_number_operands!(expr.operator, left, right)
      left.to_f >= right.to_f
    when :less
      check_number_operands!(expr.operator, left, right)
      left.to_f < right.to_f
    when :less_equal
      check_number_operands!(expr.operator, left, right)
      left.to_f <= right.to_f

    # Equality operators
    when :bang_equal then !equal?(left, right)
    when :equal_equal then equal?(left, right)

    # Arithmetic operators
    when :minus
      check_number_operands!(expr.operator, left, right)
      left.to_f - right.to_f
    when :slash
      check_number_operands!(expr.operator, left, right)
      left.to_f / right.to_f
    when :star
      check_number_operands!(expr.operator, left, right)
      left.to_f * right.to_f
    when :plus
      return left.to_f + right.to_f if [left, right].all? { |value| value.is_a?(Float) }
      return left.to_s + right.to_s if [left, right].all? { |value| value.is_a?(String) }
      raise LoxRuntimeError.new(expr.operator, 'Operands must be two numbers or two strings.')
    end
  end

  private

  def evaluate(expr)
    expr.accept(self)
  end

  def equal?(left, right)
    return true if [left, right].all?(&:nil?)
    return false if left.nil?
    left == right
  end

  def check_number_operand!(operator, operand)
    return if operand.is_a?(Float)
    raise LoxRuntimeError.new(operator, 'Operand must be a number.')
  end

  def check_number_operands!(operator, left, right)
    return if [left, right].all? { |value| value.is_a?(Float) }
    raise LoxRuntimeError.new(operator, 'Operands must be numbers.')
  end
end
