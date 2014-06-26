require 'active_record/attribute_set/builder'

module ActiveRecord
  class AttributeSet # :nodoc:
    delegate :[], :[]=, to: :attributes
    delegate :keys, to: :initialized_attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def values_before_type_cast
      attributes.each_with_object({}) { |(k, v), h| h[k] = v.value_before_type_cast }
    end

    def to_hash
      initialized_attributes.each_with_object({}) { |(k, v), h| h[k] = v.value }
    end
    alias_method :to_h, :to_hash

    def include?(name)
      attributes.include?(name) && self[name].initialized?
    end

    def fetch_value(name)
      attribute = self[name]
      if attribute.initialized? || !block_given?
        attribute.value
      else
        yield name
      end
    end

    def freeze
      @attributes.freeze
      super
    end

    def initialize_dup(_)
      @attributes = attributes.dup
      attributes.each do |key, attr|
        attributes[key] = attr.dup
      end

      super
    end

    def initialize_clone(_)
      @attributes = attributes.clone
      super
    end

    protected

    attr_reader :attributes

    private

    def initialized_attributes
      attributes.select { |_, attr| attr.initialized? }
    end
  end
end