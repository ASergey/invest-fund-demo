Sidekiq.default_worker_options = {
  retry: 0,
  unique: :until_executing,
  unique_args: ->(args) { [ args.first.except('job_id') ] }
}

Sidekiq.configure_client do |config|
  config.redis = { size: 2 }
end

Sidekiq.configure_server do |config|
  config.redis = { size: 24 }
  # Avoid autoload issue such as 'uninitialized constant Mail::Parsers::ContentTypeParser'
  # https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting
  Mail.eager_autoload! if Rails.env.production? && defined?(Mail)
end