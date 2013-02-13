PikatagDemoApp::Application.routes.draw do

  root to: "home#index"

  resources :items, only: [:index, :new, :create]
end
