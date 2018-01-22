module ConditionalValidations
  attr_accessor :validated_scopes

  def method_missing(method_sym, *arguments, &block)
    if m = method_sym.to_s.match(/^validate_if_(?<attribute>.*)\?$/)
      validated_scopes.kind_of?(Array) && validated_scopes.include?(m[:attribute].to_sym)
    else
      super
    end
  end
end