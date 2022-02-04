class ScriptTemplatesController < EsmAdminController
  
        # esm_scaffold :script_template do |config|
       #
       #  end
        
        
        # def index
        #
        #   render :plain=>'OK'
        #
        # end
        
        
        
        # GET /script_templates or /script_templates.json
        def index
          @script_templates = ScriptTemplate.all
        end

        # GET /script_templates/1 or /script_templates/1.json
        def show
          @script_template = ScriptTemplate.find params[:id]
        end

        # GET /script_templates/new
        def new
          @script_template = ScriptTemplate.new
        end

        # GET /script_templates/1/edit
        def edit
        end

        # POST /script_templates or /script_templates.json
        def create
          @script_template = ScriptTemplate.new(script_template_params)

          respond_to do |format|
            if @script_template.save
              format.html { redirect_to script_template_url(@script_template), notice: "Script template was successfully created." }
              format.json { render :show, status: :created, location: @script_template }
            else
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @script_template.errors, status: :unprocessable_entity }
            end
          end
        end

        # PATCH/PUT /script_templates/1 or /script_templates/1.json
        def update
          respond_to do |format|
            if @script_template.update(script_template_params)
              format.html { redirect_to script_template_url(@script_template), notice: "Script template was successfully updated." }
              format.json { render :show, status: :ok, location: @script_template }
            else
              format.html { render :edit, status: :unprocessable_entity }
              format.json { render json: @script_template.errors, status: :unprocessable_entity }
            end
          end
        end

        # DELETE /script_templates/1 or /script_templates/1.json
        def destroy
          @script_template.destroy

          respond_to do |format|
            format.html { redirect_to script_templates_url, notice: "Script template was successfully destroyed." }
            format.json { head :no_content }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_script_template
            @script_template = ScriptTemplate.find(params[:id])
          end

          # Only allow a list of trusted parameters through.
          def script_template_params
            params.require(:script_template).permit(:name)
          end
        
 
end
