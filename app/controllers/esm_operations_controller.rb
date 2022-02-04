class EsmOperationsController < EsmController

  before_action :login_required
  layout 'esm_application'
  
  before_action :workspace
  def workspace
      params[:update]='workspace' unless params[:update]
  end
  
  def reload_workspace urls = nil
    
    @url = url_for urls if urls
     
     render_to_panel :partial=>'/esm_home/reload_workspace.html'
      
  end

  def operation_params
    params.require(:operation).permit(:title,:name,:template_id,:command, :acl)
  end
  
  def new  
        @service =Service.find(params[:id])
        @project = @service.project
        @operation = @service.operations.new   
        @operation.template_id = params[:template_id] if params[:template_id]
        if request.post?
                if params[:commit]=='Default'
                  if @service.extended ==''
                    template = ScriptTemplate.find(params[:operation][:template_id]).template
                  else
                    s = Service.get @service.extended
                    if s and op = s.operations.find_by_name(params[:operation][:name])
                       template = op.command
                    end 
                    
                  end 
                  params[:operation][:command] = template 
                end
                @operation.assign_attributes  operation_params
                @operation.save
               reload_workspace :controller=>'esm_services',:action=>'show',:id=>@service
        else  
          render_to_panel :partial=>'new.html'
        end
  end
  
  def show
     @operation = Operation.find(params[:id]) 
      @service = @operation.service
      @project = @service.project
     render_to_panel :partial=>'edit.html'
  end
  
  def edit
          @operation = Operation.find(params[:id]) 
          @service = @operation.service
          @project = @service.project
          params[:update]='operation_panel'
          
          if request.post?
                  if params[:commit]=='Default'
                    template = ScriptTemplate.find(params[:operation][:template_id]).template 
                    params[:operation][:command] = template 
                  end
                  @operation.assign_attributes operation_params #params[:operation]
                  if @operation.save     
                  end
                  params[:op_id]=@operation.id
                  if params[:commit]=='Test'
                    render_to_panel :partial=>'/esm_services/updated.html'
                  else
                    # render :text=>'alert("Updated")'
                    params[:update]='update-panel'
                    render_to_panel :partial=>'/esm_services/updated.html'
                  end
          else
            unless params[:sid].to_i!=@service.id  
              render_to_panel :partial=>'edit.html'
            else
              
              @service =  Service.find(params[:sid]) 
              render_to_panel :partial=>'override.html'
              
            end
          end          
          
  end


  def destroy
          @operation = Operation.find(params[:id]) 
          @service = @operation.service
          @project = @service.project
          @operation.destroy
          reload_workspace :controller=>'esm_services',:action=>'show',:id=>@service
  end
  
  def operation_params
    params.require(:operation).permit(:name,:service_id,:template_id,:command,:description,:auto_test,:snippet,:title,:acl)
  end
  
  
end