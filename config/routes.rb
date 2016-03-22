Rails.application.routes.draw do
  post 'handle' =>  'handler#handle'
  post 'enqueue' => 'handler#enqueue'
end
