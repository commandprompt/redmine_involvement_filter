require 'redmine'

Redmine::Plugin.register :redmine_involvement_filter do
  name 'Redmine Issue Involvement Filter plugin'
  author 'Alex Shulgin <ash@commandprompt.com>'
  description 'A plugin to filter out issues in which the current user is involved.'
  version '0.2.0'
#  url 'http://example.com/path/to/plugin'
#  author_url 'http://example.com/about'
end

prepare_block = Proc.new do
  IssueQuery.send(:include, RedmineInvolvementFilter::IssueQueryPatch)
end

if Rails.env.development?
  ActionDispatch::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end
