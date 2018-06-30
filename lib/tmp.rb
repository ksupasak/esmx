# encoding: utf-8

class EsmSuperClass 
  
      attr_accessor :params,:context,:view

      def initialize context=nil
        @context = context
        @params = context[:params]
        @current_project =context[:project]
        @current_solution = @current_project.esm
      end

      def context
        @context
      end

      def params
        @params
      end

      def render_template command, this, p, layout=false        
        if layout
          command = "<% content_for :context_menu do %>
#{context_menu}
 <% end %>
<% content_for :content do %>
#{command}
 <% end %> <% this = @context[:delegate] if @context[:delegate] %>#{self.layout}<%=include_essential%>"
        end
        @command = command
         ctype = 'text/html'
         ctype = params[:content_type] if params[:content_type]
         
      (@context[:controller]).render(:inline=>command,:content_type=>ctype,:locals=>{:command=>command,:this=>this,:context=>@context,:params=>params})[0]
     end
      
      
      
      def layout
        if @context 
          home_service = @context[:project].get_service  'home'
          s = home_service.load @context 
          l = s.layout
          @context[:delegate] = s
          return l
        end
        return '<%=yield :content%>'  
      end
      
      def context_menu
        return ''        
      end
      
      def method_missing m, *params, &block
        return "No service"
      end
end

class Homeemrehr < EsmSuperClass

    def initialize context=nil
       super context
    end

    def local_class name
      "'#{self.class.name}::#{name}'"
    end


        def index *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
  module_name = @current_project.name
 if params[:date]
  session[module_name]={:date=>params[:date]}
 end
 if session[module_name]
    params[:date] = session[module_name][:date]
 end
 unless params[:date]
 params[:date] = Time.now.strftime('%d/%m/%Y')
 end
%>
<%#session[module_name].inspect %>
<%

 if params[:obj_id]
 now = Time.now 

 

 
 
%>
<meta http-equiv="Refresh" content="0; url=../Appointment/create?patient_id=<%=params[:obj_id]%>&data[date]=<%=now.strftime('%Y-%m-%d')%>&data[start]=<%=now.strftime('H:M')%>&data[stop]=<%=now.strftime('H:M')%>">
<%
 end
%>

<div class="row-fluid">
<div class="span8">
<div class="w-box">
    <div class="w-box-header">
       Dashboard
    </div>  
    <div class="w-box-content cnt_a">
<center><b>Welcome to <span style="color:#F3790D">EMR</span>-LIFE, <%= @current_project.title %> Module</b></center><br/>

<center>

<a href="../Appointment/create?return=../Home/index"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-add"></i><br />Appointment</button></a>

<!--<a href="../../www/Patient/create?return=../../<%=@current_project.name%>/Home/index"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-add"></i><br /> New Patient</button></a>
-->
<a href="../Appointment/index"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-calendar_month"></i><br />Appointment</button></a>
<a href="report"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-view_outline_detail"></i><br />Reports</button></a>
<!--<a href="status_feed"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-view_outline_detail"></i><br />Status</button></a>
-->
<%
if false
%><a href="attachment"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-view_outline_detail"></i><br />Attachments</button></a>
<% end %>
</center>
    </div>
    </div>
</div>
<div class="span4">
<div class="w-box">
    <div class="w-box-header">
        Status
    </div>  
    <div class="w-box-content cnt_a" style="padding-bottom:0px">
        <div class="alert alert-block alert-info" >
                
        <%
       begin        
            date = Time.now
            date = Date.strptime(params[:date], '%d/%m/%Y') if params[:date]
        %>
                Date <%= text_field_tag 'date',date,:id=>'today-date',:onchange=>'alert',:style=>'width:120px' %> <%=link_to "( Today Click )", "../Home/index?date=\#{Time.now.strftime('%d/%m/%Y')}" %><br/>

        <h1><%= Time.now.strftime("%H : %M") %></h1>
        
       <%= date.strftime('%A %d %B %Y')%><br/>

        </div>

    <script>
    $("#today-date").kendoDatePicker({
        value: '<%= date.strftime("%d/%m/%Y") %>',
        change: function(){
            window.location = "../Home/index?date="+kendo.toString(this.value(), 'd')
        }
	});
</script>
<% rescue %>
  error
<% end %>
    </div>
    </div>
</div>
</div>

<div class="clear"></div>
<br/>


<style>
.status_cls{
width:100px
}
</style>
<script>
function change_status(obj){
  if(confirm("Are you sure to update status to "+obj.value + " ?")){
   window.location="update_status?id="+obj.id+"&status="+obj.value;
  }
 }
</script>
<%
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    patients = [] 
    mname = "\#{@current_project.name}#appointment"
   # patients =  module_model.all(:module_name=>mname)
    status_list=%w{appointed waiting processing recovery completed cancelled no_show}.collect{|i| i.humanize}
   
    
    models = get_model
    ap_model = models[:appointment]
    p_model = models[:provider]
    v_model = models[:visit_type]
    

    
    visits = {}
    v_model.all.each do |i|
        visits[i.id]=i.name
    end
    indications = {}
    models[:indication].all.each do |i|
        indications[i.id]=i.name
    end
    
    aps = ap_model.all(:date.gte=>date.at_beginning_of_day,:date.lt=>date.end_of_day) 
    for a in aps
        a.update_attributes :status=>'Completed' if a.status==''
    end
    %>
    <%# aps.inspect %>
    <%
    
    
    list = aps.clone
    id = ''
    aps.collect!{|i| 
    id = i.id
      if m = module_model.first(:module_name=>mname,:module_id=>i.id)
         patient = patient_model.find(m.patient_id)
         provider = p_model.find(i.provider)
         visit_type = visits[i.visit_type]
         provider_name = '-'
         provider_name = provider.name if provider
         procedure_name = '-'
         pro = models[:procedure].find(i.procedure) 
         procedure_name = pro.name if pro
         patient = patient_model.new unless patient 
         hn = '-'
         hn = link_to(patient.hn, "../Appointment/show?id=\#{m.id}") if patient
         public_id = '-'
        # public_id = patient.public_id if patient
         c = {:ref_number=>m.ref_number,:public_id=>public_id,:hn=>hn,:patient=>link_to("\#{patient.prefix_name} \#{patient.first_name} \#{patient.last_name}","../../www/Patient/edit?id=\#{patient.id}&return=\#{request.fullpath}"),
         :provider=>provider_name,:date=>i.date,:note=>"\#{visit_type} \#{indications[i.indication]} \#{i.note}",:status=>i.status,:procedure=>procedure_name,
         :status_ctrl=>select_tag('name',options_for_select(status_list,i.status),:class=>'status_cls',:id=>i.id,:onchange=>'change_status(this)'),
         :pending_ctrl=>link_to('Arrived',"update_status?id=\#{i.id}&status=Processing",:class=>'btn btn-small btn-success'),
         :visit_type=>visit_type
         }
         
         if i.status=='Waiting'
         c[:pending_ctrl]=link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small ')+" "+link_to('Process',"update_status?id=\#{i.id}&status=Processing",:class=>'btn btn-small btn-success') 
        

         #c[:processing_ctrl]=link_to('Process',"update_status?id=\#{i.id}&status=Processing",:class=>'btn btn-small btn-success') 
         else
         status = 'btn-info'
         status = '' if i.status =='Completed'
         c[:processing_ctrl]=link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small '+status)
         end
         c
      end
    }.compact!
    
    waiting = aps.collect{|i| i if i[:status]=='Appointed' or  i[:status]=='Pending' or i[:status]=='Waiting'}.compact
    
    processing = aps.collect{|i| i if i[:status]=='Processing' }.compact
    
    completed = aps.collect{|i| i if i[:status]=='Recovery' or i[:status]=='Completed' }.compact
    
    cancelling = aps.collect{|i| i if i[:status]=='No show' or i[:status]=='Cancelled' }.compact
    
    
    table_model = %w{ hn patient provider procedure status_ctrl}.collect{|i| i.to_sym}
    
    #[:ref_number,:date,:patient,:provider,:status_ctrl,:note,:pending_ctrl]
    
    labels = {:hn=>'HN',:public=>'Public',:patient=>'Patient',:provider=>'Appointed Doctor',:status_ctrl=>'Status',:pending_ctrl=>'Appointed ctrl',
    :note=>'Note',:visit_type=>'Group' }
    
%>


<div style="width:100%;border:0px solid">
<div class="left" style="width:100%;">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
	        Today Patients 
     
	    <div class="pull-right"><i class=""><%=waiting.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        
           <% 
           
           for visit in visits.values
            tmp = waiting.collect{|w| w if  w[:visit_type]==visit }.compact
           %>
           <% if tmp.size>0 %>
           <%=visit%>
	        <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>tmp,:labels=>labels %>
            <% end %>  <% end %>
            
        <% if tmp = waiting.collect{|w| w if w[:visit_type]==nil }.compact and tmp.size>0 %>    
        <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>tmp ,:labels=>labels %>
        <% end %>
        </div>
    </div>
</div>
<div class="clear"></div>
<br/>

<%
    providers = {}
    
    for i in processing
        p = i[:provider]
        providers[p]=[] unless providers[p]
        providers[p] << i
    end
    

%>

<div class="left" style="width:100%;background:#d9edf7">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Processing 
	    <div class="pull-right"><i class=""><%=processing.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        <% providers.each_pair do |k,v| %>
        <%= k %><br/>
            <%= tabular :model=>table_model+[:processing_ctrl,:note],:data=>providers[k],:labels=>labels %>
        <% end %>
    </div>
    </div>
</div>




<div class="clear"></div>
<br/>
<%
    providers = {}
    
    for i in completed
        p = i[:provider]
        providers[p]=[] unless providers[p]
        providers[p] << i
    end
    

%>

<div class="left" style="width:100%;">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Completed 
        <div class="pull-right"><i class=""><%=completed.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        <% providers.each_pair do |k,v| %>
        <%= k %><br/>
            <%= tabular :model=>table_model+[:processing_ctrl,:note],:data=>providers[k],:labels=>labels %>
        <% end %>
    </div>
    </div>
</div>




<div class="clear"></div>
<br/>


<%
    providers = {}
    
    for i in cancelling
        p = i[:provider]
        providers[p]=[] unless providers[p]
        providers[p] << i
    end
    

%>
<div class="left" style="width:100%;">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Cancelled &amp; No show 
        <div class="pull-right"><i class=""><%=cancelling.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        <% providers.each_pair do |k,v| %>
        <%= k %><br/>
            <%= tabular :model=>table_model+[:note],:data=>providers[k],:labels=>labels %>
        <% end %>
    </div>
    </div>
</div>
<!--
<div class="left" style="width:50%">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Today Patients
	    <div class="pull-right"><i class=""></i></div>
	    </div>
	    <div class="w-box-content cnt_a">
	        content
        </div>
    </div>
</div>
-->


</div>
<br/>
<br/>

<hr/>
Links : <%= link_to 'Print Appointment','print_appointment?print[date]='+params[:date],:target=>'_blank' %> | 
<%= link_to 'Print Report','print_report?print[date]='+params[:date],:target=>'_blank' %> | 
<%= link_to 'Status Feed','status_feed?print[date]='+params[:date] %> |
<%= link_to 'Reset Locker','../Locker/reset' if @current_role=='admin' or @current_role=='developer' %>
<div class="clear"></div>
 </div><br/>
 

HTML
return render_template(com,self,params,true)

        end
    

        def layout *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%=default_layout%>
HTML
return com

        end
    

        def report *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    patients = [] #patient_model.all :select=>[:date]
    mname = "\#{@current_project.name}#appointment"
    patients =  module_model.all(:module_name=>mname)
    
    
    list = []
    
    
    
    list = module_model.collection.group({:keyf=>'function(doc){return {month:doc.date.getMonth(),name:doc.module_name};}',
          :reduce=>'function(curr,result){result.count++;}',
          :initial=>{:count=>0},
          :finalize=>'function(result){result.month=result.month}',
          :cond=>{:date=>{'$gte'=>Time.now.at_beginning_of_year()}}})
          
          
        columns=[]
        
    mlabels = %w{Jan Feb Mar Apr May Jun July Aug Sep Oct Nov Dec}    
   
    map = {}
    data = []
         
    if list.size>0    
    for i in list
    columns[i['month'].to_i]= mlabels[i['month'].to_i]
    name = i['name'].split('#')[1]
    map[name] = {'name'=>name.humanize, 'data'=>[]} unless map[name] 
    map[name]['data'][i['month'].to_i] = i['count'].to_i
    end
    end
    map.each_pair do |k,v|
    if k!='appointment'
        data<<v    
    end
    
    end
    
    
    
   
    columns = mlabels

%>

<%#list.inspect%>
<div class='span12' style='background:#FFF;padding:10px'>
<h3>Summary</h3>

<%

%>

<div id="chart" style="border:1px solid;width:100%;min-height:300px">
</div>


<br/>
</div>




            <script>
                function createChart() {
                    $("#chart").kendoChart({
                        theme: $(document).data("kendoSkin") || "default",
                        title: {
                            text: "Records by Months"
                        },
                        legend: {
                            position: "bottom"
                        },
                        chartArea: {
                            background: ""
                        },
                        seriesDefaults: {
                            type: "column"
                        },
                        series: <%=data.to_json.html_safe %>
                        ,
                        valueAxis: {
                            labels: {
                                format: "{0}"
                            }
                        },
                        categoryAxis: {
                            categories: <%=columns.to_json.html_safe%>
                        },
                        tooltip: {
                            visible: true,
                            format: "{0}"
                        }
                    });
                }

                $(document).ready(function() {
                    setTimeout(function() {
                        createChart();
                    }, 400);
                });
            </script>



HTML
return render_template(com,self,params,true)

        end
    

        def config *params
            @params = params[0] if params[0]
            ret = this = self
services =  @current_project.get_services_by_abstract('ehr.emr.Document').collect{|i| i if  i.name!='appointment' and i.name!='live_document' and i.name!='billing'}.compact
[{:name=>'Form',:open=>true,:actions=>services.collect{|i| {:name=>i.name.camelize,:service=>i.name,:link=>"../\\#{i.name.camelize}/index"}} }]



        end
    

        def context_menu *params
            @params = params[0] if params[0]
            ret = com=<<-HTML

<% 
modules = @current_project.documents
model = get_model
ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
patient = (ehr.load_model)[:patient]
#m = modules.collect{|i| {:name=>i.title,:link=>"../../\#{i.name}/Home/index",:remote=>false} }
m = []
m <<  {:name=>'Back to Home',:link=>"index",:remote=>false}
obj = this.config
obj << {:name=>'Links',:open=>true,:actions=>m}
%>
<% services =  @current_project.get_services_by_abstract('ehr.emr.Document') %>
<%= show_menu obj %>

HTML
return com

        end
    

        def update_status *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
Status updated
<%
  date = ""
  ap = get_model[:appointment].find(params[:id])
  if ap
  ap.update_attributes :status=>params[:status]
%>
<META HTTP-EQUIV="Refresh" CONTENT="0;URL=index<%=date%>">
<%
end 
%>

HTML
return render_template(com,self,params,true)

        end
    

        def patient_record *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<% Time.zone =  get_setting 'time_zone' %>
