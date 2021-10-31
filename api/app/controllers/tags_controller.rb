class TagsController < ApplicationController
  def index
    @tags = current_user.tags.order(:name)
  end

  def create
  end

  def destroy
  end

  def edit
    @tag = current_user.tags.find(params[:id])
    render 'form'
  end

  def update
    @tag = current_user.tags.find(params[:id])

    if @tag.update(tag_params)
      flash[:notice] = 'Tag successfully updated'
      redirect_to edit_tag_path(@tag)
    else
      flash[:alert] = 'Could not update Tag'
      render 'form'
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
