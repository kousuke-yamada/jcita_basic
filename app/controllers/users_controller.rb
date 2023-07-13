class UsersController < ApplicationController
  include AttendancesHelper
  
  before_action :set_user, only: [:show, :edit, :update, :destroy, :mode_easy, :mode_hard, :mode_cat,:save_record, :ranking, :edit_basic_info, :update_basic_info, :confirm_attendance, :csv_export]
  before_action :logged_in_user, only: [:index,:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: :edit
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, :attendance_at_work, :search]
  before_action :admin_or_correct_user, only: [:show, :update]
  before_action :invalid_admin_page, only: [:show, :update]
  before_action :set_one_month, only: [:show, :confirm_attendance, :csv_export]
  before_action :set_monthly_attendance, only: [:show, :confirm_attendance]
  before_action :set_superior_user, only: :show

  skip_before_action :verify_authenticity_token

  def index
    @users = User.paginate(page: params[:page]).where.not(name: @current_user.name).order(:id)
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil, finished_at: nil).count

    # １ヶ月分の勤怠申請件数の取得
    @one_month_attendance_sum = User.joins(:monthly_attendances).where(monthly_attendances: {approval_status: "申請中", instructor: @user.name}).count

    # 勤怠変更申請件数の取得
    @attendance_chg_req_sum = User.joins(:attendances).where(attendances: {approval_status: "申請中", instructor: @user.name}).count

    # 残業申請の件数取得
    @overtime_attendance_sum = User.joins(:attendances).where(attendances: {overtime_approval_status: "申請中", overtime_instructor: @user.name}).count
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user  # 保存成功後、ログインします。
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      if current_user.admin?
        redirect_to users_url
      else  
        redirect_to @user
      end
    else
      if current_user.admin?
        redirect_to users_url
      else
        render :edit
      end
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def mode_easy
    @mode = 1
    @best_record = @user.records1
  end

  def mode_hard
    @mode = 2
    @best_record = @user.records4
  end

  def mode_cat
    @mode = 3
    @best_record = @user.records7
  end

  def save_record
    @mode = params[:mode].to_i
    @record = params[:record].to_f

    case @mode
    when 1 then # EASYモード
      if @record < @user.records1
        @user.records3 = @user.records2
        @user.records2 = @user.records1
        @user.records1 = @record
      
      elsif @record < @user.records2
        @user.records3 = @user.records2
        @user.records2 = @record
      
      elsif @record < @user.records3
        @user.records3 = @record
      
      else
        # ランキング更新しない
      end

    when 2 then # HARDモード
      if @record < @user.records4
        @user.records6 = @user.records5
        @user.records5 = @user.records4
        @user.records4 = @record
      
      elsif @record < @user.records5
        @user.records6 = @user.records5
        @user.records5 = @record
      
      elsif @record < @user.records6
        @user.records6 = @record
      
      else
        # ランキング更新しない
      end

    when 3 then # CATモード
      if @record < @user.records7
        @user.records9 = @user.records8
        @user.records8 = @user.records7
        @user.records7 = @record
      
      elsif @record < @user.records8
        @user.records9 = @user.records8
        @user.records8 = @record
      
      elsif @record < @user.records9
        @user.records9 = @record
      
      else
        # ランキング更新しない
      end
    else
      # 処理なし
    end

    @user.save    
  end

  def ranking

  end

  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def search
    if params[:name].present?
      @users = User.where('name LIKE ?', "%#{params[:name]}%").page(params[:page]).per_page(20)
    else
      @users = User.paginate(page: params[:page])
    end
   
  end

  def csv_import
    if params[:file].present?
      error = User.import(params[:file])
      
      # インポート失敗時の処理
      if error.presence
        flash[:danger] = "csvインポート失敗しました。#{error}"
      else
        flash[:success] = "csvインポート成功しました。"
      end
    else
      # ファイル未選択
      flash[:danger] = "csvファイルを選択してください。"
    end

    redirect_to users_url
  end

  def csv_export
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
  end

  def attendance_at_work
    @users = User.joins(:attendances).where(attendances: {worked_on: Date.today, finished_at: nil}).where.not(attendances: {started_at: nil})
  end

  def confirm_attendance
    @worked_sum = @attendances.where.not(started_at: nil, finished_at: nil).count
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time, :password, :password_confirmaiton)
    end
    
    def basic_info_params
      params.require(:user).permit(:affiliation,:basic_work_time, :designated_work_start_time)
    end

     def send_attendances_csv(attendances)
      csv_data = CSV.generate do |csv|
        column_names = %w(日付 曜日 出社 退社)
        csv << column_names
        attendances.each do |attendance|
          if attendance.started_at.present? && attendance.finished_at.present?
              
            column_values = [
              l(attendance.worked_on, format: :short),          # 日付
              $days_of_the_week[attendance.worked_on.wday],     # 曜日
              l(calc_round_time(attendance.started_at), format: :time),                     # 出社
              l(calc_round_time(attendance.finished_at), format: :time),                    # 退社
            ]
          else
            column_values = [
              l(attendance.worked_on, format: :short),          # 日付
              $days_of_the_week[attendance.worked_on.wday],     # 曜日
              "",          # 出社
              "",         # 退社
            ]
          end  

          csv << column_values
        end
      end
      send_data(csv_data, filename: "勤怠一覧.csv")    
     end 
end
