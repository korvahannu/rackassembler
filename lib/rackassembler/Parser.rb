module Rackassembler
  class ParserError < StandardError
  end

  class Parser
    attr_reader :current_line

    def initialize(assembly)
      @assembly = assembly
      @assembly.reject! { |line| line.strip.empty? }
      @assembly.reject! { |line| line.strip.start_with?("//") }
      @assembly.map! { |line| line.gsub(" ", "").chomp}
      @current_line_number = 0
      @current_line = @assembly[@current_line_number]
    end
    def has_more_lines?
      @current_line_number < @assembly.size
    end
    def advance
      return unless has_more_lines?
      @current_line_number += 1
      @current_line = @assembly[@current_line_number]
    end
    def instruction_type
      return :A_INSTRUCTION if current_line.start_with? "@"
      return :L_INSTRUCTION if current_line.start_with? "("
      :C_INSTRUCTION
    end
    def symbol
      raise ParserError, "Can not fetch symbol for C_INSTRUCTION" if instruction_type == :C_INSTRUCTION
      return @current_line.delete("@") if instruction_type == :A_INSTRUCTION
      @current_line.gsub(/[()]/, "") if instruction_type == :L_INSTRUCTION
    end
    def dest
      raise ParserError, "Destination can only be fetched for C_INSTRUCTION" unless instruction_type == :C_INSTRUCTION
      return @current_line.split("=", 2)[0] if @current_line.include? "="
      "null"
    end
    def comp
      raise ParserError, "Comp can only be fetched for C_INSTRUCTION" unless instruction_type == :C_INSTRUCTION
      return @current_line unless @current_line.include?("=") || @current_line.include?(";")
      return @current_line.split("=", 2)[1] unless @current_line.include? ";"
      return @current_line.split(";", 2)[0] unless @current_line.include? "="
      @current_line.split(";").split("=")[1]
    end
    def jump
      raise ParserError, "Jump can only be fetched for C_INSTRUCTION" unless instruction_type == :C_INSTRUCTION
      return "null" unless @current_line.include?(";")
      @current_line.split(";", 2)[1]
    end

    def info
      <<~EOS
Has more lines? #{has_more_lines?}    
Instruction type #{instruction_type}    
Symbol #{symbol}    
Destination #{dest}    
Computation #{comp}    
Jump #{jump}      
      EOS
    end
  end
end