Rails.application.routes.draw do
  post 'handle' =>  'handler#handle'
  post 'enqueue' => 'handler#enqueue'
  get 'health' => 'health_check#haiku'
end
