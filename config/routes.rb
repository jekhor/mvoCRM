MvoCRM::Application.routes.draw do
  devise_for :members, :path_prefix => 'd'
  devise_for :admins, :path_prefix => 'd'
  resources :admins

  get "admin", to: redirect("d/admins/sign_in")

  get "pages/home"

  get "pages/help"

  post "payments/remind_debtors"
  get "payments/hg_notify"
  resources :payments
  get "payments/new/:for_member(.:format)" => 'payments#new', :as => :new_payment_for

  get "members/send_test_email"
  get "members/count"
  post "members/accept_selected"
  post "members/register"
  post "members/register_new"
  get "members/:id/pay" => "members#pay", as: 'member_pay'
  get "members/pay" => "members#pay"
  post "members/:id/checkout" => "members#checkout", as: 'member_checkout'
  resources :members

  get 'checkouts/return'
  get 'checkouts/notify'
  post 'checkouts/notify'

  get "letters/make_letter" => "letters#make_letter"
  post "letters/letter" => "letters#letter"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#home'
  get '/help' => 'pages#help'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
