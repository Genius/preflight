class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked
end
