module Ahoy
  module Model
    def visitable(name = nil, options = {})
      if name.is_a?(Hash)
        name = nil
        options = name
      end
      name ||= :visit
      class_eval do
        belongs_to name, options
        before_create :set_visit
      end
      class_eval %{
        def set_visit
          self.#{name} ||= RequestStore.store[:ahoy].try(:visit)
        end
      }
    end
  end
end
