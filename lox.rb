#! env ruby
require_relative 'scanner'

class Lox
  def self.run!
    new.run!
  end

  def run!
    if ARGV.length > 1
      puts 'Usage: rlox [script]'
      exit
    elsif ARGV.length == 1
      run_file!(ARGV.first)
    else
      run_prompt!
    end
  end

  def initialize
    @had_error = false
  end

  def run_file!(path)
    run(File.read(path))
    exit 65 if @had_error
  end

  def run_prompt!
    print '> '
    print '> ' while run(gets.chomp)
    @had_error = false
  end

  def run(source)
    Scanner.new(source, self).scan_tokens.each { |token| puts token }
  end

  def error(line, message)
    report(line, '', message)
  end

  def report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
    @had_error = true
  end
end

Lox.run!
