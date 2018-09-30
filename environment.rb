require_relative 'lox_runtime_error'

class Environment
  def initialize(enclosing = nil)
    @enclosing = enclosing

    @values = {}
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    return @values[name.lexeme] if @values.include?(name.lexeme)
    return @enclosing.get(name) unless @enclosing.nil?

    raise LoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  def assign(name, value)
    if @values.include?(name.lexeme)
      @values[name.lexeme] = value
      return
    end

    unless @enclosing.nil?
      @enclosing.assign(name, value)
      return
    end

    raise LoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end
end
