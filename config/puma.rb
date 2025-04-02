# config/puma.rb
# frozen_string_literal: true

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

port        ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")

# Use clustered mode with workers for multi-core performance
workers ENV.fetch("WEB_CONCURRENCY", 2).to_i

# Load the app before forking for better memory efficiency
preload_app!

# Re-establish DB connection per worker
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Allow puma to be restarted by `rails restart`
plugin :tmp_restart
