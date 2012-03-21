class CopycatTranslationsController < ApplicationController
  
  http_basic_authenticate_with :name => COPYCAT_USERNAME, :password => COPYCAT_PASSWORD

  layout 'copycat'

  def index
    params[:locale] = I18n.default_locale unless params.has_key?(:locale)
    query = CopycatTranslation
    query = query.where(locale: params[:locale]) unless params[:locale].blank?

    if params.has_key?(:search)
      if (search = params[:search]).blank?
        @copycat_translations = query.all
      else
        @copycat_translations = query.where("key LIKE ? OR value LIKE ?", "%#{search}%", "%#{search}%")
      end
    else
      @copycat_translations = []
    end
    @locale_names = CopycatTranslation.find(:all, select: 'distinct locale').map(&:locale)
  end

  def edit
    @copycat_translation = CopycatTranslation.find_by_id(params["id"])
  end
  
  def update
    cct = CopycatTranslation.find_by_id(params["id"])
    cct.value = params["copycat_translation"]["value"]
    if cct.save
      redirect_to copycat_translations_path
    else
      @copycat_translation = cct
      render :action => 'edit'
    end
  end

  def help
  end

  def import_export
  end

  def download
    filename = "copycat_translations_#{Time.now.strftime("%Y_%m_%d_%H_%M_%S")}.yml"
    send_data CopycatTranslation.export_yaml, :filename => filename
  end

  def upload
    begin
      CopycatTranslation.import_yaml(params["file"].tempfile)
    rescue StandardError => e
      flash[:notice] = "There was an error processing your upload!"
      render :action => 'import_export', :status => 400
    else
      redirect_to copycat_translations_path, :notice => "YAML file uploaded successfully!"
    end
  end

end
