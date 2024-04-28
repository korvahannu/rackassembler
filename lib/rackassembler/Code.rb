module Rackassembler
  class Code

    attr_reader :symbols
    attr_accessor :labels

    COMP_MNEMONICS = {
      "0": "0101010",
      "1": "0111111",
      "-1": "0111010",
      "D": "0001100",
      "A": "0110000",
      "!D": "0001101",
      "!A": "0110001",
      "-D": "0001111",
      "-A": "0110011",
      "D+1": "0011111",
      "A+1": "0110111",
      "D-1": "0001110",
      "A-1": "0110010",
      "D+A": "0000010",
      "D-A": "0010011",
      "A-D": "0000111",
      "D&A": "0000000",
      "D|A": "0010101",
      "M": "1110000",
      "!M": "1110001",
      "-M": "1110011",
      "M+1": "1110111",
      "M-1": "1110010",
      "D+M": "1000010",
      "D-M": "1010011",
      "M-D": "1000111",
      "D&M": "1000000",
      "D|M": "1010101"
    }.freeze

    DEST_MNEMONICS = {
      "null": "000",
      "M": "001",
      "D": "010",
      "DM": "011",
      "MD": "011", # MD actually is not in the book instruction set. This is an error.
      "A": "100",
      "AM": "101",
      "AD": "110",
      "ADM": "111"
    }.freeze

    JUMP_MNEMONICS = {
      "null": "000",
      "JGT": "001",
      "JEQ": "010",
      "JGE": "011",
      "JLT": "100",
      "JNE": "101",
      "JLE": "110",
      "JMP": "111"
    }.freeze

    PREDEFINED_SYMBOLS = {
      "R0": "0",
      "R1": "1",
      "R2": "2",
      "R3": "3",
      "R4": "4",
      "R5": "5",
      "R6": "6",
      "R7": "7",
      "R8": "8",
      "R9": "9",
      "R10": "10",
      "R11": "11",
      "R12": "12",
      "R13": "13",
      "R14": "14",
      "R15": "15",
      "SP": "0",
      "LCL": "1",
      "ARG": "2",
      "THIS": "3",
      "THAT": "4",
      "SCREEN": "16384",
      "KBD": "24576"
    }

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

    def i_as_s_to_16_bit_binary_s(str)
      str = str.to_i.to_s(2)
      while str.size < 16
        str.prepend("0")
      end
      str
    end

    def a(instruction)
      original = instruction[1..-1]
      instruction = original
      instruction = PREDEFINED_SYMBOLS[instruction.to_sym] unless instruction =~ /\A[0-9]+\z/
      instruction = @labels[original.to_sym] if instruction.nil?
      instruction = get_or_add_symbol(original) if instruction.nil?
      i_as_s_to_16_bit_binary_s(instruction)
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