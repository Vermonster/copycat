class CopycatTranslationsController < ApplicationController
  def index
    @copycat_translations = CopycatTranslation.all
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
end
