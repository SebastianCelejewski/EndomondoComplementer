module EndomondoComplementer

	class TrackPoint

		attr_reader :lat
		attr_reader :lon
		attr_accessor :time

		def initialize (lat, lon, time)
			@lat = lat
			@lon = lon
			@time = time
		end

		def distance_to other_point
			lat_distance = other_point.lat - @lat
			lon_distance = other_point.lon - @lon
			return Math::sqrt(lat_distance * lat_distance + lon_distance * lon_distance)
		end
	end
end