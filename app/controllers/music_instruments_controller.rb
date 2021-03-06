# frozen_string_literal: true

class MusicInstrumentsController < ApplicationController
  before_action :set_music_instrument, only: %i[show edit update destroy approve reject]
  before_action :authenticate_user!, except: %i[search home]
  def index
    @music_instruments = MusicInstrument.where(role: params[:role]) if params[:role].present?
end
  def show
    @reviews = Review.where(music_instrument_id: @music_instrument.id).order('created_at DESC')

    if @reviews.blank?
              @avg_review = 0
                  else
                @avg_review = @reviews.average(:rating).round(2)
                  end
    @conversation = Conversation.where(music_instrument_id: @music_instrument.id)
  end

  def home
    if params[:sub_categor_ids].present? && params[:remote].present?
      @music_instruments = MusicInstrument.where(sub_category_id: params[:sub_categor_ids], approved_by: true).order('created_at DESC')
      respond_to :js
    elsif params[:min_price].present? && params[:max_price].present?
      @music_instruments = MusicInstrument.where('price BETWEEN ? AND ?', params[:min_price], params[:max_price], true)
    elsif params[:min_price].present?
      @music_instruments = MusicInstrument.where('price <= ? AND approved_by = ?', params[:min_price], true)
    elsif params[:max_price].present?
      @music_instruments = MusicInstrument.where('price >= ? AND approved_by = ?', params[:min_price], true)
    else
      @music_instruments = MusicInstrument.where(approved_by: true).order('created_at DESC')
    end
  end

  def approve
    @music_instrument.update(approved_by: true)
    @music_instrument.update(approved_by_id: current_user.id)
    redirect_to '/admin'
  end

  def reject
    @music_instrument.update(approved_by: nil)
    redirect_to '/admin'
  end

  def filter_by_price
    @music_instruments = MusicInstrument.where('price <= ? ', params[:price])
  end

  def send_mail
    NotificationMailer.with(user: current_user).delay.send_notification_mail
    redirect_to root_path
  end

  # GET /music_instruments/new
  def new
    @music_instrument = MusicInstrument.new
  end

  # GET /music_instruments/1/edit
  def edit; end

  # POST /music_instruments
  # POST /music_instruments.json
  def create
    @music_instrument = MusicInstrument.new(music_instrument_params)

    respond_to do |format|
      if @music_instrument.save
        format.html { redirect_to @music_instrument, notice: 'music instrument created' }
        format.json { render :show, status: :created, location: @music_instrument }
      else
        format.html { render :new }
        format.json { render json: @music_instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /music_instruments/1
  # PATCH/PUT /music_instruments/1.json
  def update
    respond_to do |format|
      if @music_instrument.update(music_instrument_params)
        format.html { redirect_to @music_instrument, notice: 'music instrument updated' }
        format.json { render :show, status: :ok, location: @music_instrument }
      else
        format.html { render :edit }
        format.json { render json: @music_instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /music_instruments/1
  # DELETE /music_instruments/1.json
  def destroy
    @music_instrument.destroy
    respond_to do |format|
      format.html { redirect_to music_instruments_url, notice: 'Music instrument  destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:search].present?
      @music_instruments = MusicInstrument.search(params[:search])
    else
      @MusicInstruments = MusicInstrument.all
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_music_instrument
    @music_instrument = MusicInstrument.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def music_instrument_params
    params.require(:music_instrument).permit(:item_tittle, :music_category_id, :item_description, :user_id,
                                             :phone_number, :price, :role, :approved_by, :sub_category_id, images: [])
  end
end
