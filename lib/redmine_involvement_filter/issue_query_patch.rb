module RedmineInvolvementFilter
  module IssueQueryPatch
    unloadable
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # alias_method_chain :available_filters, :involvement
        alias_method_chain :initialize_available_filters, :involvement_filter
      end
    end

    module InstanceMethods
      def initialize_available_filters_with_involvement_filter
        initialize_available_filters_without_involvement_filter
        add_involvement_filter if User.current.logged?
      end

      def add_involvement_filter
          add_available_filter 'involved_user_id',
                               type: :list,
                               name: l('field_involved_users'),
                               values: lambda { assigned_to_values }
      end

      def sql_for_involved_user_id_field(field, operator, value)
        value.push(User.current.id.to_s) if value.delete("me") && User.current.logged?
        user_ids = '(' + value.map(&:to_i).join(',') + ')'

        if operator == '='
          inop = 'IN'
          cond = 'OR'
        else
          inop = 'NOT IN'
          cond = 'AND'
        end

        issue_ids_sql = %(
                          SELECT DISTINCT journalized_id
                            FROM #{Journal.table_name}
                           WHERE journalized_type='Issue'
                             AND user_id IN #{user_ids}
                          )
        sql = ["#{Issue.table_name}.assigned_to_id #{inop} #{user_ids}",
               "#{Issue.table_name}.author_id #{inop} #{user_ids}",
               "#{Issue.table_name}.id #{inop} (#{issue_ids_sql})"].join(" #{cond} ")

        "(#{sql})"
      end
    end
  end
end
