require 'nokogiri'
require 'time'
require './lib/track'
require './lib/track_point'

module EndomondoComplementer

	class Complementer

		def initialize input_data_directory, output_file_name
			@input_data_directory = input_data_directory
			@output_file_name = output_file_name
		end

		def run
			puts $input_file_directory
			input_files = scan_input_files
			tracks = input_files.map { |filename| load_track(filename) }
			match_tracks! tracks
			interpolate_tracks! tracks
			sort_tracks! tracks
			merged_track = merge_tracks tracks
			save merged_track
			puts "Done."
		end

		def scan_input_files
			puts "Looking for input files in #{@input_data_directory}"
			input_files = Dir["#{@input_data_directory}/*.gpx"]
			puts "Found #{input_files.length} input files."
			return input_files
		end

		def match_tracks! tracks
			tracks.select { |track| track.type == :interpolated}.each do |track|
				puts "Matching track #{track}"
				interpolated_track_first_point = track.first_point
				interpolated_track_last_point = track.last_point

				closest_start_vincinity = nil
				closest_end_vincinity = nil

				closest_start_time = nil
				closest_end_time = nil

				tracks.select { |track| track.type == :real}.each do |real_track|

					#puts "Comparing track #{track} with track #{real_track}"

					real_track_first_point = real_track.first_point
					real_track_last_point = real_track.last_point

					start_vincinity = real_track_last_point.distance_to interpolated_track_first_point
					end_vincinity = real_track_first_point.distance_to interpolated_track_last_point

					#puts "Distance between the first point of #{track} and the last point of #{real_track}: #{start_vincinity}"
					#puts "Distance between the last point of #{track} and the first point if #{real_track}: #{end_vincinity}"

					if (closest_start_time == nil)
						closest_start_time = real_track_last_point.time
						closest_start_vincinity = start_vincinity
					else
						if (start_vincinity < closest_start_vincinity)
							closest_start_vincinity = start_vincinity
							closest_start_time = real_track_last_point.time
						end
					end

					if (closest_end_time == nil)
						closest_end_time = real_track_first_point.time
						closest_end_vincinity = end_vincinity
					else
						if (end_vincinity < closest_end_vincinity)
							closest_end_vincinity = end_vincinity
							closest_end_time = real_track_first_point.time
						end
					end

				end
				track.first_point.time = closest_start_time
				track.last_point.time = closest_end_time
			end
		end

		def interpolate_tracks! tracks
			tracks.select { |track| track.type == :interpolated}.each do |track|
				puts "Interpolating track #{track}"
				points = track.track_points
				start_time = track.first_point.time
				end_time = track.last_point.time
				delta_time = (end_time - start_time) / points.length

				time = start_time
				points.each do |point|
					point.time = time
					time = time + delta_time
				end

				points.sort!{|x, y| x.time <=> y.time}
			end
		end

		def sort_tracks! tracks
			puts "Sorting tracks"
			tracks.sort! { |a,b| a.first_point.time <=> b.first_point.time }
		end

		def merge_tracks tracks
			puts "Merging tracks"
			result = Nokogiri::XML::Builder.new do |xml|
				xml.gpx {
					xml.trk {
						xml.trkseg {
							tracks.each do |track|
								track.track_points.each do |point|
									xml.trkpt(:lat => point.lat, :lon => point.lon) {
										xml.time (point.time)
									}
								end
							end
						}
					}
				}
			end

			return result
		end

		def save track
			puts "Saving track"
			File.open(@output_file_name, "w") do |file|
				file.print(track.to_xml)
			end
			puts "Output written to #{@output_file_name}."
		end

		def load_track filename
			name = File.basename(filename)
			xml = Nokogiri::XML(open(filename))
			track_point_nodes = xml.xpath("//gpx:trkpt", "gpx" => "http://www.topografix.com/GPX/1/1")
			track_points = track_point_nodes.map do |node|
				lat = node["lat"].to_f
				lon = node["lon"].to_f
				time_nodes = node.xpath("gpx:time", "gpx" => "http://www.topografix.com/GPX/1/1")
				if (time_nodes.length == 1) 
					time = DateTime.strptime(time_nodes[0].content)
				else
					time = nil
				end
				
				TrackPoint.new lat, lon, time
			end

			result = Track.new name, track_points
			
			return result
		end

	end

end