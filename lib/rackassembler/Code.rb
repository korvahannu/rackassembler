require_relative 'Mnemonics'
require_relative 'PredefinedSymbols'

module Rackassembler
  class Code
    attr_reader :symbols
    attr_accessor :labels

    def initialize
      @symbols = {}
      @labels = {}
      @symbol_index = 16
    end

    def dest(mnemonic)
      result = DEST_MNEMONICS[mnemonic.to_sym]
      raise "Unknown mnemonic #{mnemonic}" if result.nil?
      result
    end

    def comp(mnemonic)
      result = COMP_MNEMONICS[mnemonic.to_sym]
      raise "Unknown mnemonic #{mnemonic}" if result.nil?
      result
    end

    def jump(mnemonic)
      result = JUMP_MNEMONICS[mnemonic.to_sym]
      raise "Unknown mnemonic #{mnemonic}" if result.nil?
      result
    end

    def a_instruction(instruction)
      original = instruction[1..-1]
      instruction = original
      instruction = PREDEFINED_SYMBOLS[instruction.to_sym] unless instruction =~ /\A[0-9]+\z/
      instruction = @labels[original.to_sym] if instruction.nil?
      instruction = get_or_add_symbol(original) if instruction.nil?
      integer_to_16bit_binary(instruction)
    end

    def add_label(label, value)
      labels[label.to_sym] = value
    end

    private

    def integer_to_16bit_binary(str)
      str = str.to_i.to_s(2)
      while str.size < 16
        str.prepend("0")
      end
      str
    end

    def get_or_add_symbol(symbol)
      original = symbol
      symbol = @symbols[symbol.to_sym]
      return symbol unless symbol.nil?
      @symbols[original.to_sym] = @symbol_index
      index = @symbol_index
      @symbol_index += 1
      index
    end
  end
end