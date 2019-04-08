class SettingsController < ApplicationController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  # GET /settings
  # GET /settings.json
  def index
    settings_list = %w[
      include_unregistered_packages
      news_type
      sidebar_select
      min_stars
      max_stars
      start_date
      end_date
      since
      sort
    ]

    if params[:clear_cookies]
      clear_all_cookies settings_list
    else
      updated_cookies = update_all_cookies settings_list
    end

    cookies.permanent['needs_refresh'] = true

    prev_url = request.env['HTTP_REFERER']
    prev_url = nil if prev_url.try(:include?, "/settings?")
    prev_url ||= request.base_url

    has_www = params['has_www']
    replace_subdomain = has_www ? 'www.' : ''
    prev_url.sub! 'cdn.', replace_subdomain

    if !params[:clear_cookies] && prev_url.include?("?")
      cur_url, cur_query = prev_url.split "?"

      split_query = cur_query.split "&"

      new_query = []

      split_query.each do |cur_part|
        cur_key, cur_val = cur_part.split "="
        next if updated_cookies.include? cur_key
        new_query << cur_part
      end

      prev_url = "#{cur_url}?#{new_query.join("&")}"
    end

    redirect_to prev_url
  end

  # GET /settings/1
  # GET /settings/1.json
  def show
  end

  # GET /settings/new
  def new
    @setting = Setting.new
  end

  # GET /settings/1/edit
  def edit
  end

  # POST /settings
  # POST /settings.json
  def create
    @setting = Setting.new(setting_params)

    respond_to do |format|
      if @setting.save
        format.html { redirect_to @setting, notice: 'Setting was successfully created.' }
        format.json { render :show, status: :created, location: @setting }
      else
        format.html { render :new }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/1
  # PATCH/PUT /settings/1.json
  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to @setting, notice: 'Setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @setting }
      else
        format.html { render :edit }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/1
  # DELETE /settings/1.json
  def destroy
    @setting.destroy
    respond_to do |format|
      format.html { redirect_to settings_url, notice: 'Setting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_setting
      @setting = Setting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def setting_params
      params.fetch(:setting, {})
    end

    def fix_filter_pairs new_settings
      min_stars = new_settings[:min_stars] && new_settings[:min_stars].to_i
      max_stars = new_settings[:max_stars] && new_settings[:max_stars].to_i

      needs_stars_flip = min_stars.present? && max_stars.present?
      needs_stars_flip &&= ( min_stars > max_stars )

      if needs_stars_flip
        min_stars, max_stars = max_stars, min_stars

        new_settings[:min_stars], new_settings[:max_stars] = \
          new_settings[:max_stars], new_settings[:min_stars]
      end

      new_settings[:min_stars] = '0' if min_stars.present? && min_stars < 0
      new_settings[:max_stars] = '0' if max_stars.present? && max_stars < 0

      start_date = new_settings[:start_date] && new_settings[:start_date].to_date
      end_date = new_settings[:end_date] && new_settings[:end_date].to_date

      needs_date_flip = start_date.present? && end_date.present?
      needs_date_flip &&= ( start_date > end_date )

      if needs_date_flip
        new_settings[:start_date], new_settings[:end_date] = \
          new_settings[:end_date], new_settings[:start_date]
      end
    end

    def clear_all_cookies settings_list
      settings_list.each do |cur_setting|
        cookies.delete cur_setting
      end
    end

    def update_all_cookies settings_list
      new_settings = params.select {
        |p| settings_list.include? p
      }.to_unsafe_hash

      new_settings.each do |k, v|
        new_settings[k] = nil \
          unless v.present?
      end

      fix_filter_pairs new_settings

      new_settings.each do |k, v|
        cookies.permanent[k] = v
      end

      new_settings.keys
    end
end
