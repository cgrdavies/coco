require './spec/helper'

describe ConsoleFormatter do

  it "should respond to format" do
    formatter = ConsoleFormatter.new(COVERAGE_90, ['a', 'b', 'c'], 100, true, true)
    formatter.respond_to?(:format).should == true
  end

  it "should return percents and filename" do
    formatter = ConsoleFormatter.new(COVERAGE_80, [], 100, true, true)
    result = formatter.format
    result.should == "\e[33mYour codebase is 80% covered. \n" +
                     "\e[0m\nThe following files may need some attention:\n" +
                     "\e[33m80% the/filename/80\e[0m"
  end

  it "should return percents and filename and uncovered" do
    formatter = ConsoleFormatter.new(COVERAGE_80, ['a'], 100, true, true)
    result = formatter.format
    result.should == "\e[33mYour codebase is 80% covered. \n" +
                     "\e[0m\nThe following files may need some attention:\n" +
                     "\e[31m0% a\e[0m\n" +
                     "\e[33m80% the/filename/80\e[0m"
  end

  it "should sort by percentage" do
    formatter = ConsoleFormatter.new(COVERAGE_100_90_80, [], 100, true, true)
    result = formatter.format
    result.should == "\e[33mYour codebase is 90% covered. \n" +
                     "\e[0m\nThe following files may need some attention:\n" +
                     "\e[33m80% the/filename/80\e[0m\n" +
                     "\e[33m90% the/filename/90\e[0m"
  end

  it "should sort by percentage uncovered too" do
    formatter = ConsoleFormatter.new(COVERAGE_100_90_80, ['a', 'b'], 100, true, true)
    result = formatter.format
    result.should == "\e[33mYour codebase is 90% covered. \n" +
                     "\e[0m\nThe following files may need some attention:\n" +
                     "\e[31m0% a\e[0m\n" +
                     "\e[31m0% b\e[0m\n" +
                     "\e[33m80% the/filename/80\e[0m\n" +
                     "\e[33m90% the/filename/90\e[0m"
  end

  it "should put in green when >= threshold" do
    formatter = ConsoleFormatter.new(COVERAGE_100_90_80, ['a', 'b'], 90, true, true)
    result = formatter.format
    result.should == "\e[32mYour codebase is 90% covered. \n" +
                     "\e[0m\nThe following files may need some attention:\n" +
                     "\e[31m0% a\e[0m\n" +
                     "\e[31m0% b\e[0m\n" +
                     "\e[33m80% the/filename/80\e[0m"
  end

  context "when 'exclude_files' is false" do
    it "should return all the files" do
      formatter = ConsoleFormatter.new(COVERAGE_100_90_80, ['a', 'b', 'c'], 100, false, true)
      result = formatter.format false
      result.should == "\e[33mYour codebase is 90% covered. \n" +
                       "\e[0m\n\e[31m0% a\e[0m\n" +
                       "\e[31m0% b\e[0m\n" +
                       "\e[31m0% c\e[0m\n" +
                       "\e[33m80% the/filename/80\e[0m\n" +
                       "\e[33m90% the/filename/90\e[0m\n" +
                       "\e[32m100% the/filename/100\e[0m"
    end

    it "should not include the 'fix_these_message'" do
      formatter = ConsoleFormatter.new(COVERAGE_100_90_80, ['a', 'b', 'c'], 100, false, false)
      result = formatter.format false
      result.should_not include("The following files may need some attention:\n")
    end
  end

  context "when 'single_line_report' is true" do

    context "and there is some uncovered files" do
      it "should return a message" do
        formatter = ConsoleFormatter.new(COVERAGE_90, ['a', 'b', 'c'], 100, true, false)
        result = formatter.format true
        result.should == "\e[33mSome files are uncovered\e[0m"
      end
    end

    context "and there is no uncovered files" do
      it "should return nothing" do
        formatter = ConsoleFormatter.new(COVERAGE_90, [], 100, true, false)
        result = formatter.format true
        result.should == "\e[32mAll yah files ahh covehhd.\e[0m"
      end
    end

  end

end
