module Proda
  class PublicKeyNotAcceptableError < Proda::Error
    attr_reader :obj
    def initialize(obj)
      @obj = obj
    end
  end
end