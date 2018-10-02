require_relative 'lox_runtime_error'
require_relative 'environment'

class Interpreter
  def initialize(lox)
    @lox = lox

    @environment = Environment.new
  end

  def interpret!(statements)
    statements.each { |statement| execute(statement) }
  rescue LoxRuntimeError => e
    @lox.runtime_error(e)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_logical_expr(expr)
    left = evaluate(expr.left)

    if expr.operator.type == :or
      return left if left
    else
      return left unless left
    end

    evaluate(expr.right)
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

  def visit_variable_expr(expr)
    @environment.get(expr.name)
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
    nil
  end

  def visit_if_stmt(stmt)
    if evaluate(stmt.condition)
      execute(stmt.then_branch)
    elsif !stmt.else_branch.nil?
      execute(stmt.else_branch)
    end

    nil
  end

  def visit_print_stmt(stmt)
    puts evaluate(stmt.expression)
  end

  def visit_var_stmt(stmt)
    value = stmt.initializer.nil? ? nil : evaluate(stmt.initializer)
    @environment.define(stmt.name.lexeme, value)
    nil
  end

  def visit_while_stmt(stmt)
    execute(stmt.body) while evaluate(stmt.condition)
    nil
  end

  def visit_assign_expr(expr)
    value = evaluate(expr.value)
    @environment.assign(expr.name, value)
    value
  end

  private

  def evaluate(expr)
    expr.accept(self)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def execute_block(statements, environment)
    previous = @environment
    @environment = environment

    statements.each { |statement| execute(statement) }
  ensure
    @environment = previous
  end

  def visit_block_stmt(stmt)
    execute_block(stmt.statements, Environment.new(@environment))
    nil
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
