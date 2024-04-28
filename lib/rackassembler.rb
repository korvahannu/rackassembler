# frozen_string_literal: true

require_relative "rackassembler/version"
require_relative "rackassembler/Parser"
require_relative "rackassembler/Code"

module Rackassembler
  class Error < StandardError; end

  file = ARGV[0]

  raise Error, "Please provide assembly file as a command-line argument" if file.nil?
  raise Error, "#{file} does not exist." unless File.exist?(file)

  output_filename = file.sub(".asm", ".hack")

  parser = Parser.new(File.open(file).readlines)
  code = Code.new

  #pre-assemble
  current_instruction_address = 0
  while parser.advance
    if parser.instruction_type == :L_INSTRUCTION
      symbol = parser.current_line.gsub(/[()]/, "")
      code.labels[symbol.to_sym] = current_instruction_address
    else
      current_instruction_address += 1
    end
  end

  parser.rewind

  File.open(output_filename, "w") do |f|

    while parser.advance
      instruction = ""

      case parser.instruction_type
      when :C_INSTRUCTION
        instruction += "111"
        instruction += code.comp(parser.comp)
        instruction += code.dest(parser.dest)
        instruction += code.jump(parser.jump)
      when :A_INSTRUCTION
        instruction = code.a(parser.current_line).to_s
      when :L_INSTRUCTION
        next
      else
        raise "Unknown instruction in line type: #{parser.current_line}, #{parser.current_line}"
      end
      f.puts instruction unless instruction.nil?
    end
  end
end
