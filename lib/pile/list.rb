# encoding: utf-8

require 'csv'
require 'matrix'

require_relative 'header'
require_relative 'record'

module Pile
  # A database of +Record+s, as an array of records coupled with their header.
  class List
    # Construct a +List+ from the contents of a CSV-formatted file.
    #
    # @param [String, Array<String>] contents The contents of a file, or an
    #   array of the lines of the file.
    # @param [Hash<String, Array<String>>] aliases ({})
    def self.from_string contents, aliases = {}
      lines = contents.kind_of?(Array) ? contents : contents.lines
      header = Header.from_csv_row lines[0], aliases
      self.new header, lines[1..-1].map{|l| Record.from_csv_row l, header}
    end

    # Construct a +List+ from a matrix.  Inverse of +render_rows+.
    #
    # @param [Array<Array<String>>, Matrix<String>] matrix
    def self.from_matrix matrix, aliases = {}
      matrix = matrix.to_a
      header = Header.new aliases, *(matrix[0] || [])
      if matrix.length <= 1
        # Header only.
        self.new header, []
      else
        self.new header, matrix[1..-1].map{|row| Record.new header, *row}
      end
    end

    # Read in filepath_from and write to filepath_to, which must refer to a
    # different file, yielding to the block given with the header as the first
    # argument and the record as the second; the block should return a new
    # +Record+.
    #
    # The +Header+ must be the same for each +Record+, but it can be changed if
    # the same one is returned for each record.
    #
    # No value is returned from this method.
    def self.map_csv_file filepath_from, filepath_to, aliases
      return to_enum :map_csv_file, filepath_from, filepath_to, aliases unless block_given?

      # write
      CSV.open(filepath_to, 'wb') do |csv|
        header = nil
        empty  = true

        # read
        CSV.foreach(filepath_from, converters: [:integer]) do |row|
          if !header
            # Header.
            header = Header.new aliases, *row
          else
            # Record.
            record = Record.new header, *row
            record = yield header, record

            if empty
              empty = false
              record.write_header csv
            end

            record.write_record csv
          end
        end

        # We wait until we check for the first record before writing the header
        # in case it changed.  Write the original one if there are no records.
        if empty
          empty = false
          record.write_header csv
        end
      end
    end

    # Like +map_csv_file+, but operates on strings instead of files.
    def self.map_csv_contents contents, aliases
      return to_enum :map_csv_contents, contents, aliases unless block_given?

      # write
      s = CSV.generate do |csv|
        header = nil
        empty  = true

        # read
        CSV.parse contents, converters: [:integer] do |row|
          if !header
            # Header.
            header = Header.new aliases, *row
          else
            # Record.
            record = Record.new header, *row
            record = yield header, record

            if empty
              empty = false
              record.write_header csv
            end

            record.write_record csv
          end
        end

        # We wait until we check for the first record before writing the header
        # in case it changed.  Write the original one if there are no records.
        if empty
          empty = false
          record.write_header csv
        end
      end
    end

    attr_accessor :header
    attr_accessor :records

    # @param [Pile::Header] header
    # @param [Array<Pile::Record>] records
    def initialize(header, records)
      @header  = header
      @records = records
    end

    # Map each record.
    #
    # The +Header+ must be the same for each +Record+, but it can be changed if
    # the same one is returned for each record.
    def map_records &block
      records.map &block
      header = records[0].header unless records.empty?
    end

    # Generate a CVS-formatted string encoding this list that can be written to
    # a file.
    #
    # @return [String]
    def csv_string
      CSV.generate do |csv|
        header.write_header csv
        records.each {|r| r.write_record csv}
      end
    end

    # Return an unwrapped matrix containing the header and each record.
    #
    # @return [Array<Array<String>>]
    def render_rows
      [header.indices, *(records.map &:values)]
    end

    # Returns a matrix containing the header and each record.
    #
    # @return [Matrix<String>]
    def render_matrix
      Matrix.rows render_rows
    end

    def ==(other)
      self.header == other.header && self.records == other.records
    end

    def eql?(other)
      self.header.eql?(other.aliases) && self.records.eql?(other.records)
    end

    # Enumerate the list records after converting to an array with +to_a+.
    def each
      to_a.each
    end

    # Enumerate each record.  Note that the header is not returned.
    def to_a
      records
    end

    include Enumerable
  end
end
