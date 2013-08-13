# encoding: utf-8

require 'csv'

module Pile
  # Individual record in list of contributors, as an array of values coupled
  # with its header.
  #
  # @param [Pile::Header] header The header defining the structure of
  #   each record; used to determine the type of each entry in the record
  #   by its position.
  class Record
    # Construct a 'Header' from a CSV-formatted line.
    def self.from_csv_row row, header
      self.new header, *row.parse_csv(converters: [:integer])
    end

    # @return [Pile::Header] The header associated with this record.
    attr_accessor :header
    # @return [Array<Object>] The values associated with this record.  See
    # below for helper methods that operate on a record's values.
    attr_accessor :values
    # @return [CSV] An optional CSV object, which some helper methods use; e.g.
    # see +add_record_to_csv+
    attr_accessor :csv

    # @param [Pile::Header] header The header associated with this record,
    #   defining the structure of the record, and by what names (e.g. 'id' and
    #   'name') values can be indexed.
    # @param [Array<Object>] values The values in the row of the record.
    def initialize header, *values
      @header = header
      @values = values
    end

    # Send everything that the +header+ object recognized to it.  Can be used
    # for +column_index+, etc.
    def method_missing method, *args, &block
      header.send method, *args, &block
    end

    # Retrieve a value in the record by its position, or by the column name.
    # Aliases are recognized.
    def [](i)
      values[column_index i]
    end

    # Set a value in the record by its position, or by the column name.
    # Aliases are recognized.
    def []=(i, v)
      values[column_index i] = v
    end

    # Write this record to its CSV object, if present.
    #
    # @param [CSV] csv (nil) If present, the values will be written to the
    #   passed CSV object rather than the header's.
    def write_record csv = nil
      csv ||= self.csv
      raise 'Record#add_record_to_csv: no associated CSV object.' unless csv

      csv << values
    end

    def ==(other)
      self.header == other.header && self.values == other.values && self.csv == other.csv
    end

    def eql?(other)
      self.header.eql?(other.header) && self.values.eql?(other.values) && self.csv.eql?(other.csv)
    end

    # Enumerate the record after converting to an array with +to_a+.
    def each
      to_a.each
    end

    # Enumerate each value.
    def to_a
      values
    end

    include Enumerable
  end
end
