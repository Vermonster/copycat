class CopycatTranslationsController < ActionController::Base
  
  http_basic_authenticate_with :name => Copycat.username, :password => Copycat.password
  before_action :set_copycat_translation, only: [:destroy, :edit, :update]

  layout 'copycat'

  def index
    params[:locale] = I18n.default_locale unless params.has_key?(:locale)
    query = CopycatTranslation
    query = query.where(locale: params[:locale]) unless params[:locale].blank?

    if params.has_key?(:search)
      if params[:search].blank?
        @copycat_translations = query.all
      else
        key_like = CopycatTranslation.arel_table[:key].matches("%#{params[:search]}%")
        value_like = CopycatTranslation.arel_table[:value].matches("%#{params[:search]}%")
        @copycat_translations = query.where(key_like.or(value_like))
      end
    else
      @copycat_translations = []
    end
    @locale_names = CopycatTranslation.find(:all, select: 'distinct locale').map(&:locale)
  end

  def edit
  end
  
  def update
    @copycat_translation.update(copycat_translation_params)
    redirect_to copycat_translations_path, :notice => "#{@copycat_translation.key} updated!"
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
    rescue Exception => e
      logger.info "\n#{e.class}\n#{e.message}"
      flash[:notice] = "There was an error processing your upload!"
      render :action => 'import_export', :status => 400
    else
      redirect_to copycat_translations_path, :notice => "YAML file uploaded successfully!"
    end
  end

  def destroy
    notice = "#{@copycat_translation.key} deleted!"
    @copycat_translation.destroy
    redirect_to copycat_translations_path, :notice => notice
  end

  def help
  end
  
  private
  
  def copycat_translation_params
    params.require(:copycat_translation).permit(:locale, :key, :value)
  end
  
  def set_copycat_translation
    @copycat_translation = CopycatTranslation.find(params[:id])
  end
end
