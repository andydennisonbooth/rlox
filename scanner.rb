require_relative 'token'

class Scanner
  KEYWORDS = %w[
    and
    class
    else
    false
    for
    fun
    if
    nil
    or
    print
    return
    super
    this
    true
    var
    while
  ].freeze
    # .each_with_object({}) { |k, o| o[k] = k.to_sym }.freeze

  def initialize(source, lox)
    @lox = lox
    @source = source
    @start = 0
    @current = 0
    @line = 1
    @tokens = []
  end

  def scan_tokens
    until at_end?
      @start = @current
      scan_token!
    end

    @tokens << Token.new(:eof, '', nil, @line)
  end

  private

  def scan_token!
    char = advance!
    case char

    # Single char lexemes
    when ?( then add_token!(:left_paren)
    when ?) then add_token!(:right_paren)
    when ?{ then add_token!(:left_brace)
    when ?} then add_token!(:right_brace)
    when ?, then add_token!(:comma)
    when ?. then add_token!(:dot)
    when ?- then add_token!(:minus)
    when ?+ then add_token!(:plus)
    when ?; then add_token!(:semicolon)
    when ?* then add_token!(:star)

    # Possible double char lexemes
    when ?! then add_token!(match?(?=) ? :bang_equal : :bang)
    when ?= then add_token!(match?(?=) ? :equal_equal : :equal)
    when ?< then add_token!(match?(?=) ? :less_equal : :less)
    when ?> then add_token!(match?(?=) ? :greater_equal : :greater)

    # Slashes
    when ?/
      if match?(?/)
        advance! while peek != ?\n && !at_end?
      else
        add_token!(:slash)
      end

    # Whitespace
    when ' ', ?\r, ?\t then nop!
    when ?\n then @line += 1

    when ?" then string!

    else
      return number! if digit?(char)
      return identifier! if alpha?(char)
      @lox.error(@line, 'Unexpected character.')
    end
  end

  def identifier!
    advance! while alphanumeric?(peek)
    keyword = @source[@start...@current]
    add_token!(KEYWORDS.include?(keyword) ? keyword.to_sym : :identifier)
  end

  def number!
    advance! while digit?(peek)

    if peek == ?. && digit?(peek_next)
      advance!
      advance! while digit?(peek)
    end

    add_token!(:number, @source[@start...@current].to_f)
  end

  def string!
    while peek != ?" && !at_end?
      @line += 1 if peek == ?\n
      advance!
    end

    return @lox.error(@line, "Unterminated string.") if at_end?

    advance!

    add_token!(:string, @source[(@start + 1)...(@current - 1)])
  end

  def digit?(char)
    (?0..?9).cover?(char)
  end

  def match?(expected)
    return false if at_end?
    return false if @source[@current] != expected

    @current += 1
    true
  end

  def peek
    return ?\0 if at_end?
    @source[@current]
  end

  def peek_next
    return ?0 if @current + 1 >= source.length
    @source[@current + 1]
  end

  def alpha?(char)
    (?a..?z).cover?(char) || (?A..?Z).cover?(char) || char == ?_
  end

  def alphanumeric?(char)
    alpha?(char) || digit?(char)
  end

  def advance!
    @current += 1
    @source[@current - 1]
  end

  def add_token!(type, literal = nil)
    @tokens << Token.new(type, @source[@start...@current], literal, @line)
  end

  def at_end?
    @current >= @source.length
  end

  def nop!; end
end
