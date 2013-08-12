# encoding: utf-8

require_relative '../lib/pile/list.rb'
include Pile

require_relative 'spec_helper'

describe List, '::map_csv_contents' do
  include Pile::Helpers

  it 'responds to mappings as we expect' do
    file_contents = "ID,Name,Address Line\n1,Alice,123 1st St\n2,Bob,234 2nd St\n3,Charles,345 3rd St\n"
    aliases = {'Address Line' => ['address']}

    updated_contents = List.map_csv_contents file_contents, aliases do |header, record|
      record['id'] += 1
      record
    end

    updated_contents.should == "ID,Name,Address Line\n2,Alice,123 1st St\n3,Bob,234 2nd St\n4,Charles,345 3rd St\n"
  end
end

describe List, '::csv_string' do
  it 'returns the contents we expect' do
    file_contents = example_list_csv_string

    list = List.from_string file_contents
    output = list.csv_string

    list.csv_string.should == "ID,Name,Address Line\n1,Alice,123 1st St\n2,Bob,234 2nd St\n3,Charles,345 3rd St\n"
  end

  it 'is the right-inverse of from_string' do
    list = List.from_string example_list_csv_string

    read_write_tempfile 'csv-list-spec' do |file, step|
      case step
      when :write
        file.write list.csv_string
      when :read
        list2 = List.from_string file.read

        list2.should == list
      end
    end
  end
end

describe List, '::render_rows' do
  it 'returns the output we expect' do
    file_contents = example_list_csv_string

    list = List.from_string file_contents
    output = list.render_rows

    output.should == [["ID", "Name", "Address Line"], [1, "Alice", "123 1st St"], [2, "Bob", "234 2nd St"], [3, "Charles", "345 3rd St"]]
  end

  it 'is the right-inverse of from_matrix' do
    list = List.from_string example_list_csv_string
    list2 = List.from_matrix list.render_rows

    list2.should == list
  end
end

describe List, '::render_matrix' do
  it 'is the right-inverse of from_matrix' do
    list = List.from_string example_list_csv_string
    list2 = List.from_matrix list.render_matrix

    list2.should == list
  end
end

describe List, '==' do
  it 'should not consider lists with different headers the same' do
    list = new_example_list
    list2 = new_example_list
    list2.header.indices[0] = 'ID#'

    list2.should_not == list
  end

  it 'should consider lists with the same headers and records as equal' do
    list = new_example_list
    list2 = new_example_list

    list2.should == list
  end
end
