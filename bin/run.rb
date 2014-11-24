require './lib/complementer'



input_file_directory = "./input"
output_directory = "./output"
output_file_name = "#{output_directory}/output.gpx"


if !Dir.exist?(input_file_directory)
	puts "Create #{input_file_directory} directory and put gpx tracks there."
	exit
end

if !Dir.exist?(output_directory)
	Dir.mkdir(output_directory)
end

EndomondoComplementer::Complementer.new(input_file_directory, output_file_name).run