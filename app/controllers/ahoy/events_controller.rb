module Ahoy
  class EventsController < Ahoy::BaseController
    def create
      events =
        begin
          ActiveSupport::JSON.decode(request.body.read)
        rescue ActiveSupport::JSON.parse_error
          # do nothing
          []
        end

      events.each do |event|
        time = Time.zone.parse(event["time"]) rescue nil

        options = {
          id: event["id"],
          time: time
        }
        ahoy.track event["name"], event["properties"], options
      end
      render json: {}
    end
  end
end
