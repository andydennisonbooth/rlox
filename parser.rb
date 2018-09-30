require_relative 'expr'
require_relative 'stmt'

class Parser
  def initialize(lox, tokens)
    @lox = lox
    @tokens = tokens

    @current = 0
  end

  def parse
    statements = []
    statements << declaration until at_end?
    statements
  end

  private

  def expression
    assignment
  end

  def statement
    return if_statement if match?(:if)
    return print_statement if match?(:print)
    return Block.new(block) if match?(:left_brace)
    expression_statement
  end

  def declaration
    return var_declaration if match?(:var)
    statement
  rescue ParseError
    synchronize!
    nil
  end

  def if_statement
    consume!(:left_paren, "Expect '(' after 'if'.")
    condition = expression
    consume!(:right_paren, "Expect ')' after if condition.")

    then_branch = statement
    else_branch = match?(:else) ? statement : nil

    If.new(condition, then_branch, else_branch)
  end

  def var_declaration
    name = consume!(:identifier, 'Expect variable name.')
    initializer = match?(:equal) ? expression : nil
    consume!(:semicolon, "Expect ';' after variable declaration.")
    Var.new(name, initializer)
  end

  def print_statement
    value = expression
    consume!(:semicolon, "Expect ';' after value.")
    Print.new(value)
  end

  def expression_statement
    expr = expression
    consume!(:semicolon, "Expect ';' after expression.")
    Expression.new(expr)
  end

  def block
    statements = []

    statements << declaration while !check?(:right_brace) && !at_end?

    consume!(:right_brace, "Expect '}' after block.")
    statements
  end

  def assignment
    expr = _or

    if match?(:equal)
      equals = previous
      value = assignment

      if expr.is_a?(Variable)
        name = expr.name
        return Assign.new(name, value)
      end

      error(equals, 'Invalid assignment target.')
    end

    expr
  end

  def _or
    expr = _and

    while match?(:or)
      operator = previous
      right = _and
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def _and
    expr = equality

    while match?(:and)
      operator = previous
      right = equality
      expr = Literal.new(expr, operator, right)
    end

    expr
  end

  def equality
    expr = comparison

    while match?(:bang_equal, :equal_equal)
      operator = previous
      right = comparison
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = addition

    while match?(:greater, :greater_equal, :less, :less_equal)
      operator = previous
      right = addition
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def addition
    expr = multiplication

    while match?(:minus, :plus)
      operator = previous
      right = multiplication
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def multiplication
    expr = unary

    while match?(:slash, :star)
      operator = previous
      right = unary
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match?(:bang, :minus)
      operator = previous
      right = unary
      return Unary.new(operator, right)
    end

    primary
  end

  def primary
    return Literal.new(false) if match?(:false)
    return Literal.new(true) if match?(:true)
    return Literal.new(nil) if match?(:nil)

    return Literal.new(previous.literal) if match?(:number, :string)

    return Variable.new(previous) if match?(:identifier)

    if match?(:left_paren)
      expr = expression
      consume!(:right_paren, "Expect ')' after expression")
      return Grouping.new(expr)
    end

    raise error(peek, 'Expect expression.')
  end

  def match?(*types)
    types.each do |type|
      if check?(type)
        advance!
        return true
      end
    end

    false
  end

  def consume!(type, message)
    return advance! if check?(type)

    raise error(peek, message)
  end

  def check?(type)
    return false if at_end?
    peek.type == type
  end

  def advance!
    @current += 1 unless at_end?
    previous
  end

  def at_end?
    peek.type == :eof
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def error(token, message)
    @lox.token_error(token, message)
    ParseError.new
  end

  def synchronize!
    advance!

    until at_end?
      return if previous.type == :semicolon
      return if %i[class fun var for if while print return].include?(peek.type)
    end

    advance!
  end

  class ParseError < RuntimeError; end
end
