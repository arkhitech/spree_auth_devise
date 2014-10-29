class Spree::UserSessionsController < Devise::SessionsController
  helper 'spree/base'

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Store
  

  def create
    authenticate_spree_user!
    if spree_user_signed_in?
      respond_to do |format|
        format.html {
          flash[:success] = Spree.t(:logged_in_succesfully)
          redirect_back_or_default(after_sign_in_path_for(spree_current_user))
        }
        format.js {
          api_key=spree_current_user.spree_api_key
          if api_key.nil?
            spree_current_user.generate_spree_api_key!
            api_key=spree_current_user.spree_api_key
          end
          render json: spree_current_user
        
        }
        format.json {
          api_key=spree_current_user.spree_api_key
          if api_key.nil?
            spree_current_user.generate_spree_api_key!
            api_key=spree_current_user.spree_api_key
          end
           render json: spree_current_user
        }
      end
    else
      respond_to do |format|
        format.html {
          flash.now[:error] = t('devise.failure.invalid')
          render :new
        }
        format.js {
          render :json => { error: t('devise.failure.invalid') }, status: :unprocessable_entity
        }
        format.json {
          render :json => { error: t('devise.failure.invalid') }, status: :unprocessable_entity
        }
      end
    end
  end
  
  private
    def accurate_title
      Spree.t(:login)
    end

    def redirect_back_or_default(default)
      redirect_to(session["spree_user_return_to"] || default)
      session["spree_user_return_to"] = nil
    end    
end
