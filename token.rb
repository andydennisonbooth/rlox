
class Token < Struct.new(:type, :lexeme, :literal, :line)
  def to_s
    [type, lexeme, literal, line].join(' ')
  end
end
