class FieldsController < ApplicationController
  before_action :find_field, only: %i(show favorite unfavorite)

  def index
    @q = Field.ransack(params[:q])
    @fields = @q.result(distinct: true).with_ave_rate
    @pagy, @fields = pagy(@fields, limit: Settings.field_in_field_list)
  end

  def show
    @rating = @field.ratings.build comment: Comment.new
    @average_rating = @field.ratings.average(:rating).to_f
    @images = @field.images

    @pagy, @images = pagy @images, limit: Settings.image_field_in_field_detail
  end

  def favorite
    favorite = current_user.favorites.new favoritable: @field
    if favorite.save
      flash[:success] = t ".favorites.favorite_added"
    else
      flash[:danger] = t ".favorites.favorite_failed"
      redirect_to fields_path
    end

    respond_to_format
  end

  def unfavorite
    favorite = find_favorite

    if destroy_favorite favorite
      flash[:success] = t ".favorites.favorite_removed"
    else
      handle_unfavorite_error favorite
    end

    respond_to_format
  end

  private

  def find_field
    @field = Field.find_by id: params[:id]
    return if @field

    flash[:danger] = t ".favorites.field_not_found"
    redirect_to fields_path
  end

  def filter
    @fields = @fields
              .filter_by_name(params[:name])
              .filter_by_grass(params[:grass])
              .filter_by_capacity(params[:capacity])
              .sort_by_price(params[:price])
              .favorited_by(current_user, params[:favorites])
  end

  def find_favorite
    current_user.favorites.find_by favoritable: @field
  end

  def destroy_favorite favorite
    favorite&.destroy
  end

  def handle_unfavorite_error
    flash[:danger] = t ".favorites.favorite_remove_failed"
    redirect_to fields_path
  end

  def respond_to_format
    respond_to do |format|
      format.turbo_stream
      format.html{redirect_back fallback_location: field_path(@field)}
    end
  end
end
