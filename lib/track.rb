module EndomondoComplementer

	class Track

		attr_reader :type
		attr_reader :name
		attr_reader :track_points

		def initialize (name, track_points)
			@name = name
			@track_points = track_points
			if @track_points[0].time != nil
				@type = :real
			else
				@type = :interpolated
			end
		end

		def to_s
			return "#{@name} (#{@type})"
		end

		def first_point
			@track_points.first
		end

		def last_point
			@track_points.last
		end

	end

end