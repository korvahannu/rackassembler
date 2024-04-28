# frozen_string_literal: true

require_relative "rackassembler/version"
require_relative "rackassembler/Parser"
require_relative "rackassembler/Code"
require 'benchmark'

module Rackassembler
  class InputFileError < StandardError; end

  file = ARGV[0]

  raise InputFileError, "Please provide assembly file as a command-line argument" if file.nil?
  raise InputFileError, "#{file} does not exist." unless File.exist?(file)
  raise InputFileError, "#{file} is missing the .asm -extension." unless file.include?(".asm")

  time = Benchmark.realtime do
    output_filename = file.sub(".asm", ".hack")

    parser = Parser.new(file)
    code = Code.new

    current_instruction_address = 0
    while parser.advance
      if parser.instruction_type == :L_INSTRUCTION
        code.add_label(parser.label, current_instruction_address)
      else
        current_instruction_address += 1
      end
    end

    parser.code = code

    File.open(output_filename, "w") do |f|
      while parser.advance
        instruction = parser.current_line_in_machine_language
        next if instruction.nil?
        f.puts instruction
      end
    end
  end

  puts "Finished in #{time.round(2)}s"
end
