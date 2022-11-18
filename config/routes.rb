require 'resque/server'
Esmx::Application.routes.draw do
  

          mount Resque::Server.new, :at => "/resque"

    
    
          get "/500", :to=>"errors#internal_error"
    
    

         match 'home/:action'=>'home', via: [:get, :post]

         resources :esms
         resources :menu_actions
         resources :settings
         resources :users
         resources :roles
         resources :permissions
         resources :logs
         resources :projects
         resources :services
         resources :operations
         resources :script_templates

         # match 'esm/:esm/:project/:service/:opt' =>'esm_proxy#index'
         get 'barcode' =>'esm_image#barcode'
         match 'content/esm/*package/:id(.:format)'=>'esm_attachments#show' ,via: [:get, :post]
         match 'content/data/*package/:id/:filename(.:format)'=>'esm_attachments#show' ,via: [:get, :post]
         # match 'content/esm/:solution_name/:project_name/*package/:id(.:format)'=>'esm_attachments#show' ,via: [:get, :post]


         match 'esm/*package/:opt' =>'esm_proxy#index' ,via: [:get, :post]


         match 'user'=>'user#index' ,via: [:get, :post]
         match 'user/:action'=>'user' ,via: [:get, :post]
         match 'elfinder' => 'esm_content#elfinder' ,via: [:get, :post]

         match 'manage/:model'=>'manage#index' ,via: [:get, :post]
         post  'manage/:model'=>'manage#create' 
         match 'manage/:model/new'=>'manage#new' ,via: [:get, :post]
         match 'manage/:model/create'=>'manage#create',via: [:get, :post]
         match 'manage/:model/:id'=>'manage#show' ,via: [:get, :post]
         post  'manage/:model/:id'=>'manage#update'
         put   'manage/:model/:id'=>'manage#update'
         delete 'manage/:model/:id'=>'manage#destroy'
         match  'manage/:model/destroy/:id'=>'manage#destroy' ,via: [:get, :post]
         match  'manage/:model/:id/:action'=>'manage' ,via: [:get, :post]

         match 'esm_home/:action'=>'esm_home' ,via: [:get, :post]
         match 'esm_home/:action/:id'=>'esm_home' ,via: [:get, :post]
         match 'esm_home'=>'esm_home#index' ,via: [:get, :post]

         match 'esm_content/:id'=>'esm_content#show' ,via: [:get, :post]
         match 'esm_content/:id/:action'=>'esm_content' ,via: [:get, :post]


         match 's/:service/:opt' =>'esm_proxy#index' ,via: [:get, :post]
         match 's/:service' =>'esm_proxy#index', :opt=>'index' ,via: [:get, :post]

         match 'ws/:service/:opt' =>'esm_proxy#ws' ,via: [:get, :post]
         match 'ws/:service' =>'esm_proxy#ws', :opt=>'index' ,via: [:get, :post]

         match 'admin/:id'=>'admin#show' ,via: [:get, :post]
         match 'admin/:id/:action'=>'admin' ,via: [:get, :post]



         # match ':controller'=>':controller#index' ,via: [:get, :post]
         # match ':controller/new',:action=>'new' ,via: [:get, :post]
        #  post  ':controller/create',:action=>'create'
        #  match ':controller/edit',:action=>'edit' ,via: [:get, :post]
        #  match ':controller/update',:action=>'update' ,via: [:get, :post]
        #
        #  match ':controller/destroy/:id',:action=>'destroy' ,via: [:get, :post]
         # match ':controller/:id',:action=>'show' ,via: [:get, :post]
         # match ':controller/:id/:action' ,via: [:get, :post, :patch]

         match ':solution_name/:project_name/:service/:opt'=>'esm_proxy#index' ,via: [:get, :post,:delete, :put]
         
         match ':solution_name/:project_name/:service/*id/:opt'=>'esm_proxy#index' ,via: [:get, :post,:delete, :put]
         
         
         
         resources :esm_projects
         match 'esm_projects/:id/edit', to:'esm_projects#edit', via: [:get, :post]
         match 'esm_projects/:id/add_setting', to:'esm_projects#add_setting', via: [:get, :post]
         match 'esm_projects/:id/delete_setting', to:'esm_projects#delete_setting', via: [:get, :post]
         
         
         match 'esm_projects/:id/services', to:'esm_services#index', via: [:get, :post]
         match 'esm_projects/:id/documents', to:'esm_documents#index', via: [:get, :post]
         match 'esm_projects/:id/models', to:'esm_tables#index', via: [:get, :post]
         match 'esm_projects/:id/menus', to:'esm_menus#index', via: [:get, :post]
         
         
         match 'esm_services/new', to:'esm_services#new', via: [:get, :post]
         match 'esm_documents/new', to:'esm_documents#new', via: [:get, :post]
         match 'esm_tables/new', to:'esm_tables#new', via: [:get, :post]
         match 'esm_menus/new', to:'esm_menus#new', via: [:get, :post]
         
         
         match 'esm_operations/new', to:'esm_operations#new', via: [:get, :post]
         match 'esm_operations/:id/edit', to:'esm_operations#edit', via: [:get, :post]
         
        
         match 'esm_documents/:id'=>'esm_documents#show',via: [:get, :post]
         match 'esm_documents/:id/edit_layout'=>'esm_documents#edit_layout',via: [:get, :post]
         match 'esm_documents/:id/edit_field'=>'esm_documents#edit_field',via: [:get, :post]
         match 'esm_documents/:id/edit_tree'=>'esm_documents#edit_tree',via: [:get, :post]
         
         match 'esm_documents/:id/field_edit'=>'esm_documents#field_edit',via: [:get, :post]
         
         match 'esm_image/:id/snap' =>'esm_image#snap', via: [:post]
         match 'esm_image/:id/attach_to_gallery'=>'esm_image#attach_to_gallery',via: [:get, :post]
         match 'esm_image/:id/snap_update', to:'esm_image#snap_update', via: [:get, :post]
         match 'esm_image/:id/snap_restore', to:'esm_image#snap_restore', via: [:get, :post]
         
         match 'esm_tables/:id/edit', to:'esm_tables#edit', via: [:get, :post]
         
         
   
         # match 'esm_projects/show'=>'esm_projects#show',via: [:get, :post]
         # match 'esm_projects/:id'=>'esm_projects#show',via: [:get, :post]
         # match 'esm_projects/:id/:action'=>'esm_projects',via: [:get, :post]
         #
         # match 'esm_projects/:id',to:'esm_projects#show', via: [:get, :post]
         # match 'esm_projects/:id/edit',to:'esm_projects#edit', via: [:get, :post]
         #
         
         
         
         # match ':solution_name/:project_name/:service/*id'=>'esm_proxy#index' ,via: [:get, :post,:delete, :put]
        match 'esm_services/:id'=>'esm_services#show',via: [:get, :post]
        match 'esm_services'=>'esm_services#index',via: [:get, :post]
        match 'esm_services/:id/:action'=>'esm_services',via: [:get, :post]
        
        
        match 'esm_documents'=>'esm_documents#index',via: [:get, :post]
        match 'esm_menus'=>'esm_menus#index',via: [:get, :post]
        match 'esm_menus/:id/:action'=>'esm_menus',via: [:get, :post]
        
        
        match 'esm_tables'=>'esm_tables#index',via: [:get, :post]
        match 'esm_documents/:id'=>'esm_documents#show',via: [:get, :post]
        match 'esm_tables/:id'=>'esm_tables#show',via: [:get, :post]
        
        match 'esm_operations/:id/new'=>'esm_operations#new',via: [:get, :post]
        match 'esm_operations/:id/:action'=>'esm_operations',via: [:get, :post]
        match 'script_templates'=>'script_templates#index',via: [:get, :post]
        match 'esm_attachments/:id/:action'=>'esm_attachments',via: [:get, :post]
          
         
         match ':solution_name/:project_name'=>'esm_proxy#home',via: [:get, :post]

         match ':project_name/:service/:opt'=>'esm_proxy#index',via: [:get, :post,:delete, :put]
         match ':project_name/:service/:opt'=>'esm_proxy#index',via: [:get, :post,:delete, :put], :constraints => lambda { |req| req.format == :json }
         match ':project_name/:service/:opt'=>'esm_proxy#index',via: [:get, :post,:delete, :put], :constraints => lambda { |req| req.format == :shtml }
         
         

         # match ':project_name'=>'esm_proxy#home'

         match ':content'=>'home#content' ,via: [:get, :post]


    root :to => "home#index"
    match ':controller(/:action(/:id(.:format)))' ,via: [:get, :post]
    
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
