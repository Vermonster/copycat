class CopycatTranslationsController < ApplicationController
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
      Copycat.clear_cache(params["copycat_translation"]["key"])
      @copycat_translations = CopycatTranslation.all
      redirect_to copycat_translations_path
    else
      @copycat_translation = cct
      render :action => 'edit'
    end
  end

  def upload
  end

  def import_yaml
    begin
      yaml = YAML.load(params["file"].tempfile)
      CopycatTranslation.import_yaml(yaml)
      redirect_to copycat_translations_path, :notice => "YAML file uploaded successfully!"
    rescue => e
      redirect_to upload_copycat_translations_path, :notice => "Oh no! invalid YAML file."
    end
  end

end
