Rails.application.config.hosts << ENV.fetch('CANONICAL_DOMAIN')

DelayedJobWeb.class_eval do
  set :host_authorization, :allowed_hosts => Rails.application.config.hosts
end
