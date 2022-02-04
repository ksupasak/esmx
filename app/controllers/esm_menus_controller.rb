class EsmMenusController < EsmDevController

  

def index
  @project = Project.find(params[:id])
  @menu_actions = @project.menu_actions
  render_to_panel :partial=>'index.html'
  
end


def menu_action_params
  params.require(:menu_action).permit(:name,:label,:acl,:parent_id,:url,:published,:sort_order,:esm_id,:project_id)
end

def new
  @project = Project.find(params[:id])
  @menu_action = @project.menu_actions.new
  if request.post?
    @menu_action = @project.menu_actions.create menu_action_params
    reload_workspace :action=>'edit',:id=>@menu_action
  else
    render_to_panel :partial=>'new.html'
  end
end

def edit
  @menu_action = MenuAction.find(params[:id])
  @project = @menu_action.project
  if request.post?
    @menu_action.update menu_action_params
    reload_workspace
  else
    render_to_panel :partial=>'edit.html'
  end
end

def destroy
  @menu_action = MenuAction.find(params[:id])
  @project = @menu_action.project
  @menu_action.destroy
  reload_workspace :action=>'index',:id=>@project
end

end