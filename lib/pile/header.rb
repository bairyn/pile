# encoding: utf-8

require 'csv'

require_relative 'record'

module Pile
  # Header that contains the names of each column, used to refer to values of
  # records by name.
  #
  # For example, given a CSV file containing the following header followed by
  # multiple lines each containing a record,
  #
  # "ID, Name, Address Line"
  #
  # The parsed array from this row can be passed to +initialize+ after the
  # +aliases+ hash, which can look like this, assuming +case_sensitive+ is
  # false:
  #
  # {'id' => ['identity', '#'], 'address line' => ['address']}
  class Header
    # Construct a 'Header' from a CSV-formatted line.
    def self.from_csv_row row, aliases = {}
      self.new aliases, *row.parse_csv(converters: [:integer])
    end

    # @return [Hash<String, Array<String>>] aliases A hash of aliases from the column
    #   name to an array of names that contains aliases, each of which can be
    #   used to identify the same column.  Without case sensitivity, each key
    #   in this hash is downcased.
    attr_writer :aliases
    def aliases= aliases
      @aliases_downcased = nil

      # Ensure each value is an array; create a singleton array for each one
      # that isn't.
      @aliases = {}
      aliases.each_pair {|k, v| @aliases[k] = v.kind_of?(Array) ? v : [v]}
      @aliases = aliases
    end
    def aliases
      if case_sensitive
        @aliases
      elsif @aliases_downcased
        @aliases_downcased
      else
        downcased = {}
        @aliases.each_pair {|k, v| downcased[k.downcase] = v}
        @aliases_downcased = downcased
      end
    end
    # @param [Array<String>] indices The name of each value.  Conventionally the
    #   first row in a CSV file.
    attr_accessor :indices

    # @return [Boolean] Whether indices are case sensitive; defaults to +false+.
    def case_sensitive
      @case_sensitive.nil? ? @case_sensitive = false : @case_sensitive
    end
    attr_writer :case_sensitive

    # @return [CSV] (nil) Optional CSV object associated with this header; used
    #   for utility functions such as +write_header+.
    attr_accessor :csv

    #
    # @param [Hash<String, Array<String>>] aliases A hash of aliases from the column
    #   name to an array of names that contains aliases, each of which can be
    #   used to identify the same column.
    # @param [Array<String>] indices The name of each value.
    def initialize(aliases, *indices)
      @aliases = aliases
      @indices = indices
    end

    # Return the integer position that +i+ refers to.  This takes into
    # account the name of each column and the alias hash.
    def column_index i
      if case_sensitive
        position = indices.find_index {|column| column == i || (@aliases.has_key?(column) && @aliases[column].member?(i))}
      else
        position = indices.find_index {|column| column.downcase == i.to_s.downcase || (aliases.has_key?(column.downcase) && aliases[column.downcase].any? {|the_alias| the_alias.downcase == i.to_s.downcase})}
      end

      position ||= (i.kind_of?(Fixnum) ? i : nil)
    end

    # Write this header to the header's CSV object, if present.
    #
    # @param [CSV] csv (nil) If present, the header will be written to the
    #   passed CSV object rather than the header's.
    def write_header csv = nil
      csv << indices
    end

    def ==(other)
      self.aliases == other.aliases && self.indices == other.indices && self.csv == other.csv
    end

    def eql?(other)
      self.aliases.eql?(other.aliases) && self.indices.eql?(other.indices) && self.csv.eql?(other.csv)
    end

    # Enumerate the record after converting to an array with +to_a+.
    def each
      to_a.each
    end

    # Enumerate each column header.
    def to_a
      indices
    end

    include Enumerable
  end
end
