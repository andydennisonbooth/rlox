require_relative 'expr'

class Parser
  def initialize(lox, tokens)
    @lox = lox
    @tokens = tokens

    @current = 0
  end

  def parse
    expression
  rescue ParseError
    nil
  end

  private

  def expression
    equality
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