<style>
body { min-width:0px; }
.gebo-fixed { background-color:#f5f5f5; }
#sidebar_bt {display:none }
</style>
<div class="row-fluid">
<div class="span12">
<div class="w-box">
    <div class="w-box-header">
        Patient Records
        <div class="pull-right">
        <%=link_to('<< Back','index',:class=>'btn btn-mini')%>
        </div> 
    </div>  
    <div class="w-box-content cnt_a">
    
<%

    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    ehr_models = ehr.get_model
    patient_model = ehr_models[:patient]
    patient_module_model = ehr_models[:patient_module]
    
    emr_models = get_model
    ap = emr_models[:appointment].find(params[:id])
    pm = patient_module_model.first(:module_id=>ap.id.to_s)
    locker_model = emr_models[:locker]
    if params[:reset_lock]
        l = locker_model.find(params[:reset_lock])
        l.destroy if l
    end
    #locker_model.where(:session=>session[:session_id]).all.each do |i|
    #i.destroy if i
    #end
     
    
    
    if pm
    
    if  params[:schema_patient_module]
       pm.update_attributes params[:schema_patient_module]
    end
    
    if params[:provider_id]
      ap.update_attributes :provider=>params[:provider_id]
       ap = emr_models[:appointment].find(params[:id])
     end
    
    # find provider
    provider = emr_models[:provider].find(ap.provider.to_s)
    
    # find patient
    patient = patient_model.find(pm.patient_id)
    
    params[:patient]=patient
    params[:patient_module]=pm
    
   # s = Service.get('ehr.emr.EmrHelper')
#    obj = s.load context
    
    providers = emr_models[:provider].where(:provider_type=>'1').all
    
%>

<% services =  @current_project.get_services_by_abstract('ehr.emr.Document').collect{|i| i if  i.name!='appointment' and i.name!='live_document' and i.name!='billing'}.compact %>
<div style="border:0px solid">
<div class="document-border" style="border:0px solid; width:100%; padding:0px;max-width:688px">
<%# render :inline=>obj.show_patient %>
<div id="patient">
...
</div>
<script>
<%
        url = '../../www/Patient/search_result?'
        url += '&id='+patient.id.to_s
  %>      
        $.ajax({
    	  url: '<%=url.html_safe%>',
		 success: function(data){
          $('#patient').html(data);  
		  }
		});
</script>
<br/>
<%


previous = patient_module_model.all(:patient_id=>patient.id,:id=>{"$ne" => pm.id},:module_name=>pm.module_name,:order=>'date desc')
history = []
x = previous[0..7]
last = []
last = x.compact if x
history = []
y = previous[8..-1]
history = y.compact if y and  previous.size>5
                                     
current = time_ago_in_words(ap.date)
current_date = ap.date.strftime("%d-%m-%y")
current = 'Today' if current_date == Time.now.strftime("%d-%m-%y")

%>



<div class="clear"></div>
<div class="tabbable">
    							<ul class="nav nav-tabs">
									<li class="active"><a href="#a<%=pm.id%>" data-toggle="tab"><%=current%><br/><%=current_date%></a></li>
                                    <%
                                    
                                    
                                     for i in last 
                                    %>
                                	<li><a href="#a<%=i.id%>" data-toggle="tab"><%=time_ago_in_words(i.date)%><br/><%=i.date.strftime("%d-%m-%y") if i.date%></a></li>
									<% end %>
                                    <% if history.size>5 %>
                                    <li class="dropdown">
										<a href="#" data-toggle="dropdown" class="dropdown-toggle">History<b class="caret"></b></a>
										<ul class="dropdown-menu">
                                            <% for j in history %>
											<li><a href="#a<%=j.id%>" data-toggle="tab"><%=j.date.strftime("%d-%m-%y") if j.date%> : <%=time_ago_in_words(j.date)%></a></li>
                                            <% end %>
											<li class="divider"></li>
										</ul>
									</li>
                                    <% end %>
								
                                </ul>



<div class="tab-content">
<div class="tab-pane active" id="a<%=pm.id%>">


<h4><%= @current_project.title %> Records</h4>
<hr/>
<table class="table table-striped table-bordered">
<thead>
<tr><th></th><th>Forms</th><th>Records</th><th></th></tr>
</thead>

<%
groups = this.config
if true
for g in groups 
   services = g[:actions].collect{|i| @current_project.get_service i[:service]}.compact
%>
<tr><td colspan="4"><%=g[:name]%></td></tr>
<% services.each_with_index do |s,index|
    module_name = "\#{@current_project.name}#\#{s.name}"
    records = patient_module_model.all :module_name=>module_name, :parent_id=>pm.id,:patient_id=>pm.patient_id
%>
<tr><td><%= index+1 %>. </td><td> <%= s.title %></td>

<td align="center"><% for i in records %>
<%= link_to "\#{i.date.strftime("%d-%m-%Y") if i.date} \#{i.time.strftime("%H:%M") if i.time } - \#{i.ref_number}", "../\#{s.name.camelize}/show?id=\#{i.id}&return=\#{request.fullpath}" %>&nbsp;
<%= link_to "[ Edit ]", "../\#{s.name.camelize}/edit?id=\#{i.id}&record_name=\#{patient.hn}&return=\#{request.fullpath}" %>
<% end %>
</td>
<td>
<%  if records.size==0 %>
<%=link_to 'Create',"../\#{s.name.camelize}/create?patient_id=\#{patient.id}&record_name=\#{patient.hn}&parent_id=\#{pm.id}&return=\#{request.fullpath}" ,:class=>bt_class%>
<% else %>
<%=link_to 'Print',"../\#{s.name.camelize}/print?id=\#{i.id}&return=\#{request.fullpath}",:target=>'_blank' ,:class=>bt_class%>
<% end %>


<% 

    # locker = locker_model.where(:module_id=>pm.id.to_s,:module_name=>s.name,:created_at=>{'$lt'=>1.hours.ago}).first


    locker = locker_model.where(:module_id=>pm.id.to_s,:module_name=>s.name,:created_at=>{'$lt'=>1.hours.ago}).first
    if locker
    text = ''
    case locker.status
    when 'create'
        text='Creating..'
    when 'edit'
        text='Editing..'
    end
   user,role,solution_user = @current_solution.get_user_by_id locker.session
   
   
   %>


<%
   user_name = user.login.split("@")[0]
   user_name =  solution_user.name  if solution_user

   text += " by " + user_name if user_name
#   text += locker.session
%>

<%=image_tag '/gebo/img/ajax_loader.gif',:width=>30,:height=>30,:style=>'vertical-align:middle'%>&nbsp;<span><%=text.html_safe  %><span>
    <% end %>


</td>
<% end %>
</tr>

<% end %>
<% end %>
</table>
</div>

<% for i in previous 
 pm = i
%>
<div class="tab-pane" id="a<%=i.id%>">
<h4><%= @current_project.title %> Recrods</h4>
<hr/>
<table class="table table-striped table-bordered">
<thead>
<tr><th></th><th>Forms</th><th>Records</th><th></th></tr>
</thead>

<%
groups = this.config
if true
for g in groups 
   services = g[:actions].collect{|i| @current_project.get_service i[:service]}.compact
%>
<tr><td colspan="4"><%=g[:name]%></td></tr>
<% services.each_with_index do |s,index|
    module_name = "\#{@current_project.name}#\#{s.name}"
    records = patient_module_model.all :module_name=>module_name, :parent_id=>pm.id,:patient_id=>pm.patient_id
%>
<tr><td><%= index+1 %>. </td><td> <%= s.title %></td>

<td align="center"><% for i in records %>
<%= link_to "\#{i.date.strftime("%d-%m-%Y") if i.date} \#{i.time.strftime("%H:%M") if i.time } - \#{i.ref_number}", "../\#{s.name.camelize}/show?id=\#{i.id}&return=\#{request.fullpath}" %>&nbsp;
<%= link_to "[ Edit ]", "../\#{s.name.camelize}/edit?id=\#{i.id}&record_name=\#{patient.hn}&return=\#{request.fullpath}" %>
<% end %>
</td>
<td>
<%  if records.size==0 %>
<%=link_to 'Create',"../\#{s.name.camelize}/create?patient_id=\#{patient.id}&record_name=\#{patient.hn}&parent_id=\#{pm.id}&return=\#{request.fullpath}" ,:class=>bt_class%>
<% else %>
<%=link_to 'Print',"../\#{s.name.camelize}/print?id=\#{i.id}&return=\#{request.fullpath}",:target=>'_blank' ,:class=>bt_class%>
<% end %>

<br/>

</td>
<% end %>
</tr>

<% end %>
<% end %>
</table>


</div>
<% end %>

</div>
</div>


</div>
</div>
<% else %>
Data missing
<% end %>
</div>
</div>
</div>
</div>

<script>
$('title').html('<%=patient.hn%> <%=patient.first_name%> <%=patient.last_name%>')
</script>


 
HTML
return render_template(com,self,params,true)

        end
    

        def search *params
            @params = params[0] if params[0]
            ret = com=<<-HTML

<h1> Search Result </h1>
<hr/>
<% 
    models = get_model

    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    
    fields = %w{hn public_id first_name last_name}
    query = params[:query].strip
    
    
    
    hn_mode=false
    if i = query.index('/')
        t = query.split('/')
        query = "\#{t[0].to_i}/\#{t[1].to_i}"
        hn_mode = true  
    elsif query[0..-3].size>=4 and query.to_i !=0
        query = "\#{query[0..-3].to_i}/\#{query[-2..-1].to_i}"
        hn_mode = true  
    end
    
    # if query.size == 8 and query.index('/')==nil
    #   query = "\#{query[0..-3].to_i}/\#{query[-2..-1].to_i}" 
    # elsif query.index('/')
    
    # end
    
    
    keys = []
    # fields.each do |f| 
    #     keys <<{f.to_sym=>Regexp.new(query)}
    # end
    keys << {:hn=>query}

    
    unless hn_mode
    
    keys << {:first_name=>Regexp.new(query)}
    keys << {:last_name=>Regexp.new(query)}
    keys << {:public_id=>query} if query.size==13
    
    end
    
    criteria = {'$or'=>keys}
    
    patients = patient_model.where(criteria).limit(20).all  
    
    app_name = "\#{@current_project.name}#appointment"
    app_model = models[:appointment]

    if patients.size==1
        row = patients[0]
        ams = module_model.where(:module_name=>"\#{app_name}",:patient_id=>row.id).all.collect{|i| i.module_id }
        app = app_model.where(:id=>{'$in'=>ams},:status=>{'$nin'=>['Cancelled','No show']}).all :sort=>'date desc'
 
if app
  
#   app = app_model.where(:id=>am.module_id).first
  app = app[0]
  
  if @current_role!='pathologist'
  url = "../Home/patient_record?id=\#{app.id}"
  else
  url = "../Home/patho_patient_record?id=\#{app.id}"
  end

  if true
        
        %>
        <META HTTP-EQUIV="Refresh" CONTENT="0;URL=<%=url_for(url)%>">
        <%
        
    end
        
    end
   end
%>
<%= tabular :model=>fields,:data=>patients,:n=>10 do |row,out|

  am = module_model.where(:module_name=>"\#{app_name}",:patient_id=>row.id).order('date').last
if am
  app = app_model.where(:id=>am.module_id).first
  
  if @current_role!='pathologist'
  url = "../Home/patient_record?id=\#{am.module_id}"
  else
  url = "../Home/patho_patient_record?id=\#{am.module_id}"
  end
  
  out[0] = link_to(row.hn,url)
  out[1] = link_to(row.public_id,url)
  out[2] = link_to(row.first_name,url)
  out[3] = link_to(row.last_name,url)
  n = module_model.where(:module_name=>"\#{app_name}",:patient_id=>row.id).count
out << link_to("Select (\#{n})", url)
else
out<<'-'
end

out
end

%>

<hr/>
<%# hn_mode.inspect %>
<%#@current_role %>
HTML
return render_template(com,self,params,true)

        end
    

        def attachment *params
            @params = params[0] if params[0]
            ret = com=<<-HTML

<style>
.card{
    width:300px;
    float:left;
}

</style>

<%
   attachments  = get_model[:attachment].sort('created_at desc').all(:limit=>100)
   for i in attachments
%>
<div class="card">
<img src="<%= i.path%>" >
<%= i.id  %><br/>
<%= i.title  %><br/>
<%= i.created_at  %>
</div>
<% end %>


HTML
return render_template(com,self,params,true)

        end
    

        def status_feed *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
  @module_name = @current_project.name+'#appointment' 
  @ehr_project = @context.get_projects_by_abstract('ehr.ehr')[0]
  @patient_doc = @ehr_project.get_document 'patient'
  @module_doc = @ehr_project.get_document 'patient_module'
  @ehr_model = @ehr_project.get_model()
  @patient_model = @ehr_model[:patient]
  @module_model = @ehr_model[:patient_module]
  
  @models = get_model
  
  if this.table_name!='appointment' and params[:parent_id] 
  @appointment_module = @module_model.find(params[:parent_id])
  if @appointment_module
  @appointment = @models[:appointment].find(@appointment_module.module_id)
  end
  end 
  
  if params[:id] and  @patient_module = @module_model.find(params[:id])
     @patient = @patient_model.find(@patient_module.patient_id)
  end

  if params[:print] and params[:print][:date]
  
  date = Date.to_mongo(params[:print][:date])
 
  appointments =   @models[:appointment].where(:date=>date).all
 
 
  records = {}
 patients = {}
 providers = {}
 indications= {}
  visit_types= {}


 @module_model.where(:module_name=>@module_name, :module_id=>{'$in'=>appointments.collect{|i| i.id }}).all.each do |i|

  records[i.module_id]=i
 end
 
 @patient_model.find(records.values.collect{|i| i.patient_id}).each do |i|
 patients[i.id]=i
 end

 @models[:visit_type].all.each do |i|
 visit_types[i.id.to_s] = i
 end
 
 @models[:provider].all.each do |i|
 providers[i.id.to_s] = i
 end
 @models[:indication].all.each do |i|
 indications[i.id.to_s] = i
 end
 
     pro = {}
    @models[:procedure].all.each do |i|
    pro[i.id] = i.name
    end
    
    

    
json_data =   appointments.collect{|ap| 
 i  = records[ap.id]
 p = patients[i.patient_id]
 provider = providers[ap.provider.to_s]
 l = %w{#bcdeee}
 age = '-'
 if p.birth_date
     diff = Time.diff(date, p.birth_date)
    year = diff[:year]
    month = diff[:month]
    day = diff[:day]
    age = "\#{year} ปี \#{month} เดือน \#{day} วัน"
 end
 indication="-"
 visit_type="-"
 
indication = indications[ap.indication.to_s].name if indications[ap.indication.to_s]
 visit_type = visit_types[ap.visit_type.to_s].name if visit_types[ap.visit_type.to_s]
 
 
if true
    {'id'=>ap.id,
    'status'=>ap.status,
    'record'=>i.id,
    'hn'=> p.hn,
    'procedure'=>pro[ap.procedure],
    'date'=>ap.date.strftime("%Y-%m-%d"),
    'color'=>l[rand(4%l.size)],
    'provider'=>provider.name,
    'title'=>"\#{p.prefix_name if p } \#{p.first_name if p } \#{p.last_name if p }",
    'start'=>ap.date.strftime("%Y-%m-%d")+ap.start.strftime(" %H:%M"),
    'end'=>ap.date.strftime("%Y-%m-%d")+ap.stop.strftime(" %H:%M"),
    'indication'=>indication,
    'allDay'=>false,
    'url'=>'edit?id='+i.id.to_s,
    'age'=>age,
    'visit_type'=>visit_type,
    'tel'=>[p.tel_home,p.tel_office,p.mobile].collect{|i| i if i!=""}.compact.join(", "),
    'public_id'=>p.public_id
    }  
else
    nil
end 
}.compact

list = json_data.sort{|a,b| a['visit_type']<=>b['visit_type']}
 
%>
         
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>PRINT</title>
</head>
<style type="text/css" media="all">
html {

  
     }
value {color:#06F}
imvalue { color:#F00; font-weight:bold}
imvalue value { color:#F00; font-weight:bold}
#page {border:solid 1px;  border-color:#666;
-webkit-border-radius: 5px; /* Safari prototype */
-moz-border-radius: 5px; /* Gecko browsers */
border-radius: 5px; /* Everything else - limited support at the moment */
margin-bottom:5px; padding-bottom:5px; padding:33px}
#head { width:100%; height:60px;}
#logoleft { margin-left:20px; float:left;}
#logoright{ margin-right:20px; float:right;}
th              { font-weight: bolder; text-align: center }
caption         { text-align: center }
body            {   font-family: Arial, Helvetica, sans-serif; color:#000;font-size:25px; 


}
.wrapper{ width:95%;margin-left:auto;margin-right:auto} 
hr    {clear: both;border: none;border-top: 1px solid #AAA;border-bottom: 1px solid #FFF; font-size: 1px;line-height: 0;overflow: visible; width:98%;}
h1              { font-size: 2em; margin: .67em 0 }
h2              { font-size: 1.5em; margin: .83em 0 }
h3              { font-size: 1.17em; margin: 1em 0 }
p {color:#666;}
h4, p,
blockquote, ul,
form,
ol, dl          { margin: 0.5em; }
h5              { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }
h6              { font-size: .67em; margin: 2.33em 0 }

h4 { font-size:14pt; color:#333; height:16px;}
blockquote      { margin-left: 40px; margin-right: 40px }
i, cite, em,
var, address    { font-style: italic }
pre, tt, code,
kbd, samp       {  font-size:14px; }
pre             {margin:0;margin-left:1em; color:#666}
big             { font-size: 1.17em }
v {color:#2561cD;}
small, sub, sup { font-size: .83em }
ol, ul, dd      { margin-left: 40px }
ol              { list-style-type: decimal }
ol ul, ul ol,
ul ul, ol ol    { margin-top: 0; margin-bottom: 0 }
.clear{clear:both;}
@media print {
  @page         { width:90%; margin-top:0; }
  blockquote, 
 .wrapper{ width:100%;margin-left:auto;margin-right:auto} 
}

#box{
    width:150px;
    float:left;
    padding:10px;
    text-align:center;
    border:1px solid #ccc;
    -webkit-border-radius: 5px; /* Safari prototype */
    -moz-border-radius: 5px; /* Gecko browsers */
    border-radius: 5px; /* Everything else - limited support at the moment */    
    margin:10px;
}
.smm { border:1px solid;border-color:#ccc;}
#box img{
        width:150px;
}
label{
	color:#000;font-weight:bold;
	font-size: 2em;
}

table.table {
    
    color: #666;
    font-size: 2em;
    -moz-border-radius: 3px;
    -moz-box-shadow: 0 1px 2px #d1d1d1;
    -webkit-border-radius: 3px;
    -webkit-box-shadow: 0 1px 2px #d1d1d1;
    background: #eaebec;
    border: #ccc 1px solid;
    border-radius: 3px;
    box-shadow: 0 1px 2px #d1d1d1;
    font-family: Arial, Helvetica, sans-serif;
    text-shadow: 1px 1px 0px #fff;
}

table.table tr.even td {
    background: #f6f6f6;
    background: -webkit-gradient(linear, left top, left bottom, from(#f8f8f8), to(#f6f6f6));
    background: -moz-linear-gradient(top, #f8f8f8, #f6f6f6);
}

table.table th {
    padding: 21px 25px 22px 25px;
    border-bottom: 1px solid #e0e0e0; border-top: 1px solid #fafafa;
    background: #ededed;
    background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(#ebebeb));
    background: -moz-linear-gradient(top, #ededed, #ebebeb);
}

table.table th:first-child {
    padding-left: 20px;
    text-align: left
}

table.table a:visited {
    color: #999999;
    font-weight: bold;
    text-decoration: none
}

table.table a:active,
table.table a:hover {
    color: #bd5a35;
    text-decoration: underline
}

table.table a:link {
    color: #666;
    font-weight: bold;
    text-decoration: none
}

table.table tr {
    padding-left: 20px;
    text-align: center
}

table.table tr:first-child th:first-child {
    -moz-border-radius-topleft: 3px;
    -webkit-border-top-left-radius: 3px;
    border-top-left-radius: 3px;
}

table.table tr:first-child th:last-child {
    -moz-border-radius-topright: 3px;
    -webkit-border-top-right-radius: 3px;
    border-top-right-radius: 3px;
}

table.table tr:last-child td {    border-bottom: 0 }

table.table tr:last-child td:first-child {
    -moz-border-radius-bottomleft: 3px;
    -webkit-border-bottom-left-radius: 3px;
    border-bottom-left-radius: 3px;
}

table.table tr:last-child td:last-child {
    -moz-border-radius-bottomright: 3px;
    -webkit-border-bottom-right-radius: 3px;
    border-bottom-right-radius: 3px;
}

table.table tr:hover td {
    background: #f2f2f2;
    background: -webkit-gradient(linear, left top, left bottom, from(#f2f2f2), to(#f0f0f0));
    background: -moz-linear-gradient(top, #f2f2f2, #f0f0f0);
}

table.table tr td {
    padding: 18px;
    border-bottom: 1px solid #e0e0e0; border-left: 1px solid #e0e0e0; border-top: 1px solid #ffffff;
    background: #fafafa;
    background: -webkit-gradient(linear, left top, left bottom, from(#fbfbfb), to(#fafafa));
    background: -moz-linear-gradient(top, #fbfbfb, #fafafa);
}

table.table tr td:first-child {
    padding-left: 20px;
    border-left: 0;
    t
</style>
<body >
<div class="wrapper">


<div id="page">

<div class="row-fluid" style="width:100%">
<div class="span12" style="width:100%">



<div id="endoscopy_nurse" class="  portlet " >

<span><label>  Patient status : </label></span>

			<div style="margin-top:10px">
 <table width="100%" border="1" cellpadding="0" cellspacing="0" class="table">  
 
 <tr><th>No.</th>
 <th>H/N</th>
 <th>ชื่อ-สกุล</th>
 <th>Status</th></tr>         
<% list.each_with_index do |i,index|  %>
 <tr>  
<td><v><%=index+1%>.</v></td> <td><value><%=i['hn']%></value></td> <td>&nbsp;<value><%=i['title']%>  </value></td> <td>&nbsp;<value><%=i['status']%></value></td> 
 </tr>     
	
 <% end %>





</table></div>
</div>
</div>


	


<div class="clear">	</div>	
	


</div>

<div class="clear">	</div>	

</div>

</div>



<div class="clear"></div>
</div>
<!--
</div>
</div>-->
<div class="clear"></div>



<div id="clear">
</div>
</p>

</div>
</div>

</div>
</div>
</div>
</div>
</div>


   <!--                                 -->




</body>
</html>
<% end %>

HTML
return render_template(com,self,params)

        end
    

        def export_partial *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
 if params[:hn]
  models = get_model
  
  object_keys = {:provider=>'name',:procedure=>'name',:patient=>'hn'}
  migrate = {}
  result = {}
  
  list = params[:hn].split(',').collect{|i| i.strip}
  
  map = {}
  dx = []
  dy = []
  
  
  ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
  ehr_models = ehr.get_model
  m_patient = ehr_models[:patient]
  m_patient_module = ehr_models[:patient_module]
  
  
  patients = list.collect{|i|  m_patient.where(:hn=>i).first}
  
  result[:patients]=patients
  result[:patient_modules]=[]
  result[:attachment] = []
  
  gridfs = []
  
     
 
  
  patients.each do |i|
  
  ########################## Patient
  dx <<  {:name=>:patient,:old_id=>i.id.to_s}

  query = {:patient_id=>i.id,:module_name=>"\#{@current_project.name}#appointment"}
  if params[:date]
  date =  params[:date].split('-').collect{|x| x.to_i}
  date = Time.utc(date[0],date[1],date[2])
  start = date.beginning_of_day
  stop = date.end_of_day
  #query.merge! :created_at=>{'$gte'=>start,'$lte'=>stop}
  end

  app_modules = m_patient_module.where(query).all
  modules = []
  
  app_modules.each do |x|

  
  app = models[:appointment].find(x.module_id)
  if app.date.strftime("%Y-%m-%d")==params['date']
  modules<< x
  modules+= m_patient_module.where(:parent_id=>x.id).all
  end
  end
  
  result[:patient_modules]+= modules
  for j in modules
   if j 
   ########################## Patient Module
    dx << {:name=>:patient_module,:old_id=>j.id.to_s}
    dy << {:name=>:patient_module,:old_id=>j.id.to_s,:column_name=>'patient_id',:value=>j.patient_id.to_s} 
    dy << {:name=>:patient_module,:old_id=>j.id.to_s,:column_name=>'module_id',:value=>j.module_id.to_s} 
    dy << {:name=>:patient_module,:old_id=>j.id.to_s,:column_name=>'parent_id',:value=>j.parent_id.to_s} if j.parent_id
    
    
    
    m_name = j.module_name.split("#")[-1].to_sym
    result[m_name] = [] unless result[m_name]
 
    m_module = models[m_name]

    
    m_doc = get_document m_name.to_s
    m =  m_module.find(j.module_id) if m_module
    
    ########################## Module

    if m
    dx <<  {:name=>m_name,:old_id=>m.id.to_s} 
    
    
      for k in m_doc.fields
        value = m[k.column_name]
        case k.field_type
        when 'relation_one', 'relation_many'
            p = eval "{\#{k.params}}"
            d = p[:relation][:document]
            r_name = d.to_sym
            r_doc = get_document d
            r_model = models[r_name]
            result[r_name] = [] unless result[r_name] 
            if value
            if k.field_type =='relation_one'
                r_obj = r_model.find(value)
                if r_obj
                unless map[r_obj.id.to_s]
                result[r_name]<<r_obj 
                map[r_obj.id.to_s] = r_obj
                mode = 'create_or_update'
                key = object_keys[r_name]
                dx << {:name=>r_name,:old_id=>value.to_s}  
                end
                dy << {:name=>m_name,:old_id=>m.id.to_s,:column_name=>k.column_name,:value=>value.to_s} if value
                end
            else # relation_many
                r_obj = r_model.find(value)
                for r in r_obj
                    dx <<  {:name=>r_name,:old_id=>r.id.to_s}
                end
                value = value.collect{|vx| vx.to_s}
                dy << {:name=>m_name,:old_id=>m.id.to_s,:column_name=>k.column_name,:value=>value} if value and value.size>0
                result[r_name]+=r_obj
            end
        
             end
        when 'image_camera'
            
            atts = []
            m_att = m_doc.project.load_model[:attachment]
            atts = m_att.find(value).compact
    
                
            value = atts.collect{|vx| vx.id.to_s}
            
            
            for img in atts
            
            img.path = nil
            img.ssid = nil
            grid = Mongo::Grid.new(MongoMapper.database)
            file = grid.get(img.file_id)
            content = file.read 
            gridfs << {:id=>img.file_id,:filename=> file.filename, :document=>m_doc.name, :field=>k.column_name,:type=>file.filename.split(".")[-1], :upload_date=>file.upload_date, :length=>content.size, :content_type=> file.content_type,:data=>Base64.encode64(content)}
            dx <<  {:name=>'attachment',:old_id=>img.id.to_s} 
    
            end            
            dy << {:name=>m_name,:old_id=>m.id.to_s,:column_name=>k.column_name,:value=>value} if value and value.size>0
            result[:attachment]+=atts
        

        end
        
        
    end
    
    
        result[m_name] << m

    end
    
    
    end
    
  
  end
  end
  
  
    mapx = {}
  dx.collect! do |i|
    key = object_keys[i[:name].to_sym]
    i[:new_id] = nil
    if key
        i[:mode] = 'create_or_update'
        i[:key] = key
    else
        i[:mode] = 'create'
     end
    oid = i[:old_id]
    
     i
    
  end
  
  dx.compact!
   ######################################################### Migrate
   
   migrate = {:records=>result, :import=>dx,:update=>dy, :gridfs=>gridfs}

   %>{"records":<%= result.to_json.html_safe %>,
"import":<%= dx.to_json.html_safe %>,
"update":<%= dy.to_json.html_safe %>,
"gridfs":<%= gridfs.to_json.html_safe %>}
<% end %>
HTML
return render_template(com,self,params)

        end
    

        def migrate_import *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%= form_for :migrate do |f| %>
<%= f.text_area 'data' ,:cols=>80,:style=>"width:400px" %><br/>
<%= f.check_box 'perform'  %> Commit<br/>
<%= f.submit 'Import',:confirm=>'Are you sure?' %>
<% end %>

<% 
 
  perform=false

%>
<%= render :inline=>this.import_partial %>
HTML
return render_template(com,self,params,true)

        end
    

        def import_partial *params
            @params = params[0] if params[0]
            ret = com=<<-HTML

<% if request.post?  
  content = params[:migrate][:data].read
  migrate = ActiveSupport::JSON.decode(content)
  
  perform = false
  perform = true if params[:migrate][:perform]=='1'
  migrate.symbolize_keys!
  
%>
<%# content %>
<%= migrate[:records]['patients'][0].inspect%>

<h1> Import </h1>
<%
   map = {}
   for i in migrate[:records].keys
      objs = migrate[:records][i]
      for j in objs
      map[j['id']] = j
      end
   end
%>
<hr/>
<h3>Import Objects</h3>

<%
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    ehr_models = ehr.get_model
    models = get_model
    
    models = ehr_models.merge models
    
    %>
    <%=models.keys%>
    <%
    
    
    map_i = {}
    grid_i = {}
    
    if perform
    
    for i in migrate[:gridfs]
    
      grid = Mongo::Grid.new(MongoMapper.database)
      id = grid.put(Base64.decode64(i['data']),:filename=>i['filename'])    
       map_i['att-'+i['id']] = id
       grid_i[id] = i
    
    end
    
    end
    
    %>
    <%= map_i.inspect %>
    <%
    
    for i in migrate[:import]   
    
    i.symbolize_keys!
    
    name = i[:name]
    
    object = map[i[:old_id]]
    obj = {}   
    obj = object if object
    obj.delete 'id'

    
    model = models[name.to_sym]

    if model
    
    # do import
    if i[:mode]=='create'
    
        obj['module_name'] = "\#{@current_project.name}#\#{obj['module_name'].split('#')[-1]}" if name=='patient_module'
        
        new_obj = model.new obj
    elsif i[:mode]=='create_or_update'
        key = i[:key]
        v = obj[key]
        o = model.where(key=>v).first
        if o
            #up date with existing id
            new_obj = o
        else
            new_obj = model.new obj
        end
    end
    i[:new_id] = new_obj.id if new_obj
    map_i[i[:old_id]] = new_obj
    
    if name == 'attachment'
       
        new_obj['file_id'] = map_i['att-'+new_obj['file_id']]  
        grid = grid_i[new_obj['file_id']]
        path = "/"+File.join("content",@current_project.content_path,grid['document'],grid['field'],"\#{new_obj.id}.\#{grid['type']}")    
        #content/esm/cusys/colorectal/content/colonoscopy/image/51b2d6a5e5425f066d000343.jpg?
        new_obj['path'] = path
        #new_obj.save
    end
    
    
    new_obj.save if perform
        
%>
<b>Import .. </b> <%=i[:name] %> <b>from</b> <%=i[:old_id]%> <b>to</b> <%= new_obj.id  if new_obj %>

<br/>

<% else %>
<hr/>
Not found ... <%= i %>
<hr/>
<% end %>
<% end %>


<h3>Update References</h3>
<%
    for i in migrate[:update]
    i.symbolize_keys!
    model = models[i[:name]]
    obj = map_i[i[:old_id]]
    value = i[:value]
    if value.kind_of? Array

    l = []
    for v in value
     if map_i[v]
    l << map_i[v].id 
    else
    %><hr/>
   Not found <%= v %> <%=i[:name]%><hr/>
    <%
    end
    
    end 
    
    %>
    <b>Link .. </b> <%= i[:name] %> (<%=obj.id.to_s if obj%>) <b>at</b> <%= i[:column_name] %> <b>from</b> <%=  i[:value] %> <b>to</b> <%=l.inspect%><br/>
    <%
    obj[i[:column_name]]=l 
    
    else
    %>
   <b>Link .. </b> <%= i[:name] %> (<%=obj.id.to_s if obj%>) <b>at</b> <%= i[:column_name] %> <b>from</b> <%=  i[:value] %> <b>to</b> <%=map_i[i[:value]].id.inspect if map_i[i[:value]]%><br/>
    <%
    obj[i[:column_name]]=map_i[i[:value]].id if map_i[i[:value]] 
    end
    
    
    
    
   obj.save if perform
%>

<% end %>

<% end %>

HTML
return render_template(com,self,params)

        end
    

        def print_appointment *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
  @module_name = @current_project.name+'#appointment' 
  @ehr_project = @context.get_projects_by_abstract('ehr.ehr')[0]
  @patient_doc = @ehr_project.get_document 'patient'
  @module_doc = @ehr_project.get_document 'patient_module'
  @ehr_model = @ehr_project.get_model()
  @patient_model = @ehr_model[:patient]
  @module_model = @ehr_model[:patient_module]
  
  @models = get_model
  
  if this.table_name!='appointment' and params[:parent_id] 
  @appointment_module = @module_model.find(params[:parent_id])
  if @appointment_module
  @appointment = @models[:appointment].find(@appointment_module.module_id)
  end
  end 
  
  if params[:id] and  @patient_module = @module_model.find(params[:id])
     @patient = @patient_model.find(@patient_module.patient_id)
  end

  if params[:print] and params[:print][:date]
  
  date = Date.to_mongo(params[:print][:date])
 
  appointments =   @models[:appointment].where(:date=>date).all
 
 
  records = {}
 patients = {}
 providers = {}
 indications= {}
  visit_types= {}


 @module_model.where(:module_name=>@module_name, :module_id=>{'$in'=>appointments.collect{|i| i.id }}).all.each do |i|

  records[i.module_id]=i
 end
 
 @patient_model.find(records.values.collect{|i| i.patient_id if i }).each do |i|
 patients[i.id]=i
 end

 @models[:visit_type].all.each do |i|
 visit_types[i.id.to_s] = i
 end
 
 @models[:provider].all.each do |i|
 providers[i.id.to_s] = i
 end
 @models[:indication].all.each do |i|
 indications[i.id.to_s] = i
 end
 
     pro = {}
    @models[:procedure].all.each do |i|
    pro[i.id] = i[:name]
    end
    
    

    
    
json_data =   appointments.collect{|ap| 
 i  = records[ap.id]
 if i
 p = patients[i.patient_id]  
 provider = providers[ap.provider.to_s]
 l = %w{#bcdeee}
 age = '-'
 if p.birth_date
     diff = Time.diff(date, p.birth_date)
    year = diff[:year]
    month = diff[:month]
    day = diff[:day]
    age = "\#{year} ปี \#{month} เดือน \#{day} วัน"
 end
 indication="-"
 visit_type="-"
 
indication = indications[ap.indication.to_s][:name] if indications[ap.indication.to_s]
 visit_type = visit_types[ap.visit_type.to_s][:name] if visit_types[ap.visit_type.to_s]
 
 d = "-"
 d = ap.date.strftime("%Y-%m-%d") if ap.date
 
if true
    {'id'=>ap.id,
    'record'=>i.id,
    'hn'=> p.hn,
    'procedure'=>pro[ap.procedure],
    'date'=>d,
    'color'=>l[rand(4%l.size)],
    'provider'=>(provider.nil? or provider=='') ? '-' : provider[:name],
    'title'=>"\#{p.prefix_name if p } \#{p.first_name if p } \#{p.last_name if p }",
    'start'=>d+"\#{ap.start.strftime(" %H:%M") if ap.start}",
    'end'=>d+"\#{ap.stop.strftime(" %H:%M") if ap.stop}",
    'indication'=>indication,
    'allDay'=>false,
    'url'=>'edit?id='+i.id.to_s,
    'age'=>age,
    'visit_type'=>visit_type,
    'tel'=>[p.tel_home,p.tel_office,p.mobile].collect{|i| i if i!=""}.compact.join(", "),
    'public_id'=>p.public_id
    }  
else
    nil
end 
end
}.compact

list = json_data.sort{|a,b| a['visit_type']<=>b['visit_type']}
 
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>PRINT</title>
</head>
<style type="text/css" media="print,screen">
html { }
value {color:#06F}
imvalue { color:#F00; font-weight:bold}
imvalue value { color:#F00; font-weight:bold}
#page {border:solid 1px; width:910px; border-color:#666;
-webkit-border-radius: 5px; /* Safari prototype */
-moz-border-radius: 5px; /* Gecko browsers */
border-radius: 5px; /* Everything else - limited support at the moment */
margin-bottom:5px; padding-bottom:5px; padding-left:20px;padding-right:20px; }
#head { width:100%; height:60px;}
#logoleft { margin-left:20px; float:left;}
#logoright{ margin-right:20px; float:right;}
th              { font-weight: bolder; text-align: center }
caption         { text-align: center }
body            {   font-family: Arial, Helvetica, sans-serif; color:#000;background:none;font-size:11pt;}
.wrapper{ width:960px;margin-left:auto;margin-right:auto} 
hr    {clear: both;border: none;border-top: 1px solid #AAA;border-bottom: 1px solid #FFF; font-size: 1px;line-height: 0;overflow: visible; width:98%;}
h1              { font-size: 2em; margin: .67em 0 }
h2              { font-size: 1.5em; margin: .83em 0 }
h3              { font-size: 1.17em; margin: 1em 0 }
p {color:#666;}
h4, p,
blockquote, ul,
form,
ol, dl          { margin: 0.5em; }
h5              { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }
h6              { font-size: .67em; margin: 2.33em 0 }

h4 { font-size:14pt; color:#333; height:16px;}
blockquote      { margin-left: 40px; margin-right: 40px }
i, cite, em,
var, address    { font-style: italic }
pre, tt, code,
kbd, samp       {  font-size:14px; }
pre             {margin:0;margin-left:1em; color:#666}
big             { font-size: 1.17em }
v {color:#2561cD;}
small, sub, sup { font-size: .83em }
ol, ul, dd      { margin-left: 40px }
ol              { list-style-type: decimal }
ol ul, ul ol,
ul ul, ol ol    { margin-top: 0; margin-bottom: 0 }
.clear{clear:both;}
@media print {
  @page         { width:960px; margin-top:0; }
  blockquote, 
 .wrapper{ width:960px;margin-left:55px;margin-right:auto} 
  table { page-break-after:auto; -fs-table-paginate: paginate; }
  tr    { page-break-inside:avoid; page-break-after:auto }
  td    { page-break-inside:avoid; page-break-after:auto }
  thead { display:table-header-group;     margin-top:10px;}
  tfoot { display:table-footer-group }

}

#box{
    width:150px;
    float:left;
    padding:10px;
    text-align:center;
    border:1px solid #ccc;
    -webkit-border-radius: 5px; /* Safari prototype */
    -moz-border-radius: 5px; /* Gecko browsers */
    border-radius: 5px; /* Everything else - limited support at the moment */    
    margin:10px;
}
.smm { font-size:0.5em; border:1px solid;border-color:#ccc;}
#box img{
        width:150px;
}
label{
    color:#666; font-weight:bold;
}

#table-3 {
    border: 1px solid #DFDFDF;
    background-color: #F9F9F9;
    width: 100%;
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
	font-family: Arial,"Bitstream Vera Sans",Helvetica,Verdana,sans-serif;
	color: #333;
}
#table-3 td, #table-3 th {
	border-top-color: white;
	border-bottom: 1px solid #DFDFDF;
	color: #555;
}
#table-3 th {
	text-shadow: rgba(255, 255, 255, 0.796875) 0px 1px 0px;
	font-family: Georgia,"Times New Roman","Bitstream Charter",Times,serif;
	font-weight: normal;
	padding: 7px 7px 8px;
	text-align: left;
	line-height: 1.3em;
	font-size: 14px;

}
#table-3 td {
	font-size: 12px;
	padding: 4px 7px 2px;
	vertical-align: top;
	background:#FFF;
}
thead {
    display:table-header-group;

}
tbody {
    display:table-row-group;
}
</style>
<body>

<div class="wrapper">
<div id="head">
<div id="logoleft"><img src='/esm/cusys/colorectal/login-logo.png' width="300" /></div>
<div id="logoright">
<p>Reported by :&nbsp;<%= @current_user.login.humanize %></p>
<p>Printed at :&nbsp;<%= Time.now %></p>
</div>
</div>

<div id="page">

<div class="row-fluid">
<div class="span12">

<div class="w-box">
<br />
<b>ตารางแสดงรายการผู้ป่วย
<span style="float:right">ประจำวันที่ 
<%= date.strftime("%d %B %Y")%></b>
</span>
<br /><br />



<table width="100%" border="1" cellspacing="0" cellpadding="0" id="table-3">
  <thead>
  <tr>
    <th>No.</th>
    <th>Type</th>
    <th style="width:150px">ชื่อ - สกุล</th>
    <th>HN</th>
    <th >อายุ</th>
    <th>เลขประชาชน</th>
    <th>Indication</th>
    <th>Procedure</th>
    <th>Provider</th>
    <th>Tel.</th>
  </tr>
  </thead>
  <tbody>
  <% list.each_with_index do |i,index|  %>
    <tr style="height:110px">
    <td><%=index+1%>.</td>
    <td><%=i['visit_type']%></td>
    <td style="width:150px"><%=i['title']%></td>
    <td><%=i['hn']%></td>
    <td><%=i['age']%></td>
    <td><%=i['public_id']%></td>
    <td><%=i['indication']%></td>
    <td><%=i['procedure']%></td>
    <td><%=i['provider']%></td>
    <td><%=i['tel']%></td>
    </tr>
    <% end %>
</tbody>
  </table><br/>
  </div>
  </div></div></div></div></div>
</body>
</html>
<% end %>

HTML
return render_template(com,self,params)

        end
    

        def print_report *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
print_report <%= params.to_json.html_safe %>
HTML
return render_template(com,self,params)

        end
    

        def update_partial *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<% if request.post?  
  content = params[:migrate][:data].read
  migrate = ActiveSupport::JSON.decode(content)
  
  perform = false
  perform = true if params[:migrate][:perform]=='1'
  perform = false
  migrate.symbolize_keys!

  hash = ['Cold polypectomy','Hot polypectomy','Cold biopsy','Hot biopsy','EMR','EPMR','EMR-C','ESD']
  
 
  map = {}
   for i in migrate[:records].keys
      objs = migrate[:records][i]
      for j in objs
      map[j['id']] = j
      end
   end


    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    ehr_models = ehr.get_model
    models = get_model
    
    models = ehr_models.merge models
    
    map_i = {}
    grid_i = {}
    
    if perform
    
    for i in migrate[:gridfs]
    
      grid = Mongo::Grid.new(MongoMapper.database)
      id = grid.put(Base64.decode64(i['data']),:filename=>i['filename'])    
       map_i['att-'+i['id']] = id
       grid_i[id] = i
    
    end
    
    end


    data = {}
    date_map = {}
    
    for i in migrate[:import]   
    
    
    i.symbolize_keys!
    name = i[:name]
    

    
    object = map[i[:old_id]]
    
    model = models[name.to_sym]
    
        
    case name
    
    when 'patient'
    data[:hn] = object['hn']
    
    when 'colonoscopy'
    
    data[:date] = [] unless data[:date]
    data[:date] << object['date_note']
    date_map[object['date_note']] = object
    when 'colonoscopy_scope'
    
    end
    end 
    

  scopes = %w{rectum_scope sigmoid_scope descending_colon_scope transvers_colon_scope ascending_colon_scope cecum_scope terminal_ileum_scope}


    patient = models[:patient].where(:hn=>data[:hn]).first
    appoint_patient_module = models[:patient_module].where(:patient_id=>patient.id.to_s,:module_name=>'colo#appointment').all
    appointments = models[:appointment].where(:id => { :$in => appoint_patient_module.collect{|i|i.module_id}}).all
    set = {}
    for i in appointments 
        set[i.date.strftime("%Y-%m-%d")]=models[:patient_module].where(:module_id=>i.id).first
    end
    for i in data[:date]
        s = set[i]
        colo_pm =  models[:patient_module].where(:patient_id=>patient.id.to_s,:module_name=>'colo#colonoscopy',:parent_id=>s.id).first
        colo =  models[:colonoscopy].find(colo_pm.module_id)
        colo_data = date_map[i]
        for j in scopes
            list = colo[j]
            list_data = colo_data[j]
            list.each_with_index do |l,index|
            scope_data = map[list_data[index]]
            scope = models[:colonoscopy_scope].find(l)
            scope.update_attributes :treatment_by=>"\#{scope_data['treatment_by']}"
            
            %><%= "\#{data[:hn]} \#{i} \#{scope.treatment_by} \#{scope_data['treatment_by']}" %>
<%
            end
        end
    end
%><% end %>
HTML
return render_template(com,self,params)

        end
    

        def context_menu_partial *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<style>
    .list-x{width:100px;border:0px solid;display:inline-block;}
</style>
<% 
if @current_role != 'pathologist'
modules = @context.get_projects_by_abstract 'ehr.emr' 
model = get_model
ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
ehr_models = ehr.load_model
patient_model = ehr_models[:patient]
m = modules.collect{|i| {:name=>i.title,:link=>"../../\#{i.name}/Home/index",:remote=>false} }
m <<  {:name=>'Back to EHR',:link=>"../../www/Home/index",:remote=>false}
%>
<%# show_menu m %>

<%

if params[:id]

pm_model = ehr_models[:patient_module]

lpm = pm_model.find(params[:id])
    
if params[:mode]=='module' and lpm
    
    
    apm = pm_model.find(lpm.parent_id)
    if lpm and apm
    ap = model[:appointment].find(apm.module_id)
    else
    apm = pm_model.find(params[:id])
    ap = model[:appointment].find(apm.module_id)

    end
    
else
    ap = model[:appointment].find(params[:id]) 
    if ap
    apm = pm_model.where(:module_id=>ap.id).first
    end
    
end
patient = nil
if apm
   patient = patient_model.find(apm.patient_id) 
end

# if params[:id] or params[:parent_id]
    
obj = this.config

list = []

for i in obj
for j in i[:actions]
  if j[:dashboard]==true
    list << j
  end
end
end


# 


# if params[:parent_id]
# elsif params[:service]=='Home'
#     ap = model[:appointment].find(params[:id]) 
# else
#     lpm = pm_model.find(params[:id])
#     apm = pm_model.find(lpm.parent_id)
#     ap = model[:appointment].find(apm.module_id)
# end

# obj = [
# {:name=>'Endoscopy',:open=>true,:actions=>[
# {:name=>'Consignment',:service=>'consignment',:link=>'../Consignment/index',:remote=>false},
# {:name=>'Pre Scope',:service=>'pre_scope',:link=>'../PreScope/index',:remote=>false},
# {:name=>'Intra Scope',:service=>'intra_scope',:link=>'../IntraScope/index',:remote=>false},
# {:name=>'Post Scope',:service=>'post_scope',:link=>'../PostScope/index',:remote=>false}]},
# {:name=>'Endoscopist Records',:open=>true,:actions=>[
# {:name=>'Colonosopy',:service=>'colonoscopy',:link=>'../Colonoscopy/index',:remote=>false},
# {:name=>'Gastroscopy',:service=>'gastroscopy',:link=>'../Gastroscopy/index',:remote=>false}]},
# {:name=>'ETC',:open=>true,:actions=>[
# {:name=>'Pathology',:service=>'pathology',:link=>'../Pathology/index',:remote=>false},
# {:name=>'Analyses',:service=>'report',:link=>'../Report/index',:remote=>false}]}]

if patient
%>
<%# params[:id] %>
<%#list.inspect  %>


<div class="accordion-group" style="">
	<div class="accordion-heading">
		<a href="#collapse-0" data-parent="#side_accordion" data-toggle="collapse" class="accordion-toggle">
		Visit Detail
		</a>
		</div>
		<div class="accordion-body collapse in" id="collapse-0">
			<div class="accordion-inner">
			<div class="alert alert-info">
			
<b>Name : </b><%= patient.first_name %> <%= patient.last_name %> <br/>
<b>HN : </b><%= patient.hn %> <br/>

			
<b>Visit Type : </b><%=t = model[:visit_type].find(ap.visit_type); t.name if t %> <br/>
<b>Visit Date : </b><%= ap.date  if ap%><br/>
</div>
<% for i in list %>
<div style="padding-bottom:5px;padding-top:5px;border-bottom:1px solid #ccc">
<span class="list-x"><%=i[:name]%> : </span>
<%
   ilist = []
#   apm
   pm = pm_model.where(:parent_id=>apm.id,:module_name=>"\#{@current_project.name}#\#{i[:service]}").first
   return_url = "../Home/patient_record?id=\#{ap.id}"
   if pm
      ilist << link_to("Edit","\#{i[:link].split('/')[0..-2].join('/')}/edit?id=\#{pm.id}&return=\#{return_url}",:class=>'btn')
      ilist << link_to("Print","\#{i[:link].split('/')[0..-2].join('/')}/print?id=\#{pm.id}",:class=>'btn ',:target=>'_blank')
   else
      patient_id = apm.patient_id
      patient_hn = '0000'
      
      ilist << link_to("Create","\#{i[:link].split('/')[0..-2].join('/')}/create?patient_id=\#{patient_id}&record_name=\#{patient_hn}&parent_id=\#{apm.id}&return=\#{return_url}",:class=>'btn')
   end



 for j in ilist 
%>
<%=j.html_safe%>
<% end %>
</div>

<% end %>
<div><br/>
    <center><%=link_to 'Back to Record', params[:return], :class=>'btn' %></center>

</div>
</div>

</div>

</div>

<% else %>

<%=show_menu this.config %>
<% end %>

<%    

# obj << {:name=>'Links',:open=>true,:actions=>m}
%>
<% services =  @current_project.get_services_by_abstract('ehr.emr.Document') %>

<% else %>
<center style="margin-top:20px"><%= link_to 'Pathology Records','../Pathology/index',:class=>'btn' %></center>
<% end %>

<% end %>




HTML
return render_template(com,self,params)

        end
    

        def last_updated *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
    date = Time.now
    if params[:date]
        date = params[:date]
    end
    date = Date.to_mongo(params[:date])
    
    a_app = get_model[:appointment].where(:date=>Date.to_mongo(date)).all
    a_app = a_app.sort_by{|i| i[:updated_at]}.reverse


    res = {}
    if !a_app.empty?
        res[:last_updated] = a_app.first[:updated_at]
        res[:app_first] = a_app.first[:updated_at]
        res[:app_last] = a_app.last[:updated_at]
    else
        res[:last_updated] = ""
    end
%>
<%= res.to_json.html_safe %>

HTML
return render_template(com,self,params)

        end
    

end

class Homecolorectalcusys < Homeemrehr

    def initialize context=nil
       super context
    end

    def local_class name
      "'#{self.class.name}::#{name}'"
    end


        def print *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
    values = %w{Elective Emergency Extratime}

    date = Time.now
    
    total = 0
    totals = {}
    
    if params[:print]
    date = params[:print][:date]
    date = Date.parse(date)
    end    
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    patients = []
    
    status_list=%w{appointed waiting processing completed cancelled no_show}.collect{|i| i.humanize}
   
    
    mname = "\#{@current_project.name}#appointment"
    forms = %w{colonoscopy gastroscopy}
    
    models = get_model
    ap_model = models[:appointment]
    p_model = models[:provider]
    aps = ap_model.all(:date.gte=>date.at_beginning_of_day,:date.lt=>date.end_of_day) 
    list = aps.clone
    id = ''
    
      aps.collect!{|i| 
    id = i.id
      if m = module_model.first(:module_name=>mname,:module_id=>i.id)
         patient = patient_model.find(m.patient_id)
         provider = p_model.find(i.provider)
        c = {:ref_number=>m.ref_number,
            :public_id=>patient.public_id,
            :hn=>patient.hn,
            :patient=>link_to("\#{patient.first_name} \#{patient.last_name}","../../www/Patient/edit?id=\#{patient.id}&return=\#{request.fullpath}"),
            :provider=>"",
            :date=>i.date,
            :note=>i.note,
            :status=>nil,
            :procedure=>models[:procedure].find(i.procedure).name,
            :module=>m,
            :appointment=>i
         }
         
        jname = "\#{@current_project.name}#intra_scope"
        m = module_model.where(:module_name=>jname,:parent_id=>m.id.to_s).first
        
        if m and intra = models[:intra_scope].find(m.module_id)
            c[:no_specimen] = intra.specimen
            
          
            
            if !intra.endoscopy_nurse.empty?
            tt = models[:time_to_time]
            for x in  intra.endoscopy_nurse
            tx = tt.find(x)
            if tx and px = p_model.find(tx.endoscopy_nurse)
            c[:provider]+="<br/>N:"+ px.name 
            end
            end
            end
            
            if intra.assistant1
            if px = p_model.find(intra.assistant1)
            c[:provider]+="<br/>A:"+ px.name 
            end
            end
            if intra.assistant2
            if px = p_model.find(intra.assistant2)
            c[:provider]+="<br/>A:"+ px.name 
            end
            end
            
        end
        
     end
      
      c
      
      }
    
    list = []
    
    
    
    for i in aps
    
    mm = i[:module]
    
    status = ''
    
    preprovider = i[:provider]
          
    for j in forms
        jname = "\#{@current_project.name}#\#{j}"
        m = module_model.where(:module_name=>jname,:parent_id=>mm.id.to_s).first
        if m
        data = models[j.to_sym].find(m.module_id)
        i[:time] = data.start_at.strftime("%H:%M")+" (\#{((data.stop_at-data.start_at)/60).to_i})"
        i[:procedure]= j.humanize
        i[:add_procedure] = data.procedure.split("|").join(", ")
        i[:diagnosis_group] = data.diagnosis_group.split("|").join(", ")
        i[:status] = data.status;
        status = data.status;
        i[:sedation] = ['dormicum','pethidine','diprivan','valium','buscopan','plasil','fentanyl'].collect{|s| "\#{s.humanize} \#{data[s+'_mg']} mg \#{data[s+'_num']}" if data[s+'_mg'] }.compact.join("<br/>")
        i[:bowel_prep] = data.quality_of_preparate
        
             prov = ""
             
            if data.endoscopist_1
            if px = p_model.find(data.endoscopist_1)
            prov = "E:\#{px.name}."
            end
            end
            
            
            if data.endoscopist_2
            if px = p_model.find(data.endoscopist_2)
            prov+="<br/>E:"+ px.name 
            end
            end
            
        i[:provider]= "\#{prov}\#{preprovider}"
        
        totals[i[:status]]={} unless totals[i[:status]]
        totals[i[:status]][j]=0 unless totals[i[:status]][j]
        totals[i[:status]][j]+=1
        
        ls = []
        if j == 'colonoscopy'
        ls = ['rectum_scope','sigmoid_scope','descending_colon_scope','transvers_colon_scope','ascending_colon_scope','cecum_scope','terminal_ileum_scope']
        ms = 'colonoscopy_scope'
        else
        ls = ['pharynx_scope','esophagus_scope','egj_scope','fundus_scope','cardia_scope','body_scope','antrum_scope','first_duodenum_scope','sphincter_of_oddi_scope','second_duodenum_scope','third_duodenum_scope','forth_duodenum_scope','proximal_jejunum_scope','distal_jejunum_scope']
        ms = 'gastroscopy_scope'
        end
        count = 0
        max = 0
        c = 0
        %>
        <%# data.inspect %>
        <%
        ls.each{|lc| 
            if data[lc] and !data[lc].empty?
                #count+=data[lc].size
                
                ll = models[ms.to_sym].find(data[lc])
              
                for li in ll
                    #z = li.patho_number.to_i if li.patho_number
                    #max = z if z>max
                    count+=1 if li.patho_number!='' and li.patho_number!='Loss'
                end
            end
        }
        
        
        i[:no_specimen] = (count).to_s
        list<<i.clone  
        end
        
        
                 

     end  

     if i and i[:status] and totals[i[:status]]
        totals[i[:status]]['patient']=0 unless totals[i[:status]]['patient']
        totals[i[:status]]['patient']+=1
     end

     
    end
    
    aps = list.sort{|a,b| a[:time]<=>b[:time]}

    apss = {}
    
    values.size.times do |j|
    apss[values[j]] = aps.collect{|i| i if i[:status]==values[j] }.compact
    end



%>

<%# apss.inspect  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>PRINT</title>
</head>
<style type="text/css" media="print,screen">
html { }
value {color:#06F}
imvalue { color:#F00; font-weight:bold}
imvalue value { color:#F00; font-weight:bold}
#page {border:solid 1px; width:910px; border-color:#666;
-webkit-border-radius: 5px; /* Safari prototype */
-moz-border-radius: 5px; /* Gecko browsers */
border-radius: 5px; /* Everything else - limited support at the moment */
margin-bottom:5px; padding-bottom:5px; padding-left:20px;padding-right:20px; }
#head { width:100%; height:60px;}
#logoleft { margin-left:20px; float:left;}
#logoright{ margin-right:20px; float:right;}
th              { font-weight: bolder; text-align: center }
caption         { text-align: center }
body            {   font-family: Arial, Helvetica, sans-serif; color:#000;background:none;font-size:11pt;}
.wrapper{ width:960px;margin-left:auto;margin-right:auto} 
hr    {clear: both;border: none;border-top: 1px solid #AAA;border-bottom: 1px solid #FFF; font-size: 1px;line-height: 0;overflow: visible; width:98%;}
h1              { font-size: 2em; margin: .67em 0 }
h2              { font-size: 1.5em; margin: .83em 0 }
h3              { font-size: 1.17em; margin: 1em 0 }
p {color:#666;}
h4, p,
blockquote, ul,
form,
ol, dl          { margin: 0.5em; }
h5              { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }
h6              { font-size: .67em; margin: 2.33em 0 }

h4 { font-size:14pt; color:#333; height:16px;}
blockquote      { margin-left: 40px; margin-right: 40px }
i, cite, em,
var, address    { font-style: italic }
pre, tt, code,
kbd, samp       {  font-size:14px; }
pre             {margin:0;margin-left:1em; color:#666}
big             { font-size: 1.17em }
v {color:#2561cD;}
small, sub, sup { font-size: .83em }
ol, ul, dd      { margin-left: 40px }
ol              { list-style-type: decimal }
ol ul, ul ol,
ul ul, ol ol    { margin-top: 0; margin-bottom: 0 }
.clear{clear:both;}
@media print {
  @page         { width:960px; margin-top:0; }
  blockquote, 
 .wrapper{ width:960px;margin-left:55px;margin-right:auto} 
  table { page-break-after:auto; -fs-table-paginate: paginate; }
  tr    { page-break-inside:avoid; page-break-after:auto }
  td    { page-break-inside:avoid; page-break-after:auto }
  thead { display:table-header-group;     margin-top:10px;}
  tfoot { display:table-footer-group }

}

#box{
    width:150px;
    float:left;
    padding:10px;
    text-align:center;
    border:1px solid #ccc;
    -webkit-border-radius: 5px; /* Safari prototype */
    -moz-border-radius: 5px; /* Gecko browsers */
    border-radius: 5px; /* Everything else - limited support at the moment */    
    margin:10px;
}
.smm { font-size:0.5em; border:1px solid;border-color:#ccc;}
#box img{
        width:150px;
}
label{
    color:#666; font-weight:bold;
}

#table-3 {
    border: 1px solid #DFDFDF;
    background-color: #F9F9F9;
    width: 100%;
    -moz-border-radius: 3px;
	-webkit-border-radius: 3px;
	border-radius: 3px;
	font-family: Arial,"Bitstream Vera Sans",Helvetica,Verdana,sans-serif;
	color: #333;
}
#table-3 td, #table-3 th {
	border-top-color: white;
	border-bottom: 1px solid #DFDFDF;
	color: #555;
}
#table-3 th {
	text-shadow: rgba(255, 255, 255, 0.796875) 0px 1px 0px;
	font-family: Georgia,"Times New Roman","Bitstream Charter",Times,serif;
	font-weight: normal;
	padding: 7px 7px 8px;
	text-align: left;
	line-height: 1.3em;
	font-size: 14px;

}
#table-3 td {
	font-size: 12px;
	padding: 4px 7px 2px;
	vertical-align: top;
	background:#FFF;
}
thead {
    display:table-header-group;

}
tbody {
    display:table-row-group;
}
</style>
<body>

<div class="wrapper">
<div id="head">
<div id="logoleft"><img src='/esm/cusys/colorectal/login-logo.png' width="300" /></div>
<div id="logoright">
<p>Reported by :&nbsp;<%= @current_user.login.humanize %></p>
<p>Printed at :&nbsp;<%= Time.now %></p>
</div>
</div>

<div id="page">

<div class="row-fluid">
<div class="span12">

<div class="w-box">
<br />
<b>ตารางแสดงผู้ป่วยเข้ารับการส่องกล้องห้องส่องกล้อง Surgical endoscopy 
<span style="float:right">ประจำวันที่ 
<%= date.strftime("%d %B %Y")%></b>
</span>
<br /><br />
<%
 
 line = 0 
  for x in values 
  
  aps = apss[x]
  
  if aps.size>0 
%>
<h2><%=x%></h2>
<table width="100%" border="1" cellspacing="0" cellpadding="0" id="table-3">
  <thead>
  <tr>
    <th>No.</th>
    <th>เวลา(นาที)</th>
    <th style="width:150px">ชื่อ - สกุล</th>
    <th>Quality Prep</th>
    <th style="width:150px">Sedation</th>
    <th>Procedure</th>
    <th>Add procedure</th>
    <th style="width:150px">Endoscopist</th>
    <th>Diagnosis group</th>
    <th>No. of Specimen</th>
  </tr>
  </thead>
  
  
  <tbody>

  <%
   count = 0
    
  for i in aps 

  %>
 <!---
Let's now create a ton or rows that will require
several pages to fully print.
--->

  <tr>
  <td><%= count+=1 %>.</td>
    <td> <%= i[:time] %></td>
    <td><%= i[:patient] %><br /><%= i[:hn] %><br /><%= i[:public_id] %></td>
    <td><%= i[:bowel_prep].html_safe  if i[:bowel_prep]%></td>
    <td><%= i[:sedation].html_safe  if i[:sedation]%></td>
    <td><%= i[:procedure] %></td>
    <td><%= i[:add_procedure] %></td>
    <td><%= i[:provider].html_safe %></td>
    <td><%= i[:diagnosis_group] %></td>
    <td><%= i[:no_specimen] %></td>
  </tr>
  
  <% 

 
    
    if line%16==14
  %>
  </tbody>
  </table>
  <br/><br/>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" id="table-3" style="page-break-before:always">
  <thead>
  <tr>
    <th>No.</th>
    <th>เวลา(นาที)</th>
    <th style="width:150px">ชื่อ - สกุล</th>
    <th>Quality Prep</th>
    <th style="width:150px">Sedation</th>
    <th>Procedure</th>
    <th>Add procedure</th>
    <th style="width:150px">Endoscopist</th>
    <th>Diagnosis group</th>
    <th>No. of Specimen</th>
  </tr>
  </thead>
  <tbody>
  <%
    end 
     line += 1 
  %>
  
  <% end  %>
  
  </tbody>
</table>

<br/>

<% end %>

<% end %>
<h2>Summary</h2>
<%# totals.inspect%>
<table  border="1" cellspacing="0"  cellpadding="5" id="table-3" style="width:400px">
<tr  align="center"><td>&nbsp;</td>
<% for j in forms %>
<td><%= j.humanize %></td>
<% end %><td>Number of Patient</td>
</tr>
<% for i in values 
    if totals[i]
%>
<tr align="center"><th><%=i%></th>
<% for j in forms %>
<td ><%= totals[i][j] %></td>
<% end %>
<td><%= totals[i]['patient']%></td>
</tr>
<% 

end 
end %>
</table>


</div>
</div>
</div>
</div>





<%#totals.inspect %>

<div class="clear">
</div>

</div>
<script>
window.print()
</script>
</body>
</html>



HTML
return render_template(com,self,params)

        end
    

        def config *params
            @params = params[0] if params[0]
            ret = this = self
[
{:name=>'Nurse Records',:open=>true,:actions=>[
{:name=>'Consignment',:service=>'consignment',:link=>'../Consignment/index',:remote=>false},
{:name=>'Pre Scope',:service=>'pre_scope',:link=>'../PreScope/index',:remote=>false},
{:name=>'Intra Scope',:service=>'intra_scope',:link=>'../IntraScope/index',:remote=>false},
{:name=>'Post Scope',:service=>'post_scope',:link=>'../PostScope/index',:remote=>false}]},
{:name=>'Endoscopist Records',:open=>true,:actions=>[
{:name=>'Colonosopy',:service=>'colonoscopy',:dashboard=>true,:link=>'../Colonoscopy/index',:remote=>false},
{:name=>'Gastroscopy',:service=>'gastroscopy',:dashboard=>true,:link=>'../Gastroscopy/index',:remote=>false}]},
{:name=>'ETC',:open=>true,:actions=>[
{:name=>'Billing',:service=>'billing',:link=>'../Billing/index',:remote=>false},
{:name=>'Pathology',:service=>'pathology',:dashboard=>true,:link=>'../Pathology/index',:remote=>false}]}]


        end
    

        def report *params
            @params = params[0] if params[0]
            ret = com=<<-HTML

<h3>Reports</h3><br/>
<%
    models = get_model
    forms = %w{colonoscopy gastroscopy}
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    patients = [] #patient_model.all :select=>[:date]
    mname = "\#{@current_project.name}#appointment"
   select_date = Time.now.strftime("%Y-%m-%d")
   select_date = params[:print]['date(1i)']+"-"+params[:print]['date(2i)']+"-15" if params[:print]
   select_date = Date.to_mongo(select_date)
%>



<% 
    app_model = models[:appointment]
    
    selected_doc = %w{colonoscopy gastroscopy}.collect{|i| "\#{@current_project.name}#\#{i}"}
    
    
    apps = app_model.collection.find({:status=>{'$in'=>['Completed','Recovery','Processing']},:date=>{'$gte'=>Time.now.at_beginning_of_year()}},{:fields=>[:date,:status]}).to_a
    app_ids = apps.collect{|i| i['_id']}
    
    appm_ids = []
    mapps = {}
    module_model.collection.find({:module_id=>{'$in'=>app_ids}},:fields=>[:patient_id,:module_id]).each do |i|
    appm_ids << i['_id']
    mapps[i['module_id']] = i
    end
    
    parents = {}
    c = {0=>[],1=>[]}
   
    list = module_model.collection.find({:parent_id=>{'$in'=>appm_ids},:module_name=>{'$in'=>selected_doc}},{:fields=>[:parent_id,:module_name,:module_id]}).each do |i|
    p = i['parent_id']
    parents[p] = {:modules=>0} unless parents[p]
  
    idx = selected_doc.index(i['module_name'])
    parents[p][:modules] |= 2**idx
    parents[p][:id]=i['module_id']
    c[idx] << i['module_id']
    
    end
    
    status={}
    # colono
    models[:colonoscopy].collection.find({:_id=>{'$in'=>c[0]}},{:fields=>[:status]}).each do |i|
        status[i['_id']] = i['status']
    end
    models[:gastroscopy].collection.find({:_id=>{'$in'=>c[1]}},{:fields=>[:status]}).each do |i|
        status[i['_id']] = i['status']
    end

    
    
    months = {'Elective'=>[],'Extratime'=>[],'Emergency'=>[]}
    
    list = apps.collect{|i|
        p = parents[mapps[i['_id']]['_id']]
       
        if p 
        s = status[p[:id]]
        modules = p[:modules]
        mons = months[s]
        if mons
        m = i['date'].month
        mons[m] = {} unless mons[m]
        mons[m][modules] = 0 unless mons[m][modules]
        mons[m][modules] +=1 
        end
        end
      
  
        i
    }
    list = months
    
    #list = app_model.collection.map_reduce(BSON::Code.new(map_func),BSON::Code.new(reduce_func))
    
    #list = app_model.collection.group({:keyf=>'function(doc){return {month:doc.date.getMonth(),pm:db.www.patient_module.findOne({module_id:this.id}};}',
    #      :reduce=>'function(curr,result){result.count++;}',
    #      :initial=>{:count=>0},
    #      :finalize=>'function(result){result.month=result.month}',
    #      :cond=>{:status=>{'$nin'=>['No show','Cancelled']},:date=>{'$gte'=>Time.now.at_beginning_of_year()}}})
      
%>
<%#list.inspect %>

<%
   m=[]
   12.times do |i|
   m << i+1
   end
   labels = {1=>'Colono',2=>'Gastro',3=>'Colono+Gastro'}
   
months.each_pair do |k,v| 

   v = v[1..-1]
   if v
   l = [1,3,2]
   l.collect!{|i|
    {:name=>labels[i],:data=>v.compact.collect{|j| j[i] }}
   }
   end
   
   
%>

<div id="chart<%=k%>" style="border:1px solid;width:100%;min-height:300px">
</div>
<br/>

            <script>
                    $("#chart<%=k%>").kendoChart({
                        theme: $(document).data("kendoSkin") || "default",
                        title: {
                            text: "<%= k %> Patients by Months"
                        },
                        legend: {
                            position: "bottom"
                        },
                        chartArea: {
                            background: ""
                        },
                        seriesDefaults: {
                            type: "column"
                        },
                        series: <%=l.to_json.html_safe%>
                        ,
                        valueAxis: {
                            labels: {
                                format: "{0}"
                            }
                        },
                        categoryAxis: {
                            categories: <%=m.to_json.html_safe%>
                        },
                        tooltip: {
                            visible: true,
                            format: "{0}"
                        }
                    });
                

            </script>


<% end %>








<%# select_date %>
<% date = Time.now%>
Monthly Report : 
<%= form_for 'print',:url=>"report" do |f| %>
<%= f.date_select 'date',:default=>select_date,:discard_day=>true,:id=>'today-date',:order=>[:month,:year] %>
<%= f.submit 'Query' ,:class=>'btn btn-small btn-info'%>
<% end %>


<hr/>
<%# select_date %>
<%# params.inspect %>
<%
  if params[:print] 

    
    start_date = select_date.at_beginning_of_month
    end_date = select_date.end_of_month

    apps =  models[:appointment].where(:date.gte=>start_date,:date.lt=>end_date).all 
    
    
    map = {'Elective'=>{},'Extratime'=>{},'Emergency'=>{}}
    
    apps.collect! do |i|
        mapp = module_model.where(:module_id=>i.id).first
        p = patient_model.where(:id=>mapp.patient_id).first :select=>:hn    
      
        colo_flag = false
        gastro_flag = false
        status = nil
        
        mm = module_model.where(:parent_id=>mapp.id).all
        mm.each do |j|
        
        
            if j.module_name.index('#gastro')
                gastro_flag = true 
                mo_model = models[:gastroscopy]
                x = mo_model.where(:id=>j.module_id).first :select=>[:status]
                 status = x.status if x
            end
            if j.module_name.index('#colo')
                colo_flag = true 
                mo_model = models[:colonoscopy]
                x = mo_model.where(:id=>j.module_id).first :select=>[:status]
                status = x.status if x
            end
            
     
        end
        date = i.date.strftime("%Y-%m")
        if status
        map[status][date] = {:colo=>0,:gastro=>0,:colo_gastro=>0} unless map[status][date]
        if colo_flag and gastro_flag
           map[status][date][:colo_gastro]+=1
        elsif colo_flag
           map[status][date][:colo]+=1
        elsif gastro_flag
            map[status][date][:gastro]+=1
        end
        
        end
        
        [i.date.strftime("%Y-%m-%d"),p.hn,colo_flag,gastro_flag]
        
    end
    



%>
<%
   for i in map.keys
%><h1><%=i%></h1>
<table border="1"><tr><th>Month</th><th>Colonoscopy</th><th>Gastroscopy</th><th>Colonoscopy + Gastroscopy</th></tr>
<%
   for j in map[i].keys
   x = map[i][j]
%>
<tr>
<th><%= j %></th>
<td><%= x[:colo] %></td>
<td><%= x[:gastro] %></td>
<td><%= x[:colo_gastro] %></td>
</tr>
<% end %>
</table>
<% end %>
<br/><br/>
<table border="1"><tr><th>Date</th><th>HN</th><th>Colo</th><th>Gastro</th></tr>
<% for i in apps.sort{|a,b| (a[0]+a[1])<=>(b[0]+b[1])} 
 if i[2] or i[3]
%>
<tr><td><%= i[0] %></td><td><%= i[1] %></td><td><%= i[2] %></td><td><%= i[3] %></td></tr>
<% end %>
<% end %>
</table>


<% end %>

<% if false 

  patients =  module_model.all(:module_name=>mname)
%>



<% for mo in forms %>
<h3><%=mo.humanize %> Summary</h3>

<%
    tmap = {}
    map = {}
    rds = 0 
    mo_model = models[mo.to_sym]
    ves =  module_model.all :select=>[:date,:module_name,:module_id],:date.gte=>Time.now.at_beginning_of_year,:module_name=>"\#{@current_project.name}#\#{mo}"  
    for i in ves
        tag = i.date.strftime("%Y-%m")
        data = mo_model.find(i.module_id)
        if data
        g = data.status
        tmap[g] = {} unless tmap[g]
        map[tag]= 0 unless map[tag]
        map[tag]+= 1
        tmap[g][tag] = 0 unless tmap[g][tag]
        tmap[g][tag] += 1 
        rds+=1
        end
    end
    columns = map.keys.sort
    tcolumns= tmap.keys.sort
    data = tcolumns.collect{|i| {:name=>i.split('#')[-1].humanize,:data=>columns.collect{|j| tmap[i][j] }}}
    cdata = columns.collect{|i| map[i]}
%>
<div id="chart-<%=mo%>" style="border:1px solid;width:100%;min-height:300px">
</div>

<br/>
<div style="float:right">

</div>


            <script>
                function createChart<%=mo%>() {
                    $("#chart-<%=mo%>").kendoChart({
                        theme: $(document).data("kendoSkin") || "default",
                        title: {
                            text: "Records by Months"
                        },
                        legend: {
                            position: "bottom"
                        },
                        chartArea: {
                            background: ""
                        },
                        seriesDefaults: {
                            type: "column"
                        },
                        series: <%=data.to_json.html_safe %>
                        ,
                        valueAxis: {
                            labels: {
                                format: "{0}"
                            }
                        },
                        categoryAxis: {
                            categories: <%=columns.to_json.html_safe%>
                        },
                        tooltip: {
                            visible: true,
                            format: "{0}"
                        }
                    });
                }

                $(document).ready(function() {
                    setTimeout(function() {
                        createChart<%=mo%>();
                    }, 400);
                });
            </script>
            
<% end %>

<% end %>
HTML
return render_template(com,self,params,true)

        end
    

        def status_feed *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <%= javascript_include_tag "application"  %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>PRINT</title>
</head>
<style type="text/css" media="all">
html {}

value {font-size:0.9em;padding:0px;border:0px solid;}
imvalue { color:#F00; font-weight:bold}
imvalue value { color:#F00; font-weight:bold}
#page {border:solid 1px;  border-color:#666;
-webkit-border-radius: 5px; /* Safari prototype */
-moz-border-radius: 5px; /* Gecko browsers */
border-radius: 5px; /* Everything else - limited support at the moment */
margin-bottom:5px; padding-bottom:5px; padding:33px}
#head { width:100%; height:60px;}
#logoleft { margin-left:20px; float:left;}
#logoright{ margin-right:20px; float:right;}
th              { font-weight: bolder; text-align: center }
caption         { text-align: center }
body            {   font-family: Arial, Helvetica, sans-serif; color:#fff;font-size:25px; 
background:#000;

}
.wrapper{ width:95%;margin-left:auto;margin-right:auto} 
hr    {clear: both;border: none;border-top: 1px solid #AAA;border-bottom: 1px solid #FFF; font-size: 1px;line-height: 0;overflow: visible; width:98%;}
h1              { font-size: 2em; margin: .67em 0 }
h2              { font-size: 1.5em; margin: .83em 0 }
h3              { font-size: 1.17em; margin: 1em 0 }
p {color:#666;}
h4, p,
blockquote, ul,
form,
ol, dl          { margin: 0.5em; }
h5              { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }
h6              { font-size: .67em; margin: 2.33em 0 }

h4 { font-size:14pt; color:#333; height:16px;}
blockquote      { margin-left: 40px; margin-right: 40px }
i, cite, em,
var, address    { font-style: italic }
pre, tt, code,
kbd, samp       {  font-size:14px; }
pre             {margin:0;margin-left:1em; color:#666}
big             { font-size: 1.17em }
v {color:#000;}
small, sub, sup { font-size: .83em }
ol, ul, dd      { margin-left: 40px }
ol              { list-style-type: decimal }
ol ul, ul ol,
ul ul, ol ol    { margin-top: 0; margin-bottom: 0 }
.clear{clear:both;}
@media print {
  @page         { width:90%; margin-top:0; }
  blockquote, 
 .wrapper{ width:100%;margin-left:auto;margin-right:auto} 
}

#box{
    width:150px;
    float:left;
    padding:10px;
    text-align:center;
    border:1px solid #ccc;
    -webkit-border-radius: 5px; /* Safari prototype */
    -moz-border-radius: 5px; /* Gecko browsers */
    border-radius: 5px; /* Everything else - limited support at the moment */    
    margin:10px;
}
.smm { border:1px solid;border-color:#ccc;}
#box img{
        width:150px;
}
label{
    color:#000;font-weight:bold;
    font-size: 1em;
}

table.table {
    
    color: #666;
    font-size: 2em;
    -moz-border-radius: 3px;
    -moz-box-shadow: 0 1px 2px #d1d1d1;
    -webkit-border-radius: 3px;
    -webkit-box-shadow: 0 1px 2px #d1d1d1;
    background: #eaebec;
    border: #ccc 1px solid;
    border-radius: 3px;
    box-shadow: 0 1px 2px #d1d1d1;
    font-family: Arial, Helvetica, sans-serif;
    text-shadow: 1px 1px 0px #fff;
}

table.table tr.even td {
    background: #f6f6f6;
    background: -webkit-gradient(linear, left top, left bottom, from(#f8f8f8), to(#f6f6f6));
    background: -moz-linear-gradient(top, #f8f8f8, #f6f6f6);
}

table.table th {
    padding: 5px ;
    font-size:0.9em;
    border-bottom: 1px solid #e0e0e0; border-top: 1px solid #fafafa;
    background: #ededed;
    background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(#ebebeb));
    background: -moz-linear-gradient(top, #ededed, #ebebeb);
}

table.table th:first-child {
    //padding-left: 20px;
    text-align: center
}

table.table a:visited {
    color: #999999;
    font-weight: bold;
    text-decoration: none
}

table.table a:active,
table.table a:hover {
    color: #bd5a35;
    text-decoration: underline
}

table.table a:link {
    color: #666;
    font-weight: bold;
    text-decoration: none
}

table.table tr {
    padding-left: 20px;
    text-align: center
}

table.table tr:first-child th:first-child {
    -moz-border-radius-topleft: 3px;
    -webkit-border-top-left-radius: 3px;
    border-top-left-radius: 3px;
}

table.table tr:first-child th:last-child {
    -moz-border-radius-topright: 3px;
    -webkit-border-top-right-radius: 3px;
    border-top-right-radius: 3px;
}

table.table tr:last-child td {    border-bottom: 0 }

table.table tr:last-child td:first-child {
    -moz-border-radius-bottomleft: 3px;
    -webkit-border-bottom-left-radius: 3px;
    border-bottom-left-radius: 3px;
}

table.table tr:last-child td:last-child {
    -moz-border-radius-bottomright: 3px;
    -webkit-border-bottom-right-radius: 3px;
    border-bottom-right-radius: 3px;
}

table.table tr:hover td {
    
    background: #f2f2f2;
    background: -webkit-gradient(linear, left top, left bottom, from(#f2f2f2), to(#f0f0f0));
    background: -moz-linear-gradient(top, #f2f2f2, #f0f0f0);
}

table.table tr td {
    
    padding: 0px;
    border-bottom: 1px solid #e0e0e0; border-left: 1px solid #e0e0e0; border-top: 1px solid #ffffff;
    background: #fafafa;
    background: -webkit-gradient(linear, left top, left bottom, from(#fbfbfb), to(#fafafa));
    background: -moz-linear-gradient(top, #fbfbfb, #fafafa);
    border:1px solid;
}

table.table tr td:first-child {
    padding-left: 20px;
    border-left: 0;
}


.Waiting{color:#ccc}
.Preparing{color:#6cc}
.Processing{color:#6c6}
.Recovering{color:#cc6}
.Completed{color:blue}

    
    
</style>
<body >

<div class="wrapper">


<div id="page">

<div class="row-fluid" style="width:100%">
<div class="span12" style="width:100%">



<div id="endoscopy_nurse" class="  portlet " >
<img src='/esm/cusys/colorectal/login-logo-white.png' width="400" style="float:right;margin-top:-10px"/>
<span>
<b>ห้องส่องกล้อง Surgical Endoscopy</b>

<div style="margin-top:10px" id="table">
<div id="board">
</div>
</div></div></div></div></div>
<script>
numpage = 1;
page = 0;

function update(data){
    
}

function executeQuery() {
  $.ajax({
    url: 'status_feed_partial?page='+page,
    success: function(data) {
      //  alert("update");
      // do something with the return value here if you like
      $('#board').fadeOut(500, function(){
      $('#board').html(data);
      })
      $('#board').fadeIn(500)
    }
  });
  setTimeout(executeQuery, 10000); // you could choose not to continue on failure...
}

function setPage(i){
    page = i;
   // alert("set to "+i);
}

$(document).ready(function() {
  // run the first time; all subsequent calls will take care of themselves
  setTimeout(executeQuery, 0);
});
</script>
</body>
</html>


HTML
return render_template(com,self,params)

        end
    

        def print_report *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
    values = %w{Elective Emergency Extratime}

    date = Time.now
    
    total = 0
    totals = {}
    
    if params[:print]
    date = params[:print][:date]
    date = Date.parse(date)
    end    
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    patients = []
    
    status_list=%w{appointed waiting processing completed cancelled no_show}.collect{|i| i.humanize}
     
    other_status = {'Cancelled'=>0, 'Postpone'=>0} 
     
    
    mname = "\#{@current_project.name}#appointment"
    forms = %w{colonoscopy gastroscopy}
    
    models = get_model
    ap_model = models[:appointment]
    p_model = models[:provider]
    aps = ap_model.all(:date.gte=>date.at_beginning_of_day,:date.lt=>date.end_of_day) 
    list = aps.clone
    id = ''
    
      aps.collect!{|i|
      other_status[i.status] = 0 unless other_status[i.status]
      other_status[i.status] += 1 
    id = i.id
      if m = module_model.first(:module_name=>mname,:module_id=>i.id)
         patient = patient_model.find(m.patient_id)
         provider = p_model.find(i.provider)
         
         procedure_text = '-'
         procedure = models[:procedure].find(i.procedure)
         procedure_text = procedure.name if procedure
         
        c = {:ref_number=>m.ref_number,
            :public_id=>patient.public_id,
            :hn=>patient.hn,
            :patient=>link_to("\#{patient.first_name} \#{patient.last_name}","../../www/Patient/edit?id=\#{patient.id}&return=\#{request.fullpath}"),
            :patient_id=>patient.id.to_s,
            :provider=>"",
            :date=>i.date,
            :note=>i.note,
            :status=>nil,
            :procedure=>procedure_text,
            :module=>m,
            :appointment=>i
         }
         
        jname = "\#{@current_project.name}#intra_scope"
        m = module_model.where(:module_name=>jname,:parent_id=>m.id.to_s).first
        
        if m and intra = models[:intra_scope].find(m.module_id)
            c[:no_specimen] = intra.specimen
            
          
            
            if !intra.endoscopy_nurse.empty?
            tt = models[:time_to_time]
            for x in  intra.endoscopy_nurse
            tx = tt.find(x)
            if tx and px = p_model.find(tx.endoscopy_nurse)
            c[:provider]+="<br/>N:"+ px.name 
            end
            end
            end
            
            if intra.assistant1
            if px = p_model.find(intra.assistant1)
            c[:provider]+="<br/>A:"+ px.name 
            end
            end
            if intra.assistant2
            if px = p_model.find(intra.assistant2)
            c[:provider]+="<br/>A:"+ px.name 
            end
            end
            
        end
        
     end
      
      c
      
      }
    
    list = []
    
    summary = {}
    
    status_summary = {}
    
    total_summary = {}
    
    
    aps.compact!
    
    for i in aps
    
    mm = i[:module]
    
    status = ''
    
    preprovider = i[:provider]
    
    
    i[:patho] = false
    jname = "\#{@current_project.name}#pathology"
    m = module_model.where(:module_name=>jname,:parent_id=>mm.id.to_s).first
    if m
       i[:patho] = true 
    end
    
    
    
      
    for j in forms
        jname = "\#{@current_project.name}#\#{j}"
        m = module_model.where(:module_name=>jname,:parent_id=>mm.id.to_s).first
        if m
            data = models[j.to_sym].find(m.module_id)
            
            if data
                # summary
                summary[i[:patient_id]] = {} unless summary[i[:patient_id]]
                status_summary[data.status] = {} unless status_summary[data.status]
                status_summary[data.status][i[:patient_id]] = true unless status_summary[data.status][i[:patient_id]]
                
                # summary
                summary[i[:patient_id]][j] = true
                
                i[:time] = data.start_at.strftime("%H:%M")+"-"+data.stop_at.strftime("%H:%M")+" (\#{((data.stop_at-data.start_at)/60).to_i})"
                
                i[:procedure]= j.humanize
                i[:add_procedure] = data.procedure.split("|").join(", ")
                i[:diagnosis_group] = data.diagnosis_group.split("|").join(", ")
                i[:status] = data.status;
                status = data.status;
                sedation = "No sedation"
                any_sedation = false
                sedation_list = ['dormicum','pethidine','diprivan','valium','buscopan','plasil','fentanyl'].collect{|s| 
                if data[s]=="true"
                    any_sedation = true
                    iv_field = s+'_num'
                    if j=='colonoscopy'
                        case s
                        when 'buscopan'
                            iv_field = 'buscopan_route'
                        when 'fentanyl'
                            iv_field = 'fentanyl_routh'
                        when 'plasil'
                            iv_field = 'plasil_route'
                        end
                    elsif j=='gastroscopy'
                        case s
                        when 'buscopan'
                            iv_field = 'route_buscopan'
                        when 'fentanyl'
                            iv_field = 'fentanyl_route'
                        when 'plasil'
                            iv_field = 'plasil_route'
                        end
                    end
                    
                    "\#{s.humanize} \#{data[s+'_mg']} mg \#{data[iv_field]}" 
                end
                }.compact.join("<br/>")
        
                sedation = sedation_list if any_sedation
                
                i[:sedation] = sedation
                i[:bowel_prep] = data.quality_of_preparate
                
                prov = ""
             
                if data.endoscopist_1
                    if px = p_model.find(data.endoscopist_1)
                        prov = "E:\#{px.name}."
                    end
                end
            
            
                if data.endoscopist_2
                    if px = p_model.find(data.endoscopist_2)
                        prov+="<br/>E:"+ px.name 
                    end
                end
            
                i[:provider]= "\#{prov}\#{preprovider}"
                
                totals[i[:status]]={} unless totals[i[:status]]
                totals[i[:status]][j]=0 unless totals[i[:status]][j]
                totals[i[:status]][j]+=1
                
                ls = []
                if j == 'colonoscopy'
                    ls = ['rectum_scope','sigmoid_scope','descending_colon_scope','transvers_colon_scope','ascending_colon_scope','cecum_scope','terminal_ileum_scope']
                    ms = 'colonoscopy_scope'
                else
                    ls = ['pharynx_scope','esophagus_scope','egj_scope','fundus_scope','cardia_scope','body_scope','antrum_scope','first_duodenum_scope','sphincter_of_oddi_scope','second_duodenum_scope','third_duodenum_scope','forth_duodenum_scope','proximal_jejunum_scope','distal_jejunum_scope']
                    ms = 'gastroscopy_scope'
                end
                count = 0
                max = 0
                c = 0
                
   
        ls.each{|lc| 
            if data[lc] and !data[lc].empty?
                #count+=data[lc].size
                
                ll = models[ms.to_sym].find(data[lc])
              
                for li in ll
                    #z = li.patho_number.to_i if li.patho_number
                    #max = z if z>max
                    count+=1 if li.patho_number!='' and li.patho_number!='Loss'
                end
            end
        }
        
        
        i[:no_specimen] = (count).to_s
        
        
    
        
        
        list << i.clone  
        
        else
        %>
        <%#m.inspect%>
        <%
        end
        
        end
        
        
        
                 

     end  

     if i and i[:status] and totals[i[:status]]
        totals[i[:status]]['patient']=0 unless totals[i[:status]]['patient']
        totals[i[:status]]['patient']+=1
     end

     
    end
    
    aps = list.sort{|a,b| a[:time]<=>b[:time]}

    apss = {}
    
    values.size.times do |j|
    apss[values[j]] = aps.collect{|i| i if i[:status]==values[j] }.compact
    end



%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>PRINT</title>
</head>
<style type="text/css" media="print,screen">
html { }
value {color:#06F}
imvalue { color:#F00; font-weight:bold}
imvalue value { color:#F00; font-weight:bold}
#page {border:solid 1px; width:910px; border-color:#666;
-webkit-border-radius: 5px; /* Safari prototype */
-moz-border-radius: 5px; /* Gecko browsers */
border-radius: 5px; /* Everything else - limited support at the moment */
margin-bottom:5px; padding-bottom:5px; padding-left:20px;padding-right:20px; }
#head { width:100%; height:60px;}
#logoleft { margin-left:20px; float:left;}
#logoright{ margin-right:20px; float:right;}
th              { font-weight: bolder; text-align: center }
caption         { text-align: center }
body            {   font-family: Arial, Helvetica, sans-serif; color:#000;background:none;font-size:11pt;}
.wrapper{ width:960px;margin-left:auto;margin-right:auto} 
hr    {clear: both;border: none;border-top: 1px solid #AAA;border-bottom: 1px solid #FFF; font-size: 1px;line-height: 0;overflow: visible; width:98%;}
h1              { font-size: 2em; margin: .67em 0 }
h2              { font-size: 1.5em; margin: .83em 0 }
h3              { font-size: 1.17em; margin: 1em 0 }
p {color:#666;}
h4, p,
blockquote, ul,
form,
ol, dl          { margin: 0.5em; }
h5              { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }
h6              { font-size: .67em; margin: 2.33em 0 }

h4 { font-size:14pt; color:#333; height:16px;}
blockquote      { margin-left: 40px; margin-right: 40px }
i, cite, em,
var, address    { font-style: italic }
pre, tt, code,
kbd, samp       {  font-size:14px; }
pre             {margin:0;margin-left:1em; color:#666}
big             { font-size: 1.17em }
v {color:#2561cD;}
small, sub, sup { font-size: .83em }
ol, ul, dd      { margin-left: 40px }
ol              { list-style-type: decimal }
ol ul, ul ol,
ul ul, ol ol    { margin-top: 0; margin-bottom: 0 }
.clear{clear:both;}
@media print {
  @page         { width:960px; margin-top:0; }
  blockquote, 
 .wrapper{ width:960px;margin-left:55px;margin-right:auto} 
  table { page-break-after:auto; -fs-table-paginate: paginate; }
  tr    { page-break-inside:avoid; page-break-after:auto }
  td    { page-break-inside:avoid; page-break-after:auto }
  thead { display:table-header-group;     margin-top:10px;}
  tfoot { display:table-footer-group }

}

#box{
    width:150px;
    float:left;
    padding:10px;
    text-align:center;
    border:1px solid #ccc;
    -webkit-border-radius: 5px; /* Safari prototype */
    -moz-border-radius: 5px; /* Gecko browsers */
    border-radius: 5px; /* Everything else - limited support at the moment */    
    margin:10px;
}
.smm { font-size:0.5em; border:1px solid;border-color:#ccc;}
#box img{
        width:150px;
}
label{
    color:#666; font-weight:bold;
}

#table-3 {
    border: 1px solid #DFDFDF;
    background-color: #F9F9F9;
    width: 100%;
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
	font-family: Arial,"Bitstream Vera Sans",Helvetica,Verdana,sans-serif;
	color: #333;
}
#table-3 td, #table-3 th {
	border-top-color: white;
	border-bottom: 1px solid #DFDFDF;
	color: #555;
}
#table-3 th {
	text-shadow: rgba(255, 255, 255, 0.796875) 0px 1px 0px;
	font-family: Georgia,"Times New Roman","Bitstream Charter",Times,serif;
	font-weight: normal;
	padding: 7px 7px 8px;
	text-align: left;
	line-height: 1.3em;
	font-size: 14px;

}
#table-3 td {
	font-size: 12px;
	padding: 4px 7px 2px;
	vertical-align: top;
	background:#FFF;
}
thead {
    display:table-header-group;

}
tbody {
    display:table-row-group;
}
</style>
<body>

<div class="wrapper">
<div id="head">
<div id="logoleft"><img src='/esm/cusys/colorectal/login-logo.png' width="300" /></div>
<div id="logoright">
<p>Reported by :&nbsp;<%= @current_user.login.humanize %></p>
<p>Printed at :&nbsp;<%= Time.now %></p>
</div>
</div>

<div id="page">

<div class="row-fluid">
<div class="span12">

<div class="w-box">
<br />
<b>ตารางแสดงผู้ป่วยเข้ารับการส่องกล้องห้องส่องกล้อง Surgical endoscopy 
<span style="float:right">ประจำวันที่ 
<%= date.strftime("%d %B %Y")%></b>
</span>
<br /><br />
<%
 
 line = 0 
  for x in values 
  line += 1 
  aps = apss[x]
  
  if aps.size>0 
%>
<h2><%=x%></h2>
<table width="100%" border="1" cellspacing="0" cellpadding="0" id="table-3">
  <thead>
  <tr>
    <th>No.</th>
    <th>เวลา(นาที)</th>
    <th style="width:150px">ชื่อ - สกุล</th>
    <th>Quality Prep</th>
    <th style="width:150px">Sedation</th>
    <th>Procedure</th>
    <th>Add procedure</th>
    <th style="width:150px">Endoscopist</th>
    <th>Diagnosis group</th>
    <th>No. of Specimen</th>
  </tr>
  </thead>
  
  
  <tbody>

  <%
   count = 0
    
  for i in aps 

  %>
 <!---
Let's now create a ton or rows that will require
several pages to fully print.
--->

  <tr>
  <td><%= count+=1 %>. </td>
    <td> <%= i[:time] %></td>
    <td><%= i[:patient] %><br /><%= i[:hn] %><br /><%= i[:public_id] %></td>
    <td><%= i[:bowel_prep].html_safe  if i[:bowel_prep]%></td>
    <td><%= i[:sedation].html_safe  if i[:sedation]%></td>
    <td><%= i[:procedure] %></td>
    <td><%= i[:add_procedure] %></td>
    <td><%= i[:provider].html_safe %></td>
    <td><%= i[:diagnosis_group] %></td>
    <% if i[:patho] or i[:no_specimen]=='0' 
    
        total_summary[x] = {} unless total_summary[x]
        total_summary[x][:patho] = 0 unless  total_summary[x][:patho]
        total_summary[x][:patho] += i[:no_specimen].to_i 
    
    %>
    <td ><%= i[:no_specimen] %></td>
    <% else %>
    <td style="color:red"><%= i[:no_specimen] %>- CREATE PATHO</td>
    <% end %>
      
  </tr>
  
  <% 



 
    
    if line%15==14
  %>
  </tbody>
  </table>
  <br/><br/>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" id="table-3" style="page-break-before:always">
  <thead>
  <tr>
    <th>No.</th>
    <th>เวลา(นาที)</th>
    <th style="width:150px">ชื่อ - สกุล</th>
    <th>Quality Prep</th>
    <th style="width:150px">Sedation</th>
    <th>Procedure</th>
    <th>Add procedure</th>
    <th style="width:150px">Endoscopist</th>
    <th>Diagnosis group</th>
    <th>No. of Specimen</th>
  </tr>
  </thead>
  <tbody>
  <%
    end 
     line += 1 
  %>
  
  <% end  %>
  
  </tbody>
</table>

<br/>

<% end %>

<% end %>
<%
if false
%>

<h2>Summary</h2>
<%# totals.inspect%>
<table  border="1" cellspacing="0"  cellpadding="5" id="table-3" style="width:400px">
<tr  align="center"><td>&nbsp;</td>
<% for j in forms %>
<td><%= j.humanize %></td>
<% end %><td>Total patients</td>
</tr>
<% for i in values 
    if totals[i]
%>
<tr align="center"><th><%=i%></th>
<% for j in forms %>
<td ><%= totals[i][j] %></td>
<% end %>
<td><%= totals[i]['patient']%></td>
</tr>
<% 

end 
end %>
</table>

<% end %>


<%



    map = {}
    
    status_summary.each_pair do |key,value|
        
        map[key] = {'Colonoscopy'=>0,'Gastroscopy'=>0, 'Colonoscopy+Gastroscopy'=>0,'Total'=>0}
        
        
        for i in value.keys
            
            pp = summary[i]
            
            if pp['colonoscopy'] and pp['gastroscopy']
                 map[key]['Colonoscopy+Gastroscopy']+=1   
            elsif pp['colonoscopy']
                 map[key]['Colonoscopy']+=1
            elsif pp['gastroscopy']
                 map[key]['Gastroscopy']+=1
            end
            
            map[key]['Total']+=1
            
        end
        
        
    end

    list = %w{ Colonoscopy Gastroscopy Colonoscopy+Gastroscopy Total }



%>
<%#total_summary.inspect  %>

<h2>Summary</h2>
<%# totals.inspect%>
<table  border="1" cellspacing="0"  cellpadding="5" id="table-3" style="width:400px">
<tr  align="center"><td>&nbsp;</td>
<% for j in list %>
<td><%= j %></td>
<% end %><td>No specimen</td>
</tr>
<% for i in status_summary.keys
if map[i] and total_summary[i]
if map[i]['Total'] > 0 
%>
<tr align="center"><th><%=i%></th>
<% for j in list %>
<td ><%= map[i][j] %></td>
<% end %><td><%=total_summary[i][:patho] %></td>
</tr>
<% 

end

end 
end %>
</table>

<%


    visits = models[:visit_type].all
    vmap = {}
    for i in visits
        vmap[i.id] = i.name
    end

    cancelled = 0
    postpone = 0
    aps_other = ap_model.all(:date.gte=>date.at_beginning_of_day,:date.lt=>date.end_of_day,:status=>{'$in'=>['Cancelled','Postpone','No show']}) 
    
    %>
    <%#aps_other.inspect %>
    <%
    for i in aps_other
        
        visit = vmap[i.visit_type]
        visit = 'Elective' unless visit
        
        if total_summary[visit] and i
        
        
        if i.status=='Cancelled'
        
            total_summary[visit]['cancelled']=0 unless  total_summary[visit]['cancelled']
            total_summary[visit]['cancelled']+=1
            
        elsif i.status=='Postpone'
            total_summary[visit]['postpone']=0 unless  total_summary[visit]['postpone']
            total_summary[visit]['postpone']+=1
            
        elsif i.status=='No show'
            total_summary[visit]['no_show']=0 unless  total_summary[visit]['no_show']
            total_summary[visit]['no_show']+=1
        end
        
        end
        
    end
    if aps_other.size > 0 
%>
<h2>Cancelled & Postpone</h2>

<div style="">
<table  border="1" cellspacing="0"  cellpadding="5" id="table-3" style="width:200px">

<tr  align="center">
<th>&nbsp;</th>
<th>Cancelled</th>
<th>Postpone</th>
<th>Total</th>

</tr>

<% total_summary.keys.each do |i| 

c = total_summary[i]['cancelled']
p = total_summary[i]['postpone']
s = total_summary[i]['no_show']
c = 0 unless c
p = 0 unless p
s = 0 unless s

sum = c+p+s

%>

<tr  align="center">
<td> <%= i %></td><td><%=c+s%></td>
<td> <%= p %></td>

<td> <%= sum %></td>
</tr>    

<% end %>
    
    
</table>

</div>




<% end %>
</div>
</div>
</div>
</div>





<%#totals.inspect %>

<div class="clear">
</div>

</div>
<script>
window.print()
</script>
</body>
</html>





HTML
return render_template(com,self,params)

        end
    

        def index *params
            @params = params[0] if params[0]
            ret = com=<<-HTML

<% if @current_role == 'pathologist' %>
<%= render :inline=>this.patho_index %>
<% else %>
<%
  module_name = @current_project.name
 if params[:date]
  session[module_name]={:date=>params[:date]}
 end
 if session[module_name]
    params[:date] = session[module_name][:date]
 end
 unless params[:date]
 params[:date] = Time.now.strftime('%d/%m/%Y')
 end
%>
<%#session[module_name].inspect %>
<%

 if params[:obj_id]
 now = Time.now 

 

 
 
%>
<meta http-equiv="Refresh" content="0; url=../Appointment/create?patient_id=<%=params[:obj_id]%>&data[date]=<%=now.strftime('%Y-%m-%d')%>&data[start]=<%=now.strftime('H:M')%>&data[stop]=<%=now.strftime('H:M')%>">
<%
 end
%>

<div class="row-fluid">
<div class="span8">
<div class="w-box">
    <div class="w-box-header">
       Dashboard
    </div>  
    <div class="w-box-content cnt_a">
<center><b>Welcome to <span style="color:#F3790D">EMR</span>-LIFE, <%= @current_project.title %> Module</b></center><br/>

<center>

<a href="../Appointment/create?return=../Home/index&data[date]=<%=Date.strptime(params[:date], '%d/%m/%Y') %>"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-contact_grey_add"></i><br />Appointment</button></a>

<!--<a href="../../www/Patient/create?return=../../<%=@current_project.name%>/Home/index"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-add"></i><br /> New Patient</button></a>
-->
<a href="../Appointment/index"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-calendar_month"></i><br />Appointment</button></a>


<a href="<%=url_for('print_appointment?print[date]='+params[:date]) %>"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-printer"></i><br />Print daily <br/>appointment</button></a>
<a href="<%=url_for('print_report?print[date]='+params[:date]) %>"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-printer"></i><br />Print daily <br/>report</button></a>

<% if  @current_role=='admin' or @current_role=='superadmin'  or @current_role=='developer' %>

<a href="../Report/index"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-view_outline"></i><br />Reports</button></a>


<% else %>

<a href='javascript:alert("You are not allowed!!")'><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-view_outline"></i><br />Reports</button></a>


<% end %>



<a href="../Attendance/index?date=<%=params[:date]%>">
<%

   attendance_check = false
   date = params[:date].to_mongo
   myDate =  Date.parse(date);
   models = get_model
   attendance = models[:attendance].where('date'=>{'$lte'=>myDate.end_of_day, '$gte'=>myDate.beginning_of_day}).first
    attendance_check = attendance!=nil
    icon = 'contact_blue_add'
    icon = 'check' if attendance and attendance.payroll_check=='true'
%>
<button class="btn <%='btn-danger' unless attendance_check%><%='btn-success' if attendance and attendance.payroll_check!='true'%>" style="width:120px;height:80px;margin:5px"><i class="splashy-<%=icon%>"></i><br />Extratime</button></a>



<!--<a href="status_feed"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-view_outline_detail"></i><br />Status</button></a>
-->
<%
if false
%><a href="attachment"><button class="btn" style="width:120px;height:80px;margin:5px"><i class="splashy-view_outline_detail"></i><br />Attachments</button></a>
<% end %>
</center>
    </div>
    </div>
</div>
<div class="span4">
<div class="w-box">
    <div class="w-box-header">
        Status
    </div>  
    <div class="w-box-content cnt_a" style="padding-bottom:0px">
        <div class="alert alert-block alert-info" >
                
        <%
       begin        
            date = Time.now
            date = Date.strptime(params[:date], '%d/%m/%Y') if params[:date]
        %>
                Date <%= text_field_tag 'date',date,:id=>'today-date',:onchange=>'alert' %> <br/>

        <h1><%= Time.now.strftime("%H : %M") %></h1>
        
        <%=link_to "\#{ thdate date }", "../Home/index?date=\#{Time.now.strftime('%d/%m/%Y')}", :style=>'font-size:1.5em' %><br/>

        </div>

    <script>
    $("#today-date").kendoDatePicker({
        value: '<%= date.strftime("%d/%m/%Y") %>',
        change: function(){
            window.location = "../Home/index?date="+kendo.toString(this.value(), 'd')
        }
	});
</script>
<% rescue %>
  error
<% end %>
    </div>
    </div>
</div>
</div>

<div class="clear"></div>
<br/>


<style>

.provider{
    color:black;
}

.status_cls{
width:100px
}
</style>
<script>
function change_status(obj){
  if(confirm("Are you sure to update status to "+obj.value + " ?")){
   window.location="update_status?id="+obj.id+"&status="+obj.value;
  }
 }
</script>
<%
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    patients = [] 
    mname = "\#{@current_project.name}#appointment"
   # patients =  module_model.all(:module_name=>mname)
    status_list=%w{appointed confirmed waiting preparing processing recovering completed cancelled postpone no_show}.collect{|i| i.humanize}
    sort_list=%w{preparing waiting  processing confirmed appointed  recovering completed cancelled no_show}.collect{|i| i.humanize}

    
    models = get_model
    
    locker_model = models[:locker]
    #if locker_model
    #locker_model.where(:session=>session[:session_id]).all.each do |i|
    #i.destroy if i
    #end
    #end
    
    
    ap_model = models[:appointment]
    p_model = models[:provider]
    v_model = models[:visit_type]
    visits = {}
    vsort_list = ['Elective','Emergency','Extratime']
    v_model.all.sort{|a,b| vsort_list.index(a.name)<=>vsort_list.index(b.name) }.each do |i|
       
            visits[i.id]=i.name
       
    end
    
    
    indications = {}
    models[:indication].all.each do |i|
        indications[i.id]=i.name
    end
    
    aps = ap_model.all(:date.gte=>date.at_beginning_of_day,:date.lt=>date.end_of_day) 
    for a in aps
        a.update_attributes :status=>'Completed' if a.status==''
    end
    %>
    <%# aps.inspect %>
    <%
    
    
    m_patients = {}
    m_modules = {}
    m_providers = {}
    
    module_model.where(:module_id=>aps.collect{|i| i.id }).all.each do |m|
        m_modules[m.module_id] = m 
    end
    
    patient_model.find(m_modules.values.collect{|i| i.patient_id}).each do |p|
       m_patients[p.id] = p 
    end
    
    p_model.all.each do |p|
       m_providers[p.id] = p 
    end
    
    
    list = aps.clone
    id = ''
    aps.collect!{|i| 
    id = i.id
      if m = m_modules[i.id] #module_model.first(:module_name=>mname,:module_id=>i.id)
         patient = m_patients[m.patient_id] #patient_model.find(m.patient_id)
         if patient
         provider = m_providers[i.provider] #p_model.find(i.provider)
         visit_type = visits[i.visit_type]
         
         provider_name = '-'
         provider_name = provider.name if provider
         procedure_name = '-'
         pro = models[:procedure].find(i.procedure) 
         procedure_name = pro.name if pro
         patient = patient_model.new unless patient 
         hn = '-'
         hn = link_to(patient.hn, "../Appointment/show?id=\#{m.id}") if patient
         public_id = '-'
         public_id = patient.public_id if patient
         
         ############### endoscopist provider
         if i.status == 'Completed' or i.status=='Recovering' or i.status=='Processing'
         mcolo = module_model.first(:module_name=>"\#{@current_project.name}#colonoscopy",:parent_id=>m.id)
         if mcolo
              colo = models[:colonoscopy].find(mcolo.module_id)
              provider = m_providers[colo.endoscopist_1] #p_model.find(colo.endoscopist_1)
              provider_name = '-'
              provider_name = provider.name if provider
         else
         
         
         mcolo = module_model.first(:module_name=>"\#{@current_project.name}#gastroscopy",:parent_id=>m.id)
         if mcolo
              colo = models[:gastroscopy].find(mcolo.module_id)
              provider = m_providers[colo.endoscopist_1] #p_model.find(colo.endoscopist_1)
              provider_name = '-'
              provider_name = provider.name if provider
         end
         
         
         
         
         end
         
         
         
         
         end
         ################
         note_ctrl = ''
         if i.status =='Appointed'
         pending_ctrl = link_to('Confirm',"update_status?id=\#{i.id}&status=Confirmed",:class=>'btn btn-small btn-success')+' '
         pending_ctrl += link_to('Walk-in',"update_status?id=\#{i.id}&status=Waiting",:class=>'btn btn-small btn-info')
        #  pending_ctrl += link_to('No show',"update_status?id=\#{i.id}&status=No show",:class=>'btn btn-small btn-warning')
         #pending_ctrl += link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small')

         elsif i.status =='Confirmed'
         pending_ctrl = link_to('Arrive',"update_status?id=\#{i.id}&status=Waiting",:class=>'btn btn-small btn-success')+' '
         pending_ctrl += link_to('Cancel',"update_status?id=\#{i.id}&status=Cancelled",:class=>'btn btn-small btn-warning')+' '
         pending_ctrl += link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small')

         elsif i.status =='Waiting'
         pending_ctrl = link_to('Start',"update_status?id=\#{i.id}&status=Preparing",:class=>'btn btn-small btn-success')+' '
         
         premname = "\#{@current_project.name}#pre_scope"
         
         prem = module_model.first(:module_name=>premname,:parent_id=>m.id)
   
         if prem
             
         pre_scope_record = models[:pre_scope].find(prem.module_id)     
             
         provider = provider_name
         name = patient.first_name + " " +patient.last_name
         date = Time.now.strftime("%d-%m-%Y")
         procedure = procedure_name.strip.gsub(/&/,'-')
         hn = patient.hn
         
          age = '-'
            if patient.birth_date and patient.birth_date!=''
                age = (Time.now - patient.birth_date.to_datetime) / 365 /3600/24
                age = age.to_i.to_s+" yrs"
            end
            gender = '-'
            if patient.gender
                gender = 'Male' if patient.gender=='1'
                gender = 'Female' if patient.gender=='2'
                
            end
        
         paramsx = {:class=>'btn btn-info',:target=>'_blank'}
         disease_txt = ''
         disease = false
         anti = false
         
         if pre_scope_record.previous_illness and pre_scope_record.previous_illness.index("HIV") or pre_scope_record.previous_illness.index("Hepatitis") 
         disease_txt = pre_scope_record.previous_illness.split("|").collect{|i| i if i.index("HIV") or i.index("Hepa")}.compact.join(", ")
        #  procedure+=" "+disease_txt
        #  procedure
         disease = true
         end
         
         if pre_scope_record.on_anticoaglant_anti_platelet!='No'
         anti = true 
         end
             
         if anti and disease 
         
         paramsx[:data] = {:confirm=>'Patient with underline disease was found with anti-platelet, Please change wristband to "VIOLET - RED"'}     
    
         elsif disease == true
         
         paramsx[:data] = {:confirm=>'Patient with underline disease was found, Please change wristband to "VIOLET"'}     
             
         elsif anti 
         
         paramsx[:data] = {:confirm=>'Patient is on anti-platelet, Please change wristband to "RED"'}     
         
         end
         
         
         
         wrist_band_url = "../Appointment/print_sticker?cmd=print&queue=esm-pi&age=\#{age}&gender=\#{gender}&provider=\#{provider}&name=\#{name}&date=\#{date}&proc=\#{procedure}&hn=\#{hn}"
        
         
            
         pending_ctrl += link_to('WristBand',wrist_band_url,paramsx)+' '
         end
         pending_ctrl += link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small')


         
         elsif i.status =='Preparing'
         pending_ctrl = link_to('Process',"update_status?id=\#{i.id}&status=Processing",:class=>'btn btn-small btn-success')+' '
         pending_ctrl += link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small')
         elsif i.status =='Processing'
        #  pending_ctrl = link_to('Recovery',"update_status?id=\#{i.id}&status=Recovering",:class=>'btn btn-small btn-success')+' '
         pending_ctrl = link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small btn-info')
         elsif i.status =='Recovering'
         pending_ctrl = link_to('Complete',"update_status?id=\#{i.id}&status=Completed",:class=>'btn btn-small btn-success')+' '
         pending_ctrl += link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small')
         else
         pending_ctrl = link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small')
         end
         
         
            billing_m = module_model.collection.find({:module_name=>"\#{@current_project.name}#billing",:parent_id=>m.id}).first
            if billing_m
                billing = models[:billing].collection.find(:_id=>billing_m['module_id']).first
                if billing and billing['paid']!='true'
                    pending_ctrl += link_to('Paid',"paid?id=\#{billing['_id']}",:class=>'btn btn-small btn-danger',:data=>{:confirm=>'Are you sure?'})
                else
                    if billing
                        pending_ctrl += "&nbsp;<v style='color:blue'>ชำระเงินแล้ว</v>".html_safe
                    end
                end
            end
         
        #  pending_ctrl = @current_role 
         status_ctrl=i.status 
         status_ctrl=select_tag('name',options_for_select(status_list,i.status),:class=>'status_cls',:id=>i.id,:onchange=>'change_status(this)') if @current_role=='developer' or @current_role=='admin'
        
        c = nil
        if patient
         
         c = {:ref_number=>m.ref_number,:public_id=>public_id,:hn=>hn,:patient=>link_to("\#{patient.prefix_name} \#{patient.first_name} \#{patient.last_name}","../../www/Patient/edit?id=\#{patient.id}&return=\#{request.fullpath}"),
         :provider=>provider_name,:date=>i.date,:note=>"\#{note_ctrl} \#{visit_type} \#{indications[i.indication]} \#{i.note}",:status=>i.status,:procedure=>procedure_name,
         :status_ctrl=>status_ctrl,
         :pending_ctrl=>pending_ctrl,
         :cancel_reason=>i.cancel_reason,
         :postpone_to=>i.postpone_to,
         :visit_type=>visit_type, :updated_at=>i.updated_at
         }
         
         
    end
         
        #  if i.status=='Waiting'
        #  c[:pending_ctrl]=link_to('Process',"update_status?id=\#{i.id}&status=Processing",:class=>'btn btn-small btn-success') +' '
        #  c[:pending_ctrl]+=link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small ')+" "

        #  #c[:processing_ctrl]=link_to('Process',"update_status?id=\#{i.id}&status=Processing",:class=>'btn btn-small btn-success') 
        #  else
        #  status = 'btn-info'
        #  status = '' if i.status =='Completed'
        #  c[:processing_ctrl]=link_to('Detail',"patient_record?id=\#{i.id}",:class=>'btn btn-small '+status)
        #  end
         c
     end
      end
    }.compact!
    
    # aps.sort!{|a,b| t = sort_list.index(a[:status])<=>sort_list.index(b[:status]); t = a[:provider]<=>b[:provider] if t==0; t = a[:updated_at]<=>b[:updated_at] if t==0 ; t }


    
    arriving = aps.collect{|i| i if i[:status]=='Appointed' or  i[:status]=='Pending' or i[:status]=='Confirmed' }.compact

    waiting = aps.collect{|i| i if i[:status]=='Waiting' or i[:status]=='Preparing'}.compact
    
    processing = aps.collect{|i| i if i[:status]=='Processing' }.compact
    
    completed = aps.collect{|i| i if i[:status]=='Recovering' or i[:status]=='Recovery' or i[:status]=='Completed' }.compact
    completed.sort!{|a,b| a[:updated_at]<=>b[:updated_at] }
    
    cancelling = aps.collect{|i| i if i[:status]=='No show' or i[:status]=='Cancelled' or i[:status]=='Postpone' }.compact
    
    
    table_model = %w{public_id hn patient provider procedure status_ctrl}.collect{|i| i.to_sym}
    
    waiting.sort!{|a,b| t = sort_list.index(a[:status])<=>sort_list.index(b[:status]); t = a[:provider]<=>b[:provider] if t==0; t = b[:updated_at]<=>a[:updated_at] if t==0 ; t }
    arriving.sort!{|a,b| t = sort_list.index(a[:status])<=>sort_list.index(b[:status]); t = a[:provider]<=>b[:provider] if t==0; t = b[:updated_at]<=>a[:updated_at] if t==0 ; t }

    processing.sort!{|a,b| t = sort_list.index(a[:status])<=>sort_list.index(b[:status]); t = a[:provider]<=>b[:provider] if t==0; t = a[:updated_at]<=>b[:updated_at] if t==0 ; t }


    
    #[:ref_number,:date,:patient,:provider,:status_ctrl,:note,:pending_ctrl]
    
    labels = {:hn=>'HN',:public=>'Public',:patient=>'Patient',:provider=>'Appointed Doctor',:status_ctrl=>'Status',:pending_ctrl=>'Appointed ctrl',
    :note=>'Note',:visit_type=>'Group' }
    
%>



<%
    providers = {}
    
    for i in processing
        p = i[:provider]
        providers[p]=[] unless providers[p]
        providers[p].push i
    end
    

%>

<div class="left alert-info" style="width:100%;;border:0px solid">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Processing 
	    <div class="pull-right"><i class=""><%=processing.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        <% providers.each_pair do |k,v| %>
        <span class="provider"><%= k %></span><br/>
            <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>providers[k],:col_width=>{:pending_ctrl=>220},:labels=>labels %>
        <% end %>
    </div>
    </div>
</div>


<div class="clear"></div>
<br/>


<div style="width:100%;border:0px solid; background:#ebe9d3">
<div class="left" style="width:100%;">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
	        Today Patients : Arrvived and pareparing 
     
	    <div class="pull-right"><i class=""><%=waiting.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        
           <% 
           
           for visit in visits.values
            tmp = waiting.collect{|w| w if  w[:visit_type]==visit }.compact
           %>
           <% if tmp.size>0 
           color = ''
           color = 'red' if visit =='Emergency'
           %>
    
        <font color="<%=color%>">
        <%=visit%>
	        <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>tmp,:col_width=>{:pending_ctrl=>220},:labels=>labels %>
        </font>
        
            <% end %>  <% end %>
        
        <% if tmp = waiting.collect{|w| w if w[:visit_type]==nil }.compact and tmp.size>0 %>    
        <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>tmp,:col_width=>{:pending_ctrl=>220} ,:labels=>labels %>
        <% end %>
        </div>
    </div>
</div>
<div class="clear"></div>
</div>
<br/>




<div style="width:100%;border:0px solid">
<div class="left " style="width:100%;">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
	        Today Patients 
     
	    <div class="pull-right"><i class=""><%=arriving.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        
           <% 
           
           for visit in visits.values
            tmp = arriving.collect{|w| w if  w[:visit_type]==visit }.compact
           %>
           <% if tmp.size>0
           color=''
           color='red' if visit=='Emergency'
           %>
             <font color="<%=color%>">
        <%=visit%>
        <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>tmp,:col_width=>{:pending_ctrl=>220},:labels=>labels %>
            </font>
            <% end %>  <% end %>
            
        <% if tmp = arriving.collect{|w| w if w[:visit_type]==nil }.compact and tmp.size>0 %>    
        <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>tmp,:col_width=>{:pending_ctrl=>220} ,:labels=>labels %>
        <% end %>
        </div>
    </div>
</div>
<div class="clear"></div>
</div><br/>





<%
    providers = {}
    
    for i in completed
        p = i[:provider]
        providers[p]=[] unless providers[p]
        providers[p].push i
    end
    

%>

<div class="left alert-success" style="width:100%;border:0px solid;">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Completed 
        <div class="pull-right"><i class=""><%=completed.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        <%
        plabels = labels.merge :provider=>'Endoscopist'
        providers.each_pair do |k,v| %>
        <span class="provider"><%= k %></span><br/>
            <%= tabular :model=>table_model+[:pending_ctrl,:note],:data=>providers[k],:col_width=>{:pending_ctrl=>220},:labels=>plabels %>
        <% end %>
    </div>
    </div>
</div>


<div class="clear"></div>

<br/>


<%
    providers = {}
    
    for i in cancelling
        p = i[:provider]
        providers[p]=[] unless providers[p]
        providers[p].push i
    end
    

%>
<div class="left alert-error" style="width:100%;border:0px solid;">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Cancelled &amp; No show &amp; Postpone
        <div class="pull-right"><i class=""><%=cancelling.size%> Patients</i></div>
	    </div>
	    <div class="w-box-content cnt_a">
        <% providers.each_pair do |k,v| %>
        <span class="provider"><%= k %></span><br/>
            <%= tabular :model=>table_model+[:note],:data=>providers[k],:col_width=>{:pending_ctrl=>220},:labels=>labels do |row,out|
            if row[:status]=='Cancelled' and (row[:cancel_reason]==nil or row[:cancel_reason]=='')
            
            out[0] = "<span style='color:red'>\#{out[0]}</span>"    
            out[1] = "<span style='color:red'>\#{out[1]}</span>"  
            out[3] = "<span style='color:red'>\#{out[3]}</span>"  
            out[4] = "<span style='color:red'>\#{out[4]}</span>"  
            
            else
            
            out[-1] += "<span style='color:red'>\#{row[:cancel_reason]}</span>"  
            
            end
            
            
            if row[:status]=='Postpone'
                
            out[-1] += "<span style='color:red'>\#{row[:postpone_to]}</span>"  

                
            end


    
            out
            end
            %>
        <% end %>
    </div>
    </div>
</div>
<!--
<div class="left" style="width:50%">
   <div class="w-box" id="w_sort05">    
        <div class="w-box-header">
            Today Patients
	    <div class="pull-right"><i class=""></i></div>
	    </div>
	    <div class="w-box-content cnt_a">
	        content
        </div>
    </div>
</div>
-->


<br/>
<br/>

<hr/>
Links :
<!-- <%= link_to 'Print Appointment','print_appointment?print[date]='+params[:date],:target=>'_blank' %> | 
<%= link_to 'Print Report','print_report?print[date]='+params[:date],:target=>'_blank' %> | -->
<%= link_to 'Status Feed','status_feed?print[date]='+params[:date] %> |
<%= link_to 'Reset Locker','../Locker/reset' if @current_role=='admin' or @current_role=='developer' %>
<div class="clear"></div>
 </div><br/>
 
 
</div>
 <% end %>
 
HTML
return render_template(com,self,params,true)

        end
    

        def status_feed_partial *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<b>ประจำวันท่ี <%= Time.now.strftime("%d %B %Y") %> <%=Time.now.strftime("%H:%M:%S")%></b>
<div class="clear"></div>
<%
  npage = 9
  page = 0 
  page = params[:page].to_i if params[:page]
  
  
  

  @module_name = @current_project.name+'#appointment' 
  @ehr_project = @context.get_projects_by_abstract('ehr.ehr')[0]
#   @patient_doc = @ehr_project.get_document 'patient'
#   @module_doc = @ehr_project.get_document 'patient_module'
  @ehr_model = @ehr_project.get_model()
  @patient_model = @ehr_model[:patient]
  @module_model = @ehr_model[:patient_module]
  
  @models = get_model
  
#   if this.table_name!='appointment' and params[:parent_id] 
#   @appointment_module = @module_model.find(params[:parent_id])
#   if @appointment_module
#   @appointment = @models[:appointment].find(@appointment_module.module_id)
#   end
#   end 
  
#   if params[:id] and  @patient_module = @module_model.find(params[:id])
#      @patient = @patient_model.find(@patient_module.patient_id)
#   end

  params[:print] = {} unless params[:print]
  date = Time.now

  

  if params[:print]  # and params[:print][:date]
  
 
  
  params[:print][:date] = date.strftime("%d/%m/%Y") unless params[:print][:date]
  
  date = Date.to_mongo(params[:print][:date])
 
  appointments =   @models[:appointment].where(:date=>date).all
 
 
  records = {}
 patients = {}
#  providers = {}
#  indications= {}
#   visit_types= {}


 @module_model.where(:module_name=>@module_name, :module_id=>{'$in'=>appointments.collect{|i| i.id }}).all.each do |i|

  records[i.module_id]=i
 end
 
 appointments.collect!{|i| i if records[i.id]}.compact!
 
 @patient_model.fields({:first_name=>1,:last_name=>1,:hn=>1,:prefix_name=>1}).find(records.values.collect{|i| i.patient_id}).each do |i|
 patients[i.id]=i
 end

#  @models[:visit_type].all.each do |i|
#  visit_types[i.id.to_s] = i
#  end
 
#  @models[:provider].all.each do |i|
#  providers[i.id.to_s] = i
#  end
#  @models[:indication].all.each do |i|
#  indications[i.id.to_s] = i
#  end
 
#      pro = {}
#     @models[:procedure].all.each do |i|
#     pro[i.id] = i.name
#     end
    
    

    
json_data =   appointments.collect{|ap| 
 i  = records[ap.id]
 p = patients[i.patient_id]
#  provider = providers[ap.provider.to_s]
 l = %w{#bcdeee}
 age = '-'
 if p.birth_date
     diff = Time.diff(date, p.birth_date)
    year = diff[:year]
    month = diff[:month]
    day = diff[:day]
    age = "\#{year} ปี \#{month} เดือน \#{day} วัน"
 end
#  indication="-"
#  visit_type="-"
 
# indication = indications[ap.indication.to_s].name if indications[ap.indication.to_s]
#  visit_type = visit_types[ap.visit_type.to_s].name if visit_types[ap.visit_type.to_s]
 
 
if ap.status=='Preparing' or  ap.status=='Processing' or ap.status=='Recovering' or  (ap.status=='Completed' and ( Time.now - ap.updated_at ) < 300)
apdate = ''
apdate = ap.date.strftime("%Y-%m-%d") if ap.date
starttime = ''
stoptime = ''
starttime = ap.start.strftime(" %H:%M") if ap.start
stoptime = ap.stop.strftime(" %H:%M") if ap.stop
    {'id'=>ap.id,
    'status'=>ap.status ,
    'record'=>i.id,
    'hn'=> p.hn,
    'updated_at'=>ap.updated_at,
    # 'procedure'=>pro[ap.procedure],
    'date'=>apdate,
    'color'=>l[rand(4%l.size)],
    # 'provider'=>provider.name,
    'title'=>"\#{p.prefix_name if p } \#{p.first_name if p }",
    'start'=>apdate+starttime,
    'end'=>apdate+stoptime,
    # 'indication'=>indication,
    'allDay'=>false,
    'url'=>'edit?id='+i.id.to_s
    # 'age'=>age,
    # 'visit_type'=>visit_type,
    # 'tel'=>[p.tel_home,p.tel_office,p.mobile].collect{|i| i if i!=""}.compact.join(", "),
    # 'public_id'=>p.public_id
    }  
else
    nil
end 
}.compact

list = json_data.sort{|a,b| b['updated_at']<=>a['updated_at']}

total_page =  (list.size.to_f/npage).ceil
%>
<%#total_page%>
<%
if page>=total_page-1
topage = 0
else
topage = page +1
end

list = list[page*npage..(page+1)*npage-1]




 
%>
         

 <table width="100%" border="1" cellpadding="0" cellspacing="0" class="table">  
 
 <tr><th>No.</th>
 <th>H/N</th>
 <th>ชื่อ</th>
 <th>Status</th></tr>         
<% list.each_with_index do |i,index|  %>
 <tr >  
<td style="height:none"><value><%=index+1+page*npage%>.</value></td> <td><value><%=i['hn']%></value></td> <td><value><%=i['title']%>  </value></td> <td><value class="<%=i['status']%>"><%=i['status']%></value></td> 
 </tr>     
	
 <% end %>





</table></div>
</div>
</div>


	


<div class="clear">	</div>	
	


</div>

<div class="clear">	</div>	

</div>

</div>



<div class="clear"></div>
</div>
<!--
</div>
</div>-->
<div class="clear"></div>



<div id="clear">
</div>
</p>

</div>
</div>


   <!--                                 -->

<%
   
   link = "status_feed?page=\#{topage}"

%>
<script>
    setPage(<%=topage%>);
</script>
<!--
<script type="text/javascript">
  var timeout = setTimeout("location='<%=link%>'",10000);
  function resetTimeout() {
    clearTimeout(timeout);
    timeout = setTimeout("location='<%=link%>'",10000);
  }
</script>
-->
<% end %>



HTML
return render_template(com,self,params)

        end
    

        def patho_index *params
            @params = params[0] if params[0]
            ret = com=<<-HTML

<div class="row-fluid">
<div class="span8">
<div class="w-box">
    <div class="w-box-header">
       Dashboard
    </div>  
    <div class="w-box-content cnt_a">
<center><b>Welcome to <span style="color:#F3790D">EMR</span>-LIFE, <%= @current_project.title %> Module for Pathology Unit</b></center><br/>

</center>

<hr/>
<h3> New Requests</h3>

<%
    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    models = get_model
    patho_model = models[:pathology]
    
    name = "\#{@current_project.name}#pathology"
    
    list = module_model.where(:ref_number=>'new',:module_name=>name).all(:limit=>20,:order=>'created_at desc')
    list.collect!{|i|
        patient = patient_model.find i.patient_id
        patho = patho_model.find i.module_id
        {:id=>i.id,:patient_name=>"\#{patient.prefix_name}\#{patient.first_name} \#{patient.last_name}",:hn=>patient.hn,:patho=>patho,:date=>i.date.strftime("%d-%m-%Y") }if patient
    }.compact!


%>
<%= tabular :data=>list,:model=>[:hn,:patient_name,:date],:labels=>{} do |row,out|
  
  out << link_to('Entry' , "../Pathology/edit?id=\#{row[:id]}",:class=>'btn btn-info')

 out
end
%> 
<hr/>
<h3>Recently Update (3 days)</h3>
<%

  list = module_model.where(:updated_at=>{'$gte'=>Time.now-(24*3600*3)},:module_name=>name,:ref_number=>{'$ne'=>'new'}).all :limit=>10
    list.collect!{|i|
        patient = patient_model.find i.patient_id
        patho = patho_model.find i.module_id
        {:id=>i.id,:patient_name=>"\#{patient.prefix_name}\#{patient.first_name} \#{patient.last_name}",:hn=>patient.hn,:patho=>patho,:date=>i.date.strftime("%d-%m-%Y") }if patient
        
    }.compact!
     
%>
<%= tabular :data=>list,:model=>[:hn,:patient_name,:date],:labels=>{} do |row,out|
  
  out << link_to('Show' , "../Pathology/show?id=\#{row[:id]}",:class=>'btn')

 out
end
%> 

</div>

</div>

</div>

</div>

HTML
return render_template(com,self,params)

        end
    

        def search *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%

def get_hn i

  n = ''
  y = ''
  
  return i if i.size<5 or i.size>9
  if i.index '/'  
    t = i.split("/")
    y = t[-1]
    n = t[0]
  elsif i.index '-'  
    t = i.split("-")
    y = t[-1]
    n = t[0]
  elsif i.size==8
    y = i[0..1].to_i
    y2 = i[-2..-1].to_i
    n = i[3..-1].to_i  
    if y2 > y
      y = y2
      n = i[0..-3].to_i    
    end
  else
    y = i[-2..-1]
    n = i[0..-3]
  end
  
  hn = "\#{n.to_i.to_s}/\#{y}"

  return hn    

end

%>
<h1> Search Result </h1>
<hr/>
<% 
    models = get_model

    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    model = ehr.load_model
    patient_model = model[:patient]
    module_model = model[:patient_module]
    
    fields = %w{hn public_id first_name last_name}
    query = params[:query].strip
    
    
    
    hn_mode=false
    
    
    # if i = query.index('/')
    #     t = query.split('/')
    #     query = "\#{t[0].to_i}/\#{t[1].to_i}"
    #     hn_mode = true  
    # elsif query[0..-3].size>=4 and query.to_i !=0
    #     query = "\#{query[0..-3].to_i}/\#{query[-2..-1].to_i}"
    #     hn_mode = true  
    # end
    
    if query.index('/') or query.index('-') or query.to_i>0
        
       query = get_hn query    
       hn_mode = true
        
    end
        
        
        %>
        Query for 
        <%=query%>
        
        <%
    
    
    # if query.size == 8 and query.index('/')==nil
    #   query = "\#{query[0..-3].to_i}/\#{query[-2..-1].to_i}" 
    # elsif query.index('/')
    
    # end
    
    
    keys = []
    # fields.each do |f| 
    #     keys <<{f.to_sym=>Regexp.new(query)}
    # end
    keys << {:hn=>query}

    
    unless hn_mode
    
    keys << {:first_name=>Regexp.new(query)}
    keys << {:last_name=>Regexp.new(query)}
    keys << {:public_id=>query} if query.size==13
    
    end
    
    criteria = {'$or'=>keys}
    
    patients = patient_model.where(criteria).limit(100).all  
    
    app_name = "\#{@current_project.name}#appointment"
    app_model = models[:appointment]

    if patients.size==1
        row = patients[0]
        ams = module_model.where(:module_name=>"\#{app_name}",:patient_id=>row.id).all.collect{|i| i.module_id }
        app = app_model.where(:id=>{'$in'=>ams},:status=>{'$nin'=>['Cancelled','No show','Postpone']}).all :sort=>'date desc'
 
if app
  
#   app = app_model.where(:id=>am.module_id).first
  app = app[0]
  
  if @current_role!='pathologist'
  url = "../Home/patient_record?id=\#{app.id}"
  else
  url = "../Home/patho_patient_record?id=\#{app.id}"
  end

  if true
        
        %>
        <META HTTP-EQUIV="Refresh" CONTENT="0;URL=<%=url_for(url)%>">
        <%
        
    end
        
    end
   end
   
   xlist = [:first_name, :last_name]
   
   patients.sort!{|a,b| 
   
   ia = -1
   ia = 0 if a.first_name.index query
   ia = 1 if a.last_name.index query
   
  
   ib = -1
   ib = 0 if b.first_name.index query
   ib = 1 if b.last_name.index query
   
   if ia == ib
        
       a.created_at<=>b.created_at
   
   else
       
       ia<=>ib
       
   end
   
   
   }
   
   
   
   
%>
<%= tabular :model=>fields,:data=>patients,:n=>10 do |row,out|

  am = module_model.where(:module_name=>"\#{app_name}",:patient_id=>row.id).order('date').last
  ams = module_model.where(:module_name=>"\#{app_name}",:patient_id=>row.id).order('date')
  apps = app_model.where(:id=>{'$in'=>ams.collect{|i| i.module_id}} ,:status=>{'$nin'=>['Cancelled','No show','Postpone']}).all
  map = {}
  apps.each do |i|
    map[i.id] = i  
  end
  ams = ams.collect{|i| i if map[i.module_id] }.compact 

  
if am
  app = app_model.where(:id=>am.module_id).first
  
  if @current_role!='pathologist'
  url = "../Home/patient_record?id=\#{am.module_id}"
  else
  url = "../Home/patho_patient_record?id=\#{am.module_id}"
  end
  
  out[0] = link_to(row.hn,url)
  out[1] = link_to(row.public_id,url)
  out[2] = link_to(row.first_name,url)
  out[3] = link_to(row.last_name,url)
  n = module_model.where(:module_name=>"\#{app_name}",:patient_id=>row.id).count
  
  n = ams.size

  
  
  
out << link_to("Select (\#{n})", url)
else
out<<'-'
end

out
end

%>

<hr/>
<%# hn_mode.inspect %>
<%#@current_role %>
HTML
return render_template(com,self,params,true)

        end
    

        def patho_patient_record *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
patho
<% Time.zone =  get_setting 'time_zone' %>
<style>
body { min-width:0px; }
.gebo-fixed { background-color:#f5f5f5; }
#sidebar_bt {display:none }
</style>
<div class="row-fluid">
<div class="span12">
<div class="w-box">
    <div class="w-box-header">
        Patient Records
        <div class="pull-right">
        <%=link_to('<< Back','index',:class=>'btn btn-mini')%>
        </div> 
    </div>  
    <div class="w-box-content cnt_a">
    
<%

    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    ehr_models = ehr.get_model
    patient_model = ehr_models[:patient]
    patient_module_model = ehr_models[:patient_module]
    
    emr_models = get_model
    ap = emr_models[:appointment].find(params[:id])
    pm = patient_module_model.first(:module_id=>ap.id.to_s)
    locker_model = emr_models[:locker]
    if params[:reset_lock]
        l = locker_model.find(params[:reset_lock])
        l.destroy if l
    end
    #locker_model.where(:session=>session[:session_id]).all.each do |i|
    #i.destroy if i
    #end
     
    
    
    if pm
    
    if  params[:schema_patient_module]
       pm.update_attributes params[:schema_patient_module]
    end
    
    if params[:provider_id]
      ap.update_attributes :provider=>params[:provider_id]
       ap = emr_models[:appointment].find(params[:id])
     end
    
    # find provider
    provider = emr_models[:provider].find(ap.provider.to_s)
    
    # find patient
    patient = patient_model.find(pm.patient_id)
    
    params[:patient]=patient
    params[:patient_module]=pm
    
   # s = Service.get('ehr.emr.EmrHelper')
#    obj = s.load context
    
    providers = emr_models[:provider].where(:provider_type=>'1').all
    
%>

<% services =  @current_project.get_services_by_abstract('ehr.emr.Document').collect{|i| i if  i.name!='appointment'}.compact %>
<div style="border:0px solid">
<div class="document-border" style="border:0px solid; width:100%; padding:0px;max-width:688px">
<%# render :inline=>obj.show_patient %>
<div id="patient">
...
</div>
<script>
<%
        url = '../../www/Patient/search_result?'
        url += '&id='+patient.id.to_s
  %>      
        $.ajax({
    	  url: '<%=url%>',
		 success: function(data){
          $('#patient').html(data);  
		  }
		});
</script>
<br/>
<%


previous = patient_module_model.all(:patient_id=>patient.id,:id=>{"$ne" => pm.id},:module_name=>pm.module_name,:order=>'date desc')
history = []
x = previous[0..7]
last = []
last = x.compact if x
history = []
y = previous[8..-1]
history = y.compact if y and  previous.size>5
                                     
current = time_ago_in_words(ap.date)
current_date = ap.date.strftime("%d-%m-%y")
current = 'Today' if current_date == Time.now.strftime("%d-%m-%y")

%>



<div class="clear"></div>
<div class="tabbable">
    							<ul class="nav nav-tabs">
									<li class="active"><a href="#a<%=pm.id%>" data-toggle="tab"><%=current%><br/><%=current_date%></a></li>
                                    <%
                                    
                                    
                                     for i in last 
                                    %>
                                	<li><a href="#a<%=i.id%>" data-toggle="tab"><%=time_ago_in_words(i.date)%><br/><%=i.date.strftime("%d-%m-%y") if i.date%></a></li>
									<% end %>
                                    <% if history.size>5 %>
                                    <li class="dropdown">
										<a href="#" data-toggle="dropdown" class="dropdown-toggle">History<b class="caret"></b></a>
										<ul class="dropdown-menu">
                                            <% for j in history %>
											<li><a href="#a<%=j.id%>" data-toggle="tab"><%=j.date.strftime("%d-%m-%y") if j.date%> : <%=time_ago_in_words(j.date)%></a></li>
                                            <% end %>
											<li class="divider"></li>
										</ul>
									</li>
                                    <% end %>
								
                                </ul>



<div class="tab-content">
<div class="tab-pane active" id="a<%=pm.id%>">


<h4><%= @current_project.title %> Recrods</h4>
<hr/>
<table class="table table-striped table-bordered">
<thead>
<tr><th></th><th>Forms</th><th>Records</th><th></th></tr>
</thead>

<%
groups = this.config.collect{|i| i if i[:name]=='ETC' }.compact
if true
for g in groups 
   services = g[:actions].collect{|i| @current_project.get_service i[:service]}.collect{|i| i if i.acl=='pathologist' }.compact
%>
<tr><td colspan="4"><%=g[:name]%></td></tr>
<% services.each_with_index do |s,index|
    module_name = "\#{@current_project.name}#\#{s.name}"
    records = patient_module_model.all :module_name=>module_name, :parent_id=>pm.id,:patient_id=>pm.patient_id
%>
<tr><td><%= index+1 %>. </td><td> <%= s.title %></td>

<td align="center"><% for i in records %>
<%= link_to "\#{i.date.strftime("%d-%m-%Y") if i.date} \#{i.time.strftime("%H:%M") if i.time } - \#{i.ref_number}", "../\#{s.name.camelize}/show?id=\#{i.id}&return=\#{request.fullpath}" %>&nbsp;
<%= link_to "[ Edit ]", "../\#{s.name.camelize}/edit?id=\#{i.id}&record_name=\#{patient.hn}&return=\#{request.fullpath}" %>
<% end %>
</td>
<td>
<%  if records.size==0 %>
<%=link_to 'Create',"../\#{s.name.camelize}/create?patient_id=\#{patient.id}&record_name=\#{patient.hn}&parent_id=\#{pm.id}&return=\#{request.fullpath}" ,:class=>bt_class%>
<% else %>
<%=link_to 'Print',"../\#{s.name.camelize}/print?id=\#{i.id}&return=\#{request.fullpath}",:target=>'_blank' ,:class=>bt_class%>
<% end %>


<% 


    locker = locker_model.where(:module_id=>pm.id.to_s,:module_name=>s.name,:created_at=>{'$gt'=>1.hours.ago}).first
    if locker
    text = ''
    case locker.status
    when 'create'
        text='Creating..'
    when 'edit'
        text='Editing..'
    end
   user = @current_solution.get_user_by_id locker.session
   %>

<%
   text += " by " + user.login.split("@")[0]
#   text += locker.session
%>
<%=image_tag '/gebo/img/ajax_loader.gif',:width=>30,:height=>30,:style=>'vertical-align:middle'%>&nbsp;<span><%=text.html_safe  %><span>
    <% end %>


</td>
<% end %>
</tr>

<% end %>
<% end %>
</table>
</div>

<% for i in previous 
 pm = i
%>
<div class="tab-pane" id="a<%=i.id%>">
<h4><%= @current_project.title %> Recrods</h4>
<hr/>
<table class="table table-striped table-bordered">
<thead>
<tr><th></th><th>Forms</th><th>Records</th><th></th></tr>
</thead>

<%
groups = this.config
if true
for g in groups 
   services = g[:actions].collect{|i| @current_project.get_service i[:service]}.compact
%>
<tr><td colspan="4"><%=g[:name]%></td></tr>
<% services.each_with_index do |s,index|
    module_name = "\#{@current_project.name}#\#{s.name}"
    records = patient_module_model.all :module_name=>module_name, :parent_id=>pm.id,:patient_id=>pm.patient_id
%>
<tr><td><%= index+1 %>. </td><td> <%= s.title %></td>

<td align="center"><% for i in records %>
<%= link_to "\#{i.date.strftime("%d-%m-%Y") if i.date} \#{i.time.strftime("%H:%M") if i.time } - \#{i.ref_number}", "../\#{s.name.camelize}/show?id=\#{i.id}&return=\#{request.fullpath}" %>&nbsp;
<%= link_to "[ Edit ]", "../\#{s.name.camelize}/edit?id=\#{i.id}&record_name=\#{patient.hn}&return=\#{request.fullpath}" %>
<% end %>
</td>
<td>
<%  if records.size==0 %>
<%=link_to 'Create',"../\#{s.name.camelize}/create?patient_id=\#{patient.id}&record_name=\#{patient.hn}&parent_id=\#{pm.id}&return=\#{request.fullpath}" ,:class=>bt_class%>
<% else %>
<%=link_to 'Print',"../\#{s.name.camelize}/print?id=\#{i.id}&return=\#{request.fullpath}",:target=>'_blank' ,:class=>bt_class%>
<% end %>

<br/>

</td>
<% end %>
</tr>

<% end %>
<% end %>
</table>


</div>
<% end %>

</div>
</div>


</div>
</div>
<% else %>
Data missing
<% end %>
</div>
</div>
</div>
</div>

<script>
$('title').html('<%=patient.hn%> <%=patient.first_name%> <%=patient.last_name%>')
</script>


 
HTML
return render_template(com,self,params,true)

        end
    

        def patient_record *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<% Time.zone =  get_setting 'time_zone' %>

<style>
body { min-width:0px; }
.gebo-fixed { background-color:#f5f5f5; }
#sidebar_bt {display:none }
.active a{
    color:#000;
}
</style>
<div class="row-fluid">
<div class="span12">
<div class="w-box">
    <div class="w-box-header">
        Patient Records
        <div class="pull-right">
        <%=link_to('<< Back','index',:class=>'btn btn-mini')%>
        </div> 
    </div>  
    <div class="w-box-content cnt_a">
    
<%

    ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
    ehr_models = ehr.get_model
    patient_model = ehr_models[:patient]
    patient_module_model = ehr_models[:patient_module]
    
    emr_models = get_model
    ap = emr_models[:appointment].find(params[:id])
    
    unless ap.date   
    ap.date = Time.now
    ap.save
    end
    
    pm = patient_module_model.first(:module_id=>ap.id.to_s)
    locker_model = emr_models[:locker]
    if params[:reset_lock]
        l = locker_model.find(params[:reset_lock])
        l.destroy if l
    end
    #locker_model.where(:session=>session[:session_id]).all.each do |i|
    #i.destroy if i
    #end
     
    
    
    if pm
    
    if  params[:schema_patient_module]
       pm.update_attributes params[:schema_patient_module]
    end
    
    if params[:provider_id]
      ap.update_attributes :provider=>params[:provider_id]
       ap = emr_models[:appointment].find(params[:id])
     end
    
    # find provider
    provider = emr_models[:provider].find(ap.provider.to_s)
    
    # find patient
    patient = patient_model.find(pm.patient_id)
    
    params[:patient]=patient
    params[:patient_module]=pm
    
   # s = Service.get('ehr.emr.EmrHelper')
#    obj = s.load context
    
    providers = emr_models[:provider].where(:provider_type=>'1').all
    
%>
<% services =  @current_project.get_services_by_abstract('ehr.emr.Document').collect{|i| i if  i.name!='appointment'}.compact %>
<div style="border:0px solid">
<div class="document-border" style="border:0px solid; width:100%; padding:0px;max-width:688px">
<%# render :inline=>obj.show_patient %>
<div id="patient">
...
</div>
<script>
<%
        url = '../../www/Patient/search_result?'
        url += '&id='+patient.id.to_s
  %>      
        $.ajax({
    	  url: '<%=url.html_safe%>',
		 success: function(data){
          $('#patient').html(data);  
		  }
		});
</script>


<div id='prescope' >&nbsp;</div>
<br/>
<script>

<%

 url = "../PreScope/pre_scope_detail?parent_id=\#{pm.id}"
# url = "../PreScope/pre_scope_detail?parent_id=\#{params[:parent_id]}" if params[:parent_id]
 
%>

$.ajax({
  url: "<%=url.html_safe%>",
  context: document.body
}).done(function(data) { 
  $('#prescope').html(data);
 <% unless params[:id] %>
 $('#data-bowel_preparation').val(pre_scope["bowel_preparation"]);
 $('#data-additional_bowel_preparation').val(pre_scope["add_bowel_prep"]);

 $('#data-bowel_cc').val(pre_scope["bowelprep_cc"]);
 $('#data-bowel_other').val(pre_scope["bowel_other_note"]);
 $('#data-add_bowel_prep_cc').val(pre_scope["add_bowel_prep_cc"]);
 $('#data-add_bowel_prep_other').val(pre_scope["add_bowel_other"]);
 
 <% end %> 

});
</script>



<%

today = Time.now.strftime("%d-%m-%y")

#previous = patient_module_model.all(:patient_id=>patient.id,:id=>{"$ne" => pm.id},:module_name=>pm.module_name,:order=>'date desc')

previous = patient_module_model.all(:patient_id=>patient.id,:module_name=>pm.module_name,:order=>'date desc')
select_today = false
date_map = {ap.id=>ap.date}
previous_map = {}
apps = emr_models[:appointment].where(:id=>{'$in'=>previous.collect{|i| i.module_id}},:status=>{'$nin'=>['Postpone','Cancelled','No show']}).all
for i in apps
    previous_map[i.id] = i
    date_map[i.id] = i.date
    if i.date and  i.date.strftime("%d-%m-%y") == today
      select_today = true  
    end
end

unless select_today
  today = date_map[previous[0].module_id].strftime("%d-%m-%y") if date_map[previous[0].module_id]
end


history = []
x = previous[0..7]
last = []
last = x.compact if x
history = []
y = previous[8..-1]
history = y.compact if y and  previous.size>5
                                    
ap.date = Time.now unless ap.date

current = time_ago_in_words(ap.date)
current_date = ap.date.strftime("%d-%m-%y") if ap and ap.date

current = 'Today' if current_date == today

%>
<div class="clear"></div>
<div class="tabbable">
    							<ul class="nav nav-tabs">
									<% if false %>
									<li class="<%='active' if current=='Today'%>"><a href="#a<%=pm.id%>" data-toggle="tab"><%=current%><br/><%=current_date%><br/><%=ap.status%></a></li>
                                    <% end %>
                                    <%

                                     for i in last 
                                     d = date_map[i.module_id]
                                     if d
                                    %>
                                	<li class="<%='active' if d and d.strftime("%d-%m-%y")==today %>"><a href="#a<%=i.id%>" data-toggle="tab"><%=time_ago_in_words(d)%><br/><%=d.strftime("%d-%m-%y") if d and i.date%><br/><%=previous_map[i.module_id].status%></a></li>
									<% end %>
									<% end %>
									
                                    <% if history.size>5 %>
                                    <li class="dropdown">
										<a href="#" data-toggle="dropdown" class="dropdown-toggle">History<b class="caret"></b></a>
										<ul class="dropdown-menu">
                                            <% for j in history %>
											<li><a href="#a<%=j.id%>" data-toggle="tab"><%=j.date.strftime("%d-%m-%y") if j.date%> : <%=time_ago_in_words(j.date)%></a></li>
                                            <% end %>
											<li class="divider"></li>
										</ul>
									</li>
                                    <% end %>
								
                                </ul>



<div class="tab-content">
<% if false %>
<div class="tab-pane <%='active' if current=='Today' or previous.size==0 %>" id="a<%=pm.id%>">
<%#previous.size%>

<h4><%= @current_project.title %> Recrods for <%=current_date %> #one</h4>
<hr/>
<table class="table table-striped table-bordered">
<thead>
<tr><th></th><th>Forms</th><th>Records</th><th></th></tr>
</thead>

<%
groups = this.config
if true
for g in groups 
   services = g[:actions].collect{|i| @current_project.get_service i[:service]}.compact
%>
<tr><td colspan="4"><%=g[:name]%></td></tr>
<% services.each_with_index do |s,index|
    module_name = "\#{@current_project.name}#\#{s.name}"
    records = patient_module_model.all :module_name=>module_name, :parent_id=>pm.id,:patient_id=>pm.patient_id
%>
<tr><td><%= index+1 %>. </td><td> <%= s.title %></td>

<td align="center"><% for i in records %>
<%= link_to "\#{i.date.strftime("%d-%m-%Y") if i.date} \#{i.time.strftime("%H:%M") if i.time } - \#{i.ref_number}", "../\#{s.name.camelize}/show?id=\#{i.id}&return=\#{request.fullpath}" %>&nbsp;
<%= link_to "[ Edit ]", "../\#{s.name.camelize}/edit?id=\#{i.id}&record_name=\#{patient.hn}|\#{patient.first_name} \#{patient.last_name}&return=\#{request.fullpath}" %>
<% end %>
</td>
<td>
<%  if records.size==0 %>
<%=link_to 'Create',"../\#{s.name.camelize}/create?patient_id=\#{patient.id}&record_name=\#{patient.hn}|\#{patient.first_name} \#{patient.last_name}&parent_id=\#{pm.id}&return=\#{request.fullpath}" ,:class=>bt_class%>
<% else %>
<%=link_to 'Print',"../\#{s.name.camelize}/print?id=\#{i.id}&return=\#{request.fullpath}",:target=>'_blank' ,:class=>bt_class%>
<% end %>


<% 
    # locker = locker_model.where(:module_id=>pm.id.to_s,:module_name=>s.name,:created_at=>{'$gt'=>1.hours.ago}).first
    locker = locker_model.where(:module_id=>pm.id.to_s,:module_name=>s.name,:created_at=>{'$lt'=>1.minutes.ago}).first



    if locker
    text = ''
    case locker.status
    when 'create'
        text='Creating..'
    when 'edit'
        text='Editing..'
    end
   user,role,solution_user = @current_solution.get_user_role_by_id locker.session
   
   user_name = user.login.split("@")[0]
   user_name =  solution_user.name  if solution_user

   text += " by " + user_name
#   text += locker.session
%>
<%=image_tag '/gebo/img/ajax_loader.gif',:width=>30,:height=>30,:style=>'vertical-align:middle'%>&nbsp;<span><%=text.html_safe  %><span>

<% end %>


</td>
<% end %>
</tr>

<% end %>
<% end %>
</table>
</div>
<% end %>
<% for i in previous 
 pm = i
 d = date_map[i.module_id] 
 if d
%>
<div class="tab-pane <%='active' if d and  d.strftime("%d-%m-%y")==today%>" id="a<%=i.id%>">
<%= d.strftime("%d-%m-%y") if d%>
<h4><%= @current_project.title %> Recrods for <%=d.strftime("%d-%m-%y")%></h4>
<hr/>
<table class="table table-striped table-bordered">
<thead>
<tr><th></th><th>Forms</th><th>Records</th><th></th></tr>
</thead>

<%
groups = this.config
if true
for g in groups 
   services = g[:actions].collect{|i| @current_project.get_service i[:service]}.compact
%>
<tr><td colspan="4"><%=g[:name]%></td></tr>
<% services.each_with_index do |s,index|
    module_name = "\#{@current_project.name}#\#{s.name}"
    records = patient_module_model.all :module_name=>module_name, :parent_id=>pm.id,:patient_id=>pm.patient_id
%>
<tr><td><%= index+1 %>. </td><td> <%= s.title %></td>

<td align="center"><% for i in records %>
<%= link_to "\#{i.date.strftime("%d-%m-%Y") if i.date} \#{i.time.strftime("%H:%M") if i.time } - \#{i.ref_number}", "../\#{s.name.camelize}/show?id=\#{i.id}&return=\#{request.fullpath}" %>&nbsp;
<%= link_to "Edit", "../\#{s.name.camelize}/edit?id=\#{i.id}&record_name=\#{patient.hn}&ref_2=\#{patient.first_name} \#{patient.last_name}&return=\#{request.fullpath}",:class=>'btn btn-info' if  @current_role=='admin' or @current_role=='superadmin'  or @current_role=='developer' or (i.date and (Time.now - i.updated_at).to_i < 3600*24 ) or s.name=='pre_scope' %>
&nbsp;<%= link_to "Del", "../\#{s.name.camelize}/destroy?id=\#{i.id}&record_name=\#{patient.hn}&return=\#{request.fullpath}" ,:data=>{:confirm=>'Are you sure?'},:class=>'btn btn-danger' if @current_role=='admin' or  @current_role=='superadmin' or @current_role=='developer' %>


<% end %>
</td>
<td>
<%  if records.size==0 %>
<%=link_to 'Create',"../\#{s.name.camelize}/create?patient_id=\#{patient.id}&record_name=\#{patient.hn}&ref_2=\#{patient.first_name} \#{patient.last_name}&parent_id=\#{pm.id}&return=\#{request.fullpath}" ,:class=>'btn'%>
<% else %>
<%=link_to 'Print',"../\#{s.name.camelize}/print?id=\#{i.id}&return=\#{request.fullpath}",:target=>'_blank' ,:class=>'btn'%>

<% end %>

<% 
    locker = locker_model.where(:module_id=>pm.id.to_s,:module_name=>s.name,:created_at=>{'$gt'=>Time.now-3600}).first


   text = ''
   if locker
    case locker.status
    when 'create'
        text='Creating..'
    when 'edit'
        text='Editing..'
    end
    
   user,role,solution_user = @current_solution.get_user_role_by_id locker.session
   
#   user_name =  @current_user.login.split("@")[0]
#   user_name =  solution_user.name  if solution_user
   
   
   user_name =  user.login.split("@")[0]
   user_name =  solution_user.name  if solution_user

   text += " by " + user_name
   
   text = "<span>\#{text}</span>&nbsp;"+ image_tag('/gebo/img/ajax_loader.gif',:width=>30,:height=>30,:style=>'vertical-align:middle')
   
   end

%>

<%= text.html_safe %> 


</td>
<% end %>
</tr>

<% end %>
<% end %>
</table>


</div>
<% end %>

<% end %>
</div>
</div>


</div>
</div>
<% else %>
Data missing
<% end %>
</div>
</div>
</div>
</div>

<script>
$('title').html('<%=patient.hn%> <%=patient.first_name%> <%=patient.last_name%>')
</script>


 
HTML
return render_template(com,self,params,true)

        end
    

        def print_appointment *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
  @module_name = @current_project.name+'#appointment' 
  @ehr_project = @context.get_projects_by_abstract('ehr.ehr')[0]
  @patient_doc = @ehr_project.get_document 'patient'
  @module_doc = @ehr_project.get_document 'patient_module'
  @ehr_model = @ehr_project.get_model()
  @patient_model = @ehr_model[:patient]
  @module_model = @ehr_model[:patient_module]
  
  @models = get_model
  
  if this.table_name!='appointment' and params[:parent_id] 
  @appointment_module = @module_model.find(params[:parent_id])
  if @appointment_module
  @appointment = @models[:appointment].find(@appointment_module.module_id)
  end
  end 
  
  if params[:id] and  @patient_module = @module_model.find(params[:id])
     @patient = @patient_model.find(@patient_module.patient_id)
  end

  if params[:print] and params[:print][:date]
  
  date = Date.to_mongo(params[:print][:date])
 
  appointments =   @models[:appointment].where(:date=>date).all
 
 
  records = {}
 patients = {}
 providers = {}
 indications= {}
  visit_types= {}


 @module_model.where(:module_name=>@module_name, :module_id=>{'$in'=>appointments.collect{|i| i.id }}).all.each do |i|

  records[i.module_id]=i
 end

 appointments = appointments.collect{|i| i if records[i.id] }.compact

 
 @patient_model.find(records.values.collect{|i| i.patient_id}).each do |i|
 patients[i.id]=i
 end

 @models[:visit_type].all.each do |i|
 visit_types[i.id.to_s] = i
 end
 
 @models[:provider].all.each do |i|
 providers[i.id.to_s] = i
 end
 @models[:indication].all.each do |i|
 indications[i.id.to_s] = i
 end
 
     pro = {}
    @models[:procedure].all.each do |i|
    pro[i.id] = i.name
    end
    
    

    
json_data =   appointments.collect{|ap| 
 i  = records[ap.id]
 p = patients[i.patient_id]
 provider = providers[ap.provider.to_s]
 l = %w{#bcdeee}
 age = '-'
 if p.birth_date
     diff = Time.diff(date, p.birth_date)
    year = diff[:year]
    month = diff[:month]
    day = diff[:day]
    age = "\#{year} ปี \#{month} เดือน \#{day} วัน"
 end
 indication="-"
 visit_type="-"
 
indication = indications[ap.indication.to_s].name if indications[ap.indication.to_s]
 visit_type = visit_types[ap.visit_type.to_s].name if visit_types[ap.visit_type.to_s]
 
 d = "-"
 d = ap.date.strftime("%Y-%m-%d") if ap.date
 
if ap.status!='Postpone' and ap.status!='Cancelled'
    {'id'=>ap.id,
    'status'=>ap.status,
    'record'=>i.id,
    'hn'=> p.hn,
    'procedure'=>pro[ap.procedure],
    'date'=>d,
    'color'=>l[rand(4%l.size)],
    'provider'=>provider.name,
    'title'=>"\#{p.prefix_name if p } \#{p.first_name if p } \#{p.last_name if p }",
    'start'=>d+"\#{ap.start.strftime(" %H:%M") if ap.start}",
    'end'=>d+"\#{ap.stop.strftime(" %H:%M") if ap.stop}",
    'indication'=>indication,
    'allDay'=>false,
    'url'=>'edit?id='+i.id.to_s,
    'age'=>age,
    'visit_type'=>visit_type,
    'tel'=>[p.tel_home,p.tel_office,p.mobile].collect{|i| i if i!=""}.compact.join(", "),
    'public_id'=>p.public_id
    }  
else
    nil
end 
}.compact

list = json_data.sort{|a,b| a['visit_type']<=>b['visit_type']}
 
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>PRINT</title>
</head>
<style type="text/css" media="print,screen">
html { }
value {color:#06F}
imvalue { color:#F00; font-weight:bold}
imvalue value { color:#F00; font-weight:bold}
#page {border:solid 1px; width:910px; border-color:#666;
-webkit-border-radius: 5px; /* Safari prototype */
-moz-border-radius: 5px; /* Gecko browsers */
border-radius: 5px; /* Everything else - limited support at the moment */
margin-bottom:5px; padding-bottom:5px; padding-left:20px;padding-right:20px; }
#head { width:100%; height:60px;}
#logoleft { margin-left:20px; float:left;}
#logoright{ margin-right:20px; float:right;}
th              { font-weight: bolder; text-align: center }
caption         { text-align: center }
body            {   font-family: Arial, Helvetica, sans-serif; color:#000;background:none;font-size:12pt;}
.wrapper{ width:960px;margin-left:auto;margin-right:auto} 
hr    {clear: both;border: none;border-top: 1px solid #AAA;border-bottom: 1px solid #FFF; font-size: 1px;line-height: 0;overflow: visible; width:98%;}
h1              { font-size: 2em; margin: .67em 0 }
h2              { font-size: 1.5em; margin: .83em 0 }
h3              { font-size: 1.17em; margin: 1em 0 }
p {color:#666;}
h4, p,
blockquote, ul,
form,
ol, dl          { margin: 0.5em; }
h5              { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }
h6              { font-size: .67em; margin: 2.33em 0 }

h4 { font-size:14pt; color:#333; height:16px;}
blockquote      { margin-left: 40px; margin-right: 40px }
i, cite, em,
var, address    { font-style: italic }
pre, tt, code,
kbd, samp       {  font-size:14px; }
pre             {margin:0;margin-left:1em; color:#666}
big             { font-size: 1.17em }
v {color:#2561cD;}
small, sub, sup { font-size: .83em }
ol, ul, dd      { margin-left: 40px }
ol              { list-style-type: decimal }
ol ul, ul ol,
ul ul, ol ol    { margin-top: 0; margin-bottom: 0 }
.clear{clear:both;}
@media print {
  @page         { width:960px; margin-top:0; }
  blockquote, 
 .wrapper{ width:960px;margin-left:55px;margin-right:auto} 
  table { page-break-after:auto; -fs-table-paginate: paginate; }
  tr    { page-break-inside:avoid; page-break-after:auto }
  td    { page-break-inside:avoid; page-break-after:auto }
  thead { display:table-header-group;     margin-top:10px;}
  tfoot { display:table-footer-group }

}

#box{
    width:150px;
    float:left;
    padding:10px;
    text-align:center;
    border:1px solid #ccc;
    -webkit-border-radius: 5px; /* Safari prototype */
    -moz-border-radius: 5px; /* Gecko browsers */
    border-radius: 5px; /* Everything else - limited support at the moment */    
    margin:10px;
}
.smm { font-size:0.5em; border:1px solid;border-color:#ccc;}
#box img{
        width:150px;
}
label{
    color:#666; font-weight:bold;
}

#table-3 {
    border: 1px solid #DFDFDF;
    background-color: #F9F9F9;
    width: 100%;
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
	font-family: Arial,"Bitstream Vera Sans",Helvetica,Verdana,sans-serif;
	color: #333;
}
#table-3 td, #table-3 th {
	border-top-color: white;
	border-bottom: 1px solid #DFDFDF;
	color: #555;
}
#table-3 th {
	text-shadow: rgba(255, 255, 255, 0.796875) 0px 1px 0px;
	font-family: Georgia,"Times New Roman","Bitstream Charter",Times,serif;
	font-weight: normal;
	padding: 7px 7px 8px;
	text-align: left;
	line-height: 1.3em;
	font-size: 16px;

}
#table-3 td {
	font-size: 16px;
	padding: 2px 2px 2px;
	vertical-align: top;
	background:#FFF;
}
thead {
    display:table-header-group;

}
tbody {
    display:table-row-group;
}
</style>
<body>

<div class="wrapper" >
<div id="head">
<div id="logoleft"><img src='/esm/cusys/colorectal/login-logo.png' width="300" /></div>
<div id="logoright">
<p>Reported by :&nbsp;<%= @current_user.login.humanize %></p>
<p>Printed at :&nbsp;<%= Time.now %></p>
</div>
</div>

<div id="page">

<div class="row-fluid">
<div class="span12">

<div class="w-box">
<br />
<b>ตารางแสดงรายการผู้ป่วย
<span style="float:right">ประจำวันที่ 
<%= date.strftime("%d %B %Y")%></b>
</span>
<br /><br />



<table width="100%" border="1" cellspacing="0" cellpadding="0" id="table-3" style="font-size:2em">
  <thead>
  <tr>
    <th>No.</th>
    <th>Type</th>
    <th style="width:150px">ชื่อ - สกุล</th>
    <th>HN</th>
    <th >อายุ</th>
    <th>เลขประชาชน</th>
    <th>Indic.</th>
    <th>Procedure</th>
    <th>Provider</th>
    <th>Tel.</th>
  </tr>
  </thead>
  <tbody>
  <%
  
  n = 10
  
  
  %>
  
  
  
  <% list[0..n-1].each_with_index do |i,index|  %>
    <tr style="height:110px">
    <td><%=index+1%>.</td>
    <td><%=i['visit_type']%></td>
    <td style="width:200px"><%=i['title']%></td>
    <td><%=i['hn']%></td>
    <td><%=i['age']%></td>
    <td><%=i['public_id']%></td>
    <td><%=i['indication']%></td>
    <td ><%=i['procedure']%></td>
    <td><%=i['provider']%></td>
    <td><%=i['tel']%></td>
    </tr>
    <% end %>
    
    <%  if list.size>n %>
    
    </tbody>
  </table>
</div>

  
<div style="page-break-after: always">
<br/><br/>  
</div>
    <table width="100%" border="1" cellspacing="0" cellpadding="0" id="table-3" style="font-size:2em">
  <thead>
  <tr>
    <th>No.</th>
    <th>Type</th>
    <th style="width:150px">ชื่อ - สกุล</th>
    <th>HN</th>
    <th>อายุ</th>
    <th>เลขประชาชน</th>
    <th>Indic.</th>
    <th>Procedure</th>
    <th>Provider</th>
    <th>Tel.</th>
  </tr>
  </thead>
  <tbody>
  
    <% list[n..-1].each_with_index do |i,index|  %>
    <tr style="height:110px">
    <td><%=index+1+n%>.</td>
    <td><%=i['visit_type']%></td>
    <td style="width:200px"><%=i['title']%></td>
    <td><%=i['hn']%></td>
    <td><%=i['age']%></td>
    <td><%=i['public_id']%></td>
    <td><%=i['indication']%></td>
    <td><%=i['procedure']%></td>
    <td><%=i['provider']%></td>
    <td><%=i['tel']%></td>
    </tr>
    <% end %>
    
    
     <% end %>
    
    
</tbody>
  </table>
  
  <br/>
  </div>
  </div></div></div></div></div>
</body>
</html>
<% end %>


HTML
return render_template(com,self,params)

        end
    

        def context_menu *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%

     id = params[:id]
%>
<div id="context-menu-panel">
</div>
<script>
         $.ajax({
    	  url: '../Home/context_menu_partial?<%='id='+id if id%>',
		 success: function(data){
          $('#context-menu-panel').html(data);  
		  }
		});
</script>
HTML
return com

        end
    

        def context_menu_partial *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<style>
    .list-x{width:100px;border:0px solid;display:inline-block;}
</style>
<% 
if @current_role != 'pathologist'
modules = @context.get_projects_by_abstract 'ehr.emr' 
model = get_model
ehr = @context.get_projects_by_abstract('ehr.ehr')[0]
ehr_models = ehr.load_model
patient_model = ehr_models[:patient]
m = modules.collect{|i| {:name=>i.title,:link=>"../../\#{i.name}/Home/index",:remote=>false} }
m <<  {:name=>'Back to EHR',:link=>"../../www/Home/index",:remote=>false}
%>
<%# show_menu m %>
<%

if params[:id] and params[:id]!=""

pm_model = ehr_models[:patient_module]
if params[:mode]=='module' 
    
    lpm = pm_model.find(params[:id])

    apm = pm_model.find(lpm.parent_id)
    if lpm and apm
    ap = model[:appointment].find(apm.module_id)
    else
    apm = pm_model.find(params[:id])
    ap = model[:appointment].find(apm.module_id)

  
end
    
else
    ap = model[:appointment].find(params[:id]) 
    apm = pm_model.where(:module_id=>ap.id).first
    
end
patient = nil
if apm
   patient = patient_model.find(apm.patient_id) 
end

# if params[:id] or params[:parent_id]
    
obj = this.config

list = []

for i in obj
for j in i[:actions]
  if j[:dashboard]==true
    list << j
  end
end
end


# 


# if params[:parent_id]
# elsif params[:service]=='Home'
#     ap = model[:appointment].find(params[:id]) 
# else
#     lpm = pm_model.find(params[:id])
#     apm = pm_model.find(lpm.parent_id)
#     ap = model[:appointment].find(apm.module_id)
# end

# obj = [
# {:name=>'Endoscopy',:open=>true,:actions=>[
# {:name=>'Consignment',:service=>'consignment',:link=>'../Consignment/index',:remote=>false},
# {:name=>'Pre Scope',:service=>'pre_scope',:link=>'../PreScope/index',:remote=>false},
# {:name=>'Intra Scope',:service=>'intra_scope',:link=>'../IntraScope/index',:remote=>false},
# {:name=>'Post Scope',:service=>'post_scope',:link=>'../PostScope/index',:remote=>false}]},
# {:name=>'Endoscopist Records',:open=>true,:actions=>[
# {:name=>'Colonosopy',:service=>'colonoscopy',:link=>'../Colonoscopy/index',:remote=>false},
# {:name=>'Gastroscopy',:service=>'gastroscopy',:link=>'../Gastroscopy/index',:remote=>false}]},
# {:name=>'ETC',:open=>true,:actions=>[
# {:name=>'Pathology',:service=>'pathology',:link=>'../Pathology/index',:remote=>false},
# {:name=>'Analyses',:service=>'report',:link=>'../Report/index',:remote=>false}]}]
%>
<%# params[:id] %>
<%#list.inspect  %>


<div class="accordion-group" style="">
	<div class="accordion-heading">
		<a href="#collapse-0" data-parent="#side_accordion" data-toggle="collapse" class="accordion-toggle">
		Visit Detail
		</a>
		</div>
		<div class="accordion-body collapse in" id="collapse-0">
			<div class="accordion-inner">
			<div class="alert alert-info">
			
<b>Name : </b><%= patient.first_name %> <%= patient.last_name %> <br/>
<b>HN : </b><%= patient.hn %> <br/>

			
<b>Visit Type : </b><%=t = model[:visit_type].find(ap.visit_type); t.name if t %> <br/>
<b>Visit Date : </b><font style="color:red"><%= ap.date.strftime("%d-%m-%Y")  if ap%></font><br/>

<span id="patient-other-detail">
<%

   pre_scope_model = model[:pre_scope]
   if pre_scope_model
   pm = pm_model.where(:parent_id=>apm.id,:module_name=>"\#{@current_project.name}#pre_scope").first
   if pm 
    
      pre_scope_record = pre_scope_model.find(pm.module_id)
     %>
     <b>สิทธิผู้ป่วย : </b>
     <%=pre_scope_record.finance%><br/>
     <% if pre_scope_record.on_anticoaglant_anti_platelet and pre_scope_record.on_anticoaglant_anti_platelet!='No' %>
    <font style="color:red">  <b>Anticoaglant : </b>
    <b ><%=pre_scope_record.on_anticoaglant_anti_platelet%></br></font>
     <% end %>
     <%
     if pre_scope_record.previous_illness and pre_scope_record.previous_illness.index("HIV") or pre_scope_record.previous_illness.index("Hepatitis")
      %>
      <font style="color:red"><b >Note : <%=pre_scope_record.previous_illness.split("|").collect{|x| x if x.index('HIV') or x=='Hepatitis' }.compact.join(",") %></b></font>
      <%
  end
   else
       %>
       no prescope
       <%
   end
   
   end
   

%>
    
    
</span>    


    
</div>


<% for i in list %>
<div style="padding-bottom:5px;padding-top:5px;border-bottom:1px solid #ccc">
<span class="list-x"><%=i[:name]%> : </span>
<%
   ilist = []
#   apm
   pm = pm_model.where(:parent_id=>apm.id,:module_name=>"\#{@current_project.name}#\#{i[:service]}").first
   return_url = "../Home/patient_record?id=\#{ap.id}"
      patient_hn = patient.hn
      patient_id = apm.patient_id
   if pm
      ilist << link_to("Edit","\#{i[:link].split('/')[0..-2].join('/')}/edit?id=\#{pm.id}&record_name=\#{patient_hn}&ref_2=\#{patient.first_name} \#{patient.last_name}&return=\#{return_url}",:class=>'btn')
      ilist << link_to("Print","\#{i[:link].split('/')[0..-2].join('/')}/print?id=\#{pm.id}",:class=>'btn ',:target=>'_blank')
   else
      ilist << link_to("Create","\#{i[:link].split('/')[0..-2].join('/')}/create?patient_id=\#{patient_id}&record_name=\#{patient_hn}&ref_2=\#{patient.first_name} \#{patient.last_name}&parent_id=\#{apm.id}&return=\#{return_url}",:class=>'btn')
   end



 for j in ilist 
%>
<%=j.html_safe%>
<% end %>
</div>

<% end %>
<div><br/>
<center><%=link_to 'Back to Detail', return_url, :class=>'btn' %></center>

</div>
</div>

</div>

</div>

<% else %>

<%=show_menu this.config  if  %w{admin superadmin developer}.index @current_role%>
<% end %>

<%    

# obj << {:name=>'Links',:open=>true,:actions=>m}
%>
<% services =  @current_project.get_services_by_abstract('ehr.emr.Document') %>

<% else %>
<center style="margin-top:20px"><%= link_to 'Pathology Records','../Pathology/index',:class=>'btn' %></center>
<% end %>



HTML
return render_template(com,self,params)

        end
    

        def print_weekly *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
<style>
    table, th, td {
   border: 1pt solid black;
   border-collapse: collapse; 
    font-size:12x;
}
    
</style>
<style type="text/css" media="print">
@media print{@page {size: landscape}}
    .page
    {
        
     -webkit-transform: rotate(-90deg); 
     -moz-transform:rotate(-90deg);
     filter:progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
	
    }
    body {margin-top: 3px;padding-top: 3px;}
</style>
</head>

<body style="margin-top: 3px;padding-top: 3px;">

<div id="page" style="font-size:12px">
<span style="position:fixed;">แบบ ย.ส.6</span>
<center>รายงานประจำเดือน <% %>


<br />
ชื่อผู้รับใบอนุญาต
<% %>
สถานที่ชื่อ 
<% %>
<br />
อยู่เลขที่ 
<% %>
<br /></center>
<table width="100%" border="1" cellspacing="0" cellpadding="0" style="font-size:12px;">
  <tr>
    <td rowspan="2" align="center">วัน เดือน ปี</td>
    <td rowspan="2" align="center">ชื่อยาเสพติดให้โทษในประเภทที่ 2 </td>
    <td rowspan="2" align="center">รหัส</td>
    <td rowspan="2" align="center">ได้มาจาก<br />
      กระทรวงสาธารณะสุข</td>
    <td rowspan="2" align="center">จ่ายไป</td>
    <td colspan="3" align="center">(ปริมาณ กรัม หรือ ช.ม.)</td>
    <td rowspan="2" align="center">หมายเหตุ</td>
  </tr>
  <tr>
    <td align="center">รับ</td>
    <td align="center">จ่าย</td>
    <td align="center">คงเหลือ</td>
    </tr>
  <tr>
    <td align="center">1 / 1 / 59</td>
    <td>&nbsp;Fentany 0.1 mg</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;นาย กฤษฎา วงษ์จินเพื่อง</td>
    <td align="center" width="100">&nbsp;</td>
    <td align="center" width="100">1 Amps.</td>
    <td align="center" width="100">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<br />
หมายเหตุ ให้ขีดฆ่าข้อความที่ไม่ต้องการออก คำอธิบาย 1.ช่องรหัส ให้ดูรหัสจากฉลากติดกับภาชนะบรรจุ 2.ช่องจ่ายไป ให้ระบุชื่อคนไข้ เพศ อายุ อาชีพ และที่อยู่ให้ชัดเจน 3.รายงานนี้ให้ส่งถึงเลขาธิการคณะกรรมการอาหารและยา ภายใน สามสินวันนับแต่วันสิ้นเดือน 4.แบบฟอร์มนี้ขอให้ที่กองคอบคุมวัตถุเสพติด สำนักงานคณะกรรมการอาหารและยา กระทรวงสาธารณสุข<br />
<span style="float:right">(ลายมือชื่อ).................................................(ผู้รับอนุมัติ)</span></div>
</body>
</html>

HTML
return render_template(com,self,params)

        end
    

        def paid *params
            @params = params[0] if params[0]
            ret = com=<<-HTML
<%
    billing = get_model('billing').find params[:id]
    
    billing.update_attributes :paid=>'true'
    
%>
<script>
    window.location="index";
</script>
HTML
return render_template(com,self,params)

        end
    

end