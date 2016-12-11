module Cranky
  class Factory

    def task
      define(
        state: 'created',
        pickup_point: { lat: 44.106667, lng: -73.935833 },
        delivery_point: { lat: 44.106668, lng: -73.935834 }
      )
    end

  end
end
