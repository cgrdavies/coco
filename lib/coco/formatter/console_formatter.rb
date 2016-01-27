module Coco

  # I format coverages data for console output.
  class ConsoleFormatter < Formatter

    # Public: Get a colored report, formatted for console output.
    #
    # single_line_report - Boolean
    #
    # Returns percent covered and associated filenames as a multilines
    # String
    def format(single_line_report = false)
      single_line_report ? single_line_message : @formatted_output.join("\n")
    end

    # Get the link for the report's index file.
    #
    # Returns String.
    def link
      unless @formatted_output.empty?
        "See file://" +
          File.expand_path(File.join(Coco::HtmlDirectory.new.coverage_dir,
                                     'index.html'))
      end
    end

    # Public: Creates a new ConsoleFormatter.
    #
    # covered   - See base class Formatter.
    # uncovered - See base class Formatter.
    # threshold - The Fixnum percentage threshold.
    def initialize(covered, uncovered, threshold, exclude_files, show_total_coverage)
      super(covered, uncovered)
      @exclude_files = exclude_files
      @threshold = threshold
      @show_total_coverage = show_total_coverage
      @formatted_output = []
      @coverage_percentages = []
      compute_percentage
      @total_coverage_percentage = compute_total_coverage
      filter_formatted_output if exclude_files
      add_percentage_to_uncovered
      format_output
    end

    private

    attr_accessor :threshold, :formatted_output, :coverage_percentages,
                  :total_coverage_percentage, :raw_coverages, :exclude_files,
                  :show_total_coverage

    def format_output
      formatted_output.sort!
      formatted_output.map! { |percentage, filename| format_text(percentage, filename) }
      formatted_output.unshift fix_these_message if exclude_files && formatted_output.any?
      formatted_output.unshift total_coverage_message if show_total_coverage
    end

    def format_text(percentage, filename)
      text = ColoredString.new "#{percentage}% #{filename}"
      determine_text_color(text, percentage)
    end

    def compute_percentage
      raw_coverages.each do |filename, coverage|
        percentage = CoverageStat.coverage_percent(coverage)
        coverage_percentages << percentage
        formatted_output << [percentage, filename]
      end
    end

    def filter_formatted_output
      formatted_output.reject! do |percentage, filename|
        percentage >= @threshold
      end
    end

    def compute_total_coverage
      (coverage_percentages.inject 0, :+) / coverage_percentages.length
    end

    def add_percentage_to_uncovered
      @uncovered.each {|filename| @formatted_output << [0, filename] }
    end

    def single_line_message
      if @uncovered.empty?
        ColoredString.new("All yah files ahh covehhd.").green
      else
        ColoredString.new("Some files are uncovered").yellow
      end
    end

    def fix_these_message
      "The following files may need some attention:"
    end

    def total_coverage_message
      message = ColoredString.new "Your codebase is #{total_coverage_percentage}% covered. \n"
      determine_text_color(message, total_coverage_percentage)
    end

    def determine_text_color(text, percentage)
      case percentage
      when 0..50 then text.red
      when threshold..100 then text.green
      else text.yellow
      end
    end
  end
end
