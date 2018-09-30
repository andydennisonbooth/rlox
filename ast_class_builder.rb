def build_ast_classes(suffix, params)
  params.each do |name, args|
    klass = Class.new(Struct.new(*args))
    klass.send(:define_method, :accept) do |visitor|
      visitor.send(:"visit_#{name.downcase}_#{suffix}", self)
    end
    Object.const_set(name, klass)
  end
end
