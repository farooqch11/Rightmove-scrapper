schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

#Sidekiq::Logging.logger.level = Logger::DEBUG
Sidekiq::Extensions.enable_delay!

# Sidekiq.configure_server do |config|
#   config.error_handlers << Proc.new {|ex, ctx_hash| ErrorService.notify(ex, ctx_hash) }
# end