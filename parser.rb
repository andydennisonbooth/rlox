
class Parser < Struct.new(:tokens)
  private

  def expression
    equality
  end

  def equality
    expr = comparison

    while match?(:bang_equal, :equal_equal)

    end
  end
end
