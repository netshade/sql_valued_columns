module SqlValuedColumns
  def self.included(base)
    base.extend(SqlValuedColumns::ClassMethods)
    base.class_eval {  include SqlValuedColumns::InstanceMethods }
    base.alias_method_chain(:attributes_with_quotes, :sqlcolumns)    
  end

  def self.activate!
    ActiveRecord::Base.class_eval { include ::SqlValuedColumns }
  end

  module ClassMethods
    
    def sql_column(column, function, *args)
      options = args.extract_options!
      raw = options[:raw] || false
      @sql_columns ||= { }
      @sql_columns[column] = [function, args, raw]
    end

    def sql_columns
      @sql_columns ||= { }
    end
    
  end

  module InstanceMethods
    
    def attributes_with_quotes_with_sqlcolumns(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
      quoted = {}
      connection = self.class.connection
      attribute_names.each do |name|
        if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
          value = read_attribute(name)

          # We need explicit to_yaml because quote() does not properly convert Time/Date fields to YAML.
          if value && self.class.serialized_attributes.has_key?(name) && (value.acts_like?(:date) || value.acts_like?(:time))
            value = value.to_yaml
          end

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
                    str = val('"' + str + '"')
                  end
                  connection.quote(str)
                else
                  connection.quote(a)
                end
              end
              quoted[name] = "#{function}(#{fmt_args.join(",")})"
            else
              quoted[name] = function
            end
          else
            quoted[name] = connection.quote(value, column)            
          end

        end
      end
      include_readonly_attributes ? quoted : remove_readonly_attributes(quoted)
    end
    
  end


  
end

