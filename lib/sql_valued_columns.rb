module SqlValuedColumns
  def self.included(base)
    base.extend(SqlValuedColumns::ClassMethods)
    base.class_eval {  include SqlValuedColumns::InstanceMethods }
    base.alias_method_chain(:attributes_with_quotes, :sqlcolumns)    
  end

  # Includes the SqlValuedColumns module to ActiveRecord, overriding existing value insertion functionality.
  def self.activate!
    ActiveRecord::Base.class_eval { include ::SqlValuedColumns }
  end

  module ClassMethods

    # Indicates the given column will have its value filled by the result of an SQL function.  Pass a hash as the last 
    # argument with any optional args.
    #
    # ==== Arguments
    # * <tt>column</tt> - +Symbol+, the name of the column to fill
    # * <tt>function</tt> - +String+, the name of the function to execute, or the literal SQL to call if options[:raw] is true
    # * <tt>args</tt> - +Array+ of arguments to pass to the SQL function specified.  If an argument is a +Symbol+, the name it 
    #   represents will be called on the model at save time.  If it is a +Proc+, it will be called with the
    #   model passed as the only argument to the +Proc+.  If it is a +String+, the +String+ will evaluated if
    #   the pattern #{some_code} appears within it.  Once all these conditions have been exhausted, the
    #   resultant values will be quoted as appropriate by your database adapter and populate the arguments
    #   list of the SQL function you specified.
    # * <tt>options</tt> (optional) - Hash of optional arguments ( :raw ) .
    def sql_column(column, function, *args)
      options = args.extract_options!
      raw = options[:raw] == true
      @sql_columns ||= { }
      @sql_columns[column] = [function, args, raw]
    end

    def sql_columns
      @sql_columns ||= { }
    end
    
  end

  module InstanceMethods
    
    def attributes_with_quotes_with_sqlcolumns(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
      h = self.attributes_with_quotes_without_sqlcolumns(include_primary_key, include_readonly_attributes, attribute_names)
      names = h.keys
      names.each do |name|
          if self.class.sql_columns[name]
            function, args, raw = self.class.sql_columns[name]
            unless raw 
              fmt_args = args.collect do |a|
                case a
                when Symbol
                  connection.quote(read_attribute(a.to_s))
                when Proc
                  connection.quote(a.call(self))
                when String
                  str = a
                  if a =~ /\#\{[^\}]+\}/
                    str = eval('"' + str + '"')
                  end
                  connection.quote(str)
                else
                  connection.quote(a)
                end
              end
              h[name] = "#{function}(#{fmt_args.join(",")})"
            else
              h[name] = eval('"' + function + '"')
            end
          end
      end
      h
    end
    
  end


  
end

