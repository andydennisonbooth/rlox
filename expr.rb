
{
  Binary: %i[left operator right],
  Grouping: %i[expression],
  Literal: %i[value],
  Unary: %i[operator right]
}.each do |name, args|
  klass = Class.new(Struct.new(*args))
  klass.send(:define_method, :accept) do |visitor|
    visitor.send(:"visit_#{name.downcase}_expr", self)
  end
  Object.const_set(name, klass)
end
