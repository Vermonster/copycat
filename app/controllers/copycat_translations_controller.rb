class CopycatTranslationsController < ApplicationController
  
  http_basic_authenticate_with :name => COPYCAT_USERNAME, :password => COPYCAT_PASSWORD

  layout 'copycat'

  def index
    
    #locale
    # 1. not on URL at all
    #   - set to default_locale
    # 2. present but blank 
    # 3. present with value


    #search
    # 1. not on URL at all
    #  - show nothing
    # 2. present but blank
    #  - show everything
    #    - L1 got set to default locale
    #    - L2 show for all locales
    #    - L3 scope to one locale
    # 3. present with value
    #  - show matching
    #    - L1 got set to default locale
    #    - L2 show for all locales
    #    - L3 scope to one locale

    
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

  def readme
  end

  def import_export
  end

  def download
    send_data CopycatTranslation.export_yaml, 
      :filename => "copycat_translations_#{Time.now.strftime("%Y_%m_%d_%H_%M_%S")}.yml"
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
