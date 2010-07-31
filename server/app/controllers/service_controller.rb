class ServiceController < ApplicationController
  before_filter :determine_credentials, :skip => [:connect]

  def connect
    db = DatabaseManager.credentials(params)
    response = {}
    begin
      connected = db.try(:connect) ? "true" : "false"
      session[:credentials] = params
    rescue Exception => e
      connected = "false"
      response.merge!(:error => e.error)
    end
    
    render :json => response.merge({:connected => connected})
  end
  
  def tables
    db = DatabaseManager.credentials(@credentials)
    begin
      if db.connect
        tables = db.tables
        render :json => {:database => @credentials[:database], :tables => tables}
      end
    rescue Exception => e
      render :json => {:error => "true", :message => e.inspect}
    end
  end
  
private
  def determine_credentials
     @credentials = params
     
    #if session && session.has_key?(:credentials)
    #  @credentials = session[:credentials]
    #else
    #  @credentials = params
    #end
  end
end
