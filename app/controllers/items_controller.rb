class ItemsController < ApplicationController
  def index
    @items = Item.all
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(resource_params)

    if @item.save
      redirect_to items_path
    else
      render 'new'
    end
  end

  private

  def resource_params
    params.require(:item).permit(:name)
  end
end
