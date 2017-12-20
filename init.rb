require 'redmine'

Redmine::Plugin.register :redmine_involvement_filter do
  name 'Redmine Issue Involvement Filter plugin'
  author 'Alex Shulgin <ash@commandprompt.com>'
  description 'A plugin to filter out issues in which the current user is involved.'
  version '0.2.1'
  url 'https://github.com/commandprompt/redmine_involvement_filter'
  author_url 'https://commandprompt.com'
end

prepare_block = Proc.new do
  Query.send(:include, RedmineInvolvementFilter::QueryPatch)
end

if Rails.env.development?
  ActionDispatch::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end
