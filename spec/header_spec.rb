# encoding: utf-8

require 'csv'

require_relative '../lib/pile/header.rb'
include Pile

require_relative 'spec_helper'

describe Header, 'column_index' do
  include Pile::Helpers

  it 'should return the same integer indices' do
    header = new_example_header

    header.column_index(2).should == 2
    header.column_index(0).should == 0
  end

  it 'should recognized column names' do
    header = new_example_header

    header.column_index('name').should == 1
  end

  it 'should recognize aliases' do
    header = new_example_header

    header.column_index('id').should == 0
    header.column_index('identity').should == 0

    header.column_index('address line').should == 2
    header.column_index('address').should == 2
  end

  it 'should respect case sensitivity' do
    header = new_example_header

    header.column_index('address line').should == 2
    header.case_sensitive = true
    header.column_index('address line').should == nil
    header.column_index('Address Line').should == 2
    header.case_sensitive = false
    header.column_index('address line').should == 2
  end
end

describe Header, 'write_header' do
  include Pile::Helpers

  it 'writes the example header that matches our string' do
    header = new_example_header

    read_write_tempfile 'csv-spec' do |file, step|
      case step
      when :write
        file.write (CSV.generate {|csv| header.write_header csv})
      when :read
        file.read.should == "ID,Name,Address Line\n"
      end
    end
  end

  it 'is the right-inverse of from_csv_row' do
    header = new_example_header

    read_write_tempfile 'csv-spec' do |file, step|
      case step
      when :write
        file.write (CSV.generate {|csv| header.write_header csv})
      when :read
        header2 = Header.from_csv_row file.read, header.aliases
        header2.should == header
      end
    end
  end
end

describe Header, '==' do
  include Pile::Helpers

  it 'should not consider headers with different indices the same' do
    header = new_example_header
    header2 = new_example_header
    header2.indices[3] = 'Country'

    header2.should_not == header
  end

  it 'should not consider headers with different indices the same' do
    header = new_example_header
    header2 = new_example_header
    header2.aliases['name'] = ['handle', 'nick']

    header2.should_not == header
  end

  it 'should consider headers with the same indices and aliases as equal' do
    header = new_example_header
    header2 = new_example_header

    header2.should == header
  end
end
