module Pile
  module Helpers
    require 'tempfile'

    # Construct a new header as specified in the example in the documentation
    # of the +Header+ class.
    def new_example_header
      header = Header.new ({'id' => ['identity', '#'], 'address line' => ['address']}),
                          'ID', 'Name', 'Address Line'
    end

    # Open and close a +Tempfile+ around a block yielded to with the +Tempfile+
    # object.
    def with_tempfile name
      file = Tempfile.new name
      begin
        yield file
      ensure
        file.close
        file.unlink
      end
    end

    # Calls the block twice: first with +:write+ as the second argument, and
    # then second with +:read+ as the second argument.  The file is rewound to
    # the beginning in between.
    def read_write_tempfile name
      with_tempfile name do |file|
        yield file, :write
        file.rewind
        yield file, :read
      end
    end

    def new_example_record
      Record.new new_example_header, 3, 'Bob Smith', '123 1st St'
    end

    def new_example_list
      header = new_example_header
      List.new header, [Record.new(header), *new_example_record.values]
    end

    def example_list_csv_string
      "ID,Name,Address Line\n1,Alice,123 1st St\n2,Bob,234 2nd St\n3,Charles,345 3rd St\n"
    end
  end
end
