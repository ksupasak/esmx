class EsmAttachmentsController < EsmController
  
  protect_from_forgery :except => [:upload]
  
  before_action :context_filter, :except=>[:show]
  
  
  def show
    package = params[:package].split('/')
    # package = [params[:solution_name],params[:project_name]] + params[:package].split('/')
    # package = "#{params[:solution_name]}/#{params[:project_name]}/#{package}"
    # puts "xxxx#{package}"
    esm = Esm.find_by_name package[0]
    project = esm.projects.find_by_name package[1]
    model = project.attachment_model
    att =  model.find params[:id] 
    
    
    
    # grid = Mongo::Grid.new(MongoMapper.database)
    
     Mongoid.override_database(esm.db_name)
       
      # connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override
       
      # pool = Mongoid.default_client.cluster.next_primary.pool
      #
      # connection = pool.check_out
      #
      
      database =  Mongo::Database.new Mongoid.default_client, esm.db_name
      
      grid = Mongo::Grid::FSBucket.new(database)
          
      # grid = Mongo::Grid::FSBucket.new(connection.database)
    
    
    # file = grid.get(BSON::ObjectId.from_string(att.file_id))
    # puts att.file_id.class
    
    
    file = nil
    content = nil
    content_type =nil
    
    if params[:thumb] 
      
      
      # if att.thumb_id == nil or (file = grid.get(att.thumb_id) )== nil or params[:thumb]=='2'
    
      if  att.thumb_id == nil or params[:thumb]!= '1' or (file = grid.open_download_stream(att.thumb_id) )== nil 
           ofile = grid.open_download_stream(att.file_id)
           content_type = ofile.file_info.content_type
           info = ofile.file_info 
           ext = info.filename.split(".")[-1]
           ext = 'jpg'
           filename= info.filename
           fname = "tmp/cache/#{att.file_id}.#{ext}"
           rname = "tmp/cache/#{att.file_id}_thumb.#{ext}"
           f = File.open(fname,'w')
           f.write ofile.read.force_encoding('utf-8') 
           f.close
           size = '128x128'
           size = '256x256' if params[:thumb]=='2'
           size = '1280x720' if params[:thumb]=='hd'
           
           puts `convert -resize #{size} #{fname} #{rname}`
           file = File.open(rname,'r')
           
           # id = grid.put(content,:filename=>filename)
          
          if att.thumb_id == nil and params[:thumb] == 1
            
           id = grid.upload_from_stream(filename,file)
            file.close
              File.delete fname
               File.delete rname
          
           att.update_attributes :thumb_id=>id
         
           file = grid.open_download_stream(id)
           content = file.read
           content_type = file.file_info.content_type
           
         else
           
           # id = grid.upload_from_stream(filename,file)
          
          
           # puts "new id #{id}"
         #  att.update_attributes :thumb_id=>id
         
          # file = grid.open_download_stream(id)
           content = file.read
             file.close
             File.delete fname
              File.delete rname
           
           
           
         end
     else
       
       puts 'read from cache'

        content = file.read     
        content_type = file.file_info.content_type
     end
    
              
      
    else
            file = grid.open_download_stream(att.file_id)
            content_type = file.file_info.content_type
            content = file.read
    end
    
    
    
   
    
    render :plain=>content,:content_type=>content_type 
    
  end
  

  
  def upload
    @document = Document.find(params[:id])
    @project = Project.find(params[:p_id])
    @document.project = @project
    if request.post?
      
      field_id = params[:field_id]
      atts = @document.attach_field_file field_id,params[:upload][:file].original_filename,params[:ssid],params[:upload][:file], 0 ,params[:ref]
       respond_to do |format|
          format.html {render :action=>'upload.html',:layout=>nil}
          format.json {render :plain=>{:id=>atts.id.to_s,:path=>atts.path,:status=>'ok'}.to_json}
       end
      
    else
      render :action=>'upload.html',:layout=>nil
    end
  end
  
end