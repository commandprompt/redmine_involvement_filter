module RedmineInvolvementFilter
  module IssueQueryPatch
    unloadable

    def self.included(base)
      base.class_eval do
        alias_method_chain :available_filters, :involvement
      end
    end

    def available_filters_with_involvement
      return @available_filters if @available_filters

      available_filters_without_involvement

      if User.current.logged?
        filter = @available_filters['involved_user_id'] = @available_filters['assigned_to_id'].dup
        filter[:name] = l('field_involved_users')
        filter[:type] = :list
      end

      @available_filters
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

      journalized_issue_ids_sql = %(
SELECT DISTINCT journalized_id
  FROM #{Journal.table_name}
 WHERE journalized_type='Issue'
   AND user_id IN #{user_ids}
)
      watched_issue_ids_sql = %(
SELECT DISTINCT watchable_id
  FROM #{Watcher.table_name}
 WHERE watchable_type='Issue'
   AND user_id IN #{user_ids}
)

      sql = ["#{Issue.table_name}.assigned_to_id #{inop} #{user_ids}",
             "#{Issue.table_name}.author_id #{inop} #{user_ids}",
             "#{Issue.table_name}.id #{inop} (#{journalized_issue_ids_sql})",
             "#{Issue.table_name}.id #{inop} (#{watched_issue_ids_sql})"].join(" #{cond} ")

      "(#{sql})"
    end
  end
end
