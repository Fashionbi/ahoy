module Ahoy
  module Stores
    class ActiveRecordTokenStore < BaseStore
      def track_visit(options, &block)
        visit =
          visit_model.new do |v|
            v.visit_token = ahoy.visit_token
            v.visitor_token = ahoy.visitor_token
            v.user = user if v.respond_to?(:user=)
            v.created_at = options[:started_at]
          end

        set_visit_properties(visit)

        yield(visit) if block_given?

        begin
          visit.save!
          geocode(visit)
        rescue *unique_exception_classes
          # do nothing
        end
      end

      def track_event(name, properties, options, &block)

        event =
          event_model.new do |e|
            e.visit_id = visit.try(:id)
            e.user = user
            e.name = name
            e.properties = properties
            e.time = options[:time]
          end

        yield(event) if block_given?

        event.save!

      end

      def visit
        @visit ||= visit_model.where(visit_token: ahoy.visit_token).first if ahoy.visit_token
      end

      def exclude?
        (!Ahoy.track_bots && bot?) ||
          (
            if Ahoy.exclude_method
              warn "[DEPRECATION] Ahoy.exclude_method is deprecated - use exclude? instead"
              if Ahoy.exclude_method.arity == 1
                Ahoy.exclude_method.call(controller)
              else
                Ahoy.exclude_method.call(controller, request)
              end
            else
              false
            end
          )
      end

      def user
        @user ||= begin
          user_method = Ahoy.user_method
          if user_method.respond_to?(:call)
            user_method.call(controller)
          elsif user_method
            controller.send(user_method)
          else
            super
          end
        end
      end

      protected

      def visit_model
        Ahoy.visit_model || ::Visit
      end

      def event_model
        ::Ahoy::Event
      end
    end
  end
end
