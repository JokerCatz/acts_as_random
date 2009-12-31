module ActiveRecord
  module Acts
    module Random
      def self.included(base)
        base.extend(ClassMethods)
      end
      module ClassMethods
        def acts_as_random(options = {})
          configuration={:count => 3}
          configuration.update(options) if options.is_a?(Hash)
          class_eval <<-EOV
            def self.pick(conditions = "true")
              temp_class = has_parent_class?
              return self.find_by_sql("SELECT * FROM \#{self.table_name} as r1 JOIN (SELECT CEIL(RAND() * (SELECT MAX(id) FROM \#{self.table_name})) AS gid) AS r2 WHERE r1.id >= r2.gid AND \#{conditions} ORDER BY r1.id ASC LIMIT 1;").first unless temp_class
              return self.find_by_sql("SELECT * FROM \#{temp_class.table_name} as r1 JOIN (SELECT CEIL(RAND() * (SELECT MAX(id) FROM \#{temp_class.table_name})) AS gid) AS r2 WHERE r1.id >= r2.gid AND type = '\#{self.to_s}' AND \#{conditions} ORDER BY r1.id ASC LIMIT 1;").first
            end
            def self.picks(limit = configuration[:count] , conditions = "true")
              temp = []
              limit.times do
                temp << self.pick(conditions)
              end
              return temp
            end
            def self.has_parent_class?
              unless self.superclass == ActiveRecord::Base
                flag = self
                flag = flag.superclass while flag.superclass != ActiveRecord::Base
                return flag
              end
              return false
            end
          EOV
        end
      end
    end
  end
end
