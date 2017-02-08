class LabelsController < ApplicationController
  def index
    @labels = Label.all
  end

  def create
    @label = Label.new
    if @label.update_attributes(label_params)
      flash[:notice] = 'Label successfully created'
      redirect_to action: :index
    else
    end
  end

  def destroy
    @label = Label.find(params[:id])
    @label.destroy!
    flash[:notice] = 'Label successfully deleted'
    redirect_to action: :index
  end

  def edit
    @label = Label.find(params[:id])
    render 'form'
  end

  def update
    @label = Label.find(params[:id])

    if @label.update_attributes(label_params)
      flash[:notice] = 'Label successfully updated'
      redirect_to edit_label_path(@label)
    else
    end
  end

  private

  def label_params
    params.require(:label).permit(:name, :description, :fa_icon, :scraper)
  end
end
