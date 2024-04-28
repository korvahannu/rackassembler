module Rackassembler
  class ParserError < StandardError
  end

  class Parser
    attr_reader :current_line
    attr_accessor :code

    def initialize(filename)
      @filename = filename
      @file = File.open(@filename)
      @current_line_number = -1
      @current_line = nil
      @code = nil
    end

    def advance
      line = ""
      begin
        line = @file.readline()
        while !line.nil? && (line.strip.start_with?("//") || line.strip.empty?)
          line = @file.readline()
        end
      rescue EOFError
        rewind
        return false
      end
      line = line.gsub(" ", "").chomp
      @current_line_number += 1
      @current_line = line
      true
    end

    def instruction_type
      return :A_INSTRUCTION if current_line.start_with? "@"
      return :L_INSTRUCTION if current_line.start_with? "("
      :C_INSTRUCTION
    end

    def symbol
      raise ParserError, "Can not fetch symbol for type C_INSTRUCTION" if instruction_type == :C_INSTRUCTION
      return @current_line.delete("@") if instruction_type == :A_INSTRUCTION
      @current_line.gsub(/[()]/, "") if instruction_type == :L_INSTRUCTION
    end

    def dest
      raise ParserError, "Destination can only be fetched for type C_INSTRUCTION" unless instruction_type == :C_INSTRUCTION
      return @current_line.split("=", 2)[0] if @current_line.include? "="
      "null"
    end

    def comp
      raise ParserError, "Comp can only be fetched for type C_INSTRUCTION" unless instruction_type == :C_INSTRUCTION
      return @current_line unless @current_line.include?("=") || @current_line.include?(";")
      return @current_line.split("=", 2)[1] unless @current_line.include? ";"
      return @current_line.split(";", 2)[0] unless @current_line.include? "="
      @current_line.split(";").split("=")[1]
    end

    def jump
      raise ParserError, "Jump can only be fetched for type C_INSTRUCTION" unless instruction_type == :C_INSTRUCTION
      return "null" unless @current_line.include?(";")
      @current_line.split(";", 2)[1]
    end

    def label
      raise ParserError, "Label can only by extracted for type L_INSTRUCTION" unless instruction_type == :L_INSTRUCTION
      current_line.gsub(/[()]/, "")
    end

    def rewind
      @current_line_number = -1
      @current_line = nil
      @file = File.open(@filename)
    end

    def current_line_in_machine_language
      instruction = ""

      case instruction_type
      when :C_INSTRUCTION
        instruction = code.c_instruction(comp, dest, jump)
      when :A_INSTRUCTION
        instruction = code.a_instruction(current_line)
      when :L_INSTRUCTION
        instruction = nil
      else
        raise "Unknown instruction in line type: #{current_line}, #{current_line}"
      end

      instruction
    end
  end
end