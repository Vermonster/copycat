class CopycatTranslationsController < ApplicationController
  
  http_basic_authenticate_with :name => COPYCAT_USERNAME, :password => COPYCAT_PASSWORD

  layout 'copycat'

  def index
    @copycat_translations = CopycatTranslation.all
    respond_to do |format|
      format.html
      format.yaml { send_data CopycatTranslation.export_yaml, :filename => "copycat_translations_#{Time.now.strftime("%Y_%m_%d_%H_%M_%S")}.yml" }
    end
  end

  def edit
    @copycat_translation = CopycatTranslation.find_by_id(params["id"])
  end
  
  def update
    cct = CopycatTranslation.find_by_id(params["id"])
    cct.value = params["copycat_translation"]["value"]
    if cct.save
      @copycat_translations = CopycatTranslation.all
      redirect_to copycat_translations_path
    else
      @copycat_translation = cct
      render :action => 'edit'
    end
  end

  def readme
  end

  def upload
  end

  def import_yaml
    begin
      CopycatTranslation.import_yaml(params["file"].tempfile)
    rescue StandardError => e
      flash[:notice] = "There was an error processing your upload!"
      render :action => 'upload', :status => 400
    else
      redirect_to copycat_translations_path, :notice => "YAML file uploaded successfully!"
    end
  end

end
