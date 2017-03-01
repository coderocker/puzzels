require './lib/file_processor'

class GuideToGalaxy

  def initialize(args)
    @input_file_path = args[0]
    @file_processor = FileProcessor.new(@input_file_path)
  end

  def output
    @file_processor.process
    @file_processor.token_to_integer
    @file_processor.output
  end

end
