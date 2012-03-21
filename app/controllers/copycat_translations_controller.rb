class CopycatTranslationsController < ApplicationController
  
  http_basic_authenticate_with :name => COPYCAT_USERNAME, :password => COPYCAT_PASSWORD

  layout 'copycat'

  def index
    @current_locale = params["locale"] || I18n.locale.to_s
    @copycat_translations = []
    if params["show_all"]
      @copycat_translations = CopycatTranslation.where(locale: @current_locale)
    elsif (query = params["show_like"]) && query.present?
      @copycat_translations = CopycatTranslation.where(locale: @current_locale).where("key LIKE ? OR value LIKE ?", "%#{query}%", "%#{query}%")
    end
    @locales = CopycatTranslation.all.map(&:locale).uniq
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

  def change_locale
    redirect_to "#{copycat_translations_path}?locale=#{params["locale"]}"
  end

  def search
    url = "#{copycat_translations_path}?locale=#{params["locale"]}"
    if params["show_all"]
      url += "&show_all=true" 
    elsif params["show_like"]
      url += "&show_like=#{params["show_like"]}"
    end
    redirect_to url
  end

end
