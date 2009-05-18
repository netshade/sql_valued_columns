# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sql_valued_columns}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["netshade"]
  s.date = %q{2009-05-18}
  s.description = %q{= sql_valued_columns

SqlValuedColumns is an ActiveRecord plugin that will let you have specific
SQL statements executed on INSERT / UPDATE.  It will call the SQL function
you provide, passing the arguments specified in the call to sql_column.

See the documentation for SqlValuedColumns::ClassMethods#sql_column for more 
information regarding usage, including passing Strings and Proc objects as
arguments to your SQL function.

Example:  You have a model with two columns, one named "another_column" and 
the other named "size_of_another_column".  Whenever you insert data into 
"another_column", you want to have size_of_another_column have the result
of the SQL function LENGTH inserted into it.

  class MyModel < ActiveRecord::Base
    sql_column :size_of_another_column, "LENGTH", :another_column
  end

Example 2:  You have a model with three columns, position, latitude and longitude.
Latitude and longitude are values expressed as angles, and position is a special
datatype for your database that represents the X/Y/Z projection of that particular
latitude and longitude (example: http://www.postgresql.org/docs/8.3/static/earthdistance.html )

When you insert data with latitude and longitude, you want to automatically call a function
in your database to transform the latitude and longitude into the appropriate represenation.

  class MyModel < ActiveRecord::Base
    sql_column :position, "ll_to_earth", :latitude, :longitude
  end

Example 3:  You are an insane criminal who has somehow learned SQL.  You would like to 
make anyone who runs your code to suffer database punishing queries and odd security and
data formatting issues that will make them rue the day they ever learned of computers.

  class MyModel < ActiveRecord::Base
    sql_column :a_column, "(SELECT count(id) FROM large_list_of_things)", :raw => true
    sql_column :another_column, '(SELECT count(other_id) FROM other_large_list_of_things WHERE some_column = \'#{some_model_method}\')', :raw => true
  end


== Notes

No tests yet, am lazy.

== Copyright

Copyright (c) 2009 Chris Zelenak. See LICENSE for details.
}
  s.email = %q{netshade@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/sql_valued_columns.rb",
     "rails/bootstrap.rb",
     "rails/bootstrap.rb",
     "sql_valued_columns.gemspec",
     "test/sql_valued_columns_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/netshade/sql_valued_columns}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Specify values to be inserted into the database as the result of specific SQL functions}
  s.test_files = [
    "test/sql_valued_columns_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 2.3.2"])
    else
      s.add_dependency(%q<activerecord>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 2.3.2"])
  end
end
