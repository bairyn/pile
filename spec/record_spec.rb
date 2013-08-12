# encoding: utf-8

require 'csv'

require_relative '../lib/pile/record.rb'
include Pile
include Helpers

require_relative 'spec_helper'

describe Record, '[]' do
  it 'should return the appropriate values' do
    record = new_example_record

    record[1].should         == 'Bob Smith'
    record['name'].should    == 'Bob Smith'
    record['address'].should == '123 1st St'
  end
end

describe Record, '[]=' do
  it 'should update values' do
    record = new_example_record

    record[1].should         == 'Bob Smith'
    record['name'].should    == 'Bob Smith'
    record['address'].should == '123 1st St'
  end
end

describe Record, 'write_record' do
  it 'writes the example record that matches our string' do
    record = new_example_record

    read_write_tempfile 'csv-record-spec' do |file, step|
      case step
      when :write
        contents = CSV.generate do |csv|
          record.write_header csv
          record.write_record csv
        end
        file.write contents
      when :read
        file.read.should == "ID,Name,Address Line\n3,Bob Smith,123 1st St\n"
      end
    end
  end

  it 'is the right-inverse of from_csv_row' do
    record = new_example_record

    read_write_tempfile 'csv-record-spec' do |file, step|
      case step
      when :write
        contents = CSV.generate do |csv|
          record.write_header csv
          record.write_record csv
        end
        file.write contents
      when :read
        lines = file.readlines

        header2 = Header.from_csv_row lines[0], record.aliases
        record2 = Record.from_csv_row lines[1], header2

        record2.should == record
      end
    end
  end
end

describe Record, '==' do
  it 'should not consider records with different values the same' do
    record = new_example_record
    record2 = new_example_record
    record2[1] = 'Bob Johnson'

    record2.should_not == record
  end

  it 'should consider records with the same indices and aliases as equal' do
    record = new_example_record
    record2 = new_example_record

    record2.should == record
  end
end
