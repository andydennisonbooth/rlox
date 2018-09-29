#! env ruby
require_relative 'scanner'
require_relative 'parser'
require_relative 'ast_printer'
require_relative 'interpreter'

class Lox
  def self.run!(args)
    new.run!(args)
  end

  def run!(args)
    if args.length > 1
      puts 'Usage: rlox [script]'
      exit
    elsif args.length == 1
      run_file!(args.first)
    else
      run_prompt!
    end
  end

  def initialize
    @had_error = false
    @had_runtime_error = false

    @interpreter = Interpreter.new
  end

  def run_file!(path)
    run(File.read(path))
    exit 65 if @had_error
    exit 70 if @had_runtime_error
  end

  def run_prompt!
    loop do
      print '> '
      run(gets.chomp)
      @had_error = false
    end
  end

  def run(source)
    tokens = Scanner.new(self, source).scan_tokens
    expression = Parser.new(self, tokens).parse

    return if @had_error

    @interpreter.interpret!(expression)
  end

  def error(line, message)
    report(line, '', message)
  end

  def token_error(token, message)
    if token.type == :eof
      report(token.line, 'at end', message)
    else
      report(token.line, " at '#{token.lexeme}'", message)
    end
  end

  def report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
    @had_error = true
  end

  def runtime_error(error)
    puts "#{error.message}\n[line #{error.token.line}]"
    @had_runtime_error = true
  end
end

Lox.run!(ARGV)
