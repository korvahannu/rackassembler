# frozen_string_literal: true

require_relative "rackassembler/version"
require_relative "rackassembler/Parser"

module Rackassembler
  class Error < StandardError; end

  file = ARGV[0]

  raise Error, "Please provide assembly file as a command-line argument" if file.nil?
  raise Error, "#{file} does not exist." unless File.exist?(file)

  parser = Parser.new(File.open(file).readlines)

  while parser.has_more_lines?
    # p "#{parser.current_line}: #{parser.instruction_type}"
    # p "#{parser.symbol}" unless parser.instruction_type == :C_INSTRUCTION
    # p "#{parser.dest}" if parser.instruction_type == :C_INSTRUCTION
    # p "#{parser.comp}" if parser.instruction_type == :C_INSTRUCTION
    p "#{parser.jump}" if parser.instruction_type == :C_INSTRUCTION
    parser.advance
  end
end
