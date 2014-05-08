module Factory
  extend ActiveSupport::Concern

  module ClassMethods
    def factory!(column, attributes, &block)
      instance = self.new(attributes)
      self.where(column => instance.read_attribute(column)).first || begin
        instance.save!
        block && block.call
        instance
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
