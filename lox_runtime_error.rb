class LoxRuntimeError < RuntimeError
  def initialize(token, message)
    super(message)
    @token = token
  end
end
