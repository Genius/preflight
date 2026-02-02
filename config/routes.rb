Rails.application.routes.draw do
  root to: 'static#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :checklists do
    resources :checklist_items, only: [:create, :update, :destroy]
  end

  resources :github_repositories, only: :show

  post '/github/webhook', to: 'webhooks#github', as: :github_webhook

  authenticated :user, ->(user) { user.admin? } do
    mount DelayedJobWeb, at: "/delayed_job"
  end
end
