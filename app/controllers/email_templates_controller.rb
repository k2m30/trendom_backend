class EmailTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email_templates

  def index
  end

  def clone
    new_template = @current_template.clone
    redirect_to email_templates_path(email_template_id: new_template.id), notice: 'Template was cloned.'
  end

  def new
    new_template = current_user.email_templates.create(name: 'New template', text: '')
    redirect_to email_templates_path(email_template_id: new_template.id)
  end

  def update
    if @current_template.update(email_template_params)
      redirect_to email_templates_path(email_template_id: @current_template.id), notice: 'Template was successfully updated.'
    else
      redirect_to email_templates_path(email_template_id: @current_template.id), alert: 'Template was not updated.'
    end
  end

  def destroy
    @current_template.destroy
    redirect_to email_templates_path, notice: 'Template was successfully destroyed.'
  end


  private

  def set_email_templates
    @email_templates = current_user.email_templates.order(:name)
    unless @email_templates.empty?
      current_template_id = params[:email_template_id] || params[:id]|| @email_templates.first.id
      @current_template = @email_templates.find(current_template_id)
    end
  end

  def email_template_params
    params.require(:email_template).permit(:name, :text, :id)
  end

end
