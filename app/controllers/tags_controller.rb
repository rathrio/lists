class TagsController < ApplicationController
  def index
    @tags = Tag.all.order(:name)
  end

  def create
    @label = Label.new

    if @label.update_attributes(label_params)
      flash[:notice] = 'Label successfully created'
    else
      flash[:alert] = 'Could not create label'
    end

    redirect_to action: :index
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
      flash[:alert] = 'Could not update label'
      render 'form'
    end
  end

  private

  def label_params
    params.require(:label).permit(:name, :description, :fa_icon, :scraper)
  end
end
