class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :monthly_attendances, dependent: :destroy
  
  attr_accessor :remember_token
  
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  with_options if: :line_login_check do |user|
    user.before_save { self.email = email.downcase }
    user.validates :email, presence: true, 
                      length: {maximum: 100},
                      format: {with: VALID_EMAIL_REGEX},
                      uniqueness: true
    user.validates :affiliation, length: {in: 2..30}, allow_blank: true
    user.validates :basic_work_time, presence: true
    user.validates :designated_work_start_time, presence: true
    user.validates :designated_work_end_time, presence: true
  end

  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil:true
  
  def line_login_check
    line_user_id.blank?
  end

  # 渡された文字列のハッシュ値を返します
  def User.digest(string)
    cost = 
    if ActiveModel::SecurePassword.min_cost
      BCrypt::Engine::MIN_COST
    else
      BCrypt::Engine.cost
    end
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返します
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # トークンがダイジェストと一致すればtrueを返します
  def authenticated?(remeber_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remeber_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # importメソッド
  def self.import(file)
    errors = ""
    ActiveRecord::Base.transaction do  # トランザクションを開始します。
      CSV.foreach(file.path, headers: true).with_index(1) do |row,line|
          
        # IDが見つかれば、レコードを呼び出し、見つからなければ新しく作成
        user = User.find_by(id: row[:id]) || User.new
        $line_no = line

        # CSVからデータを取得し、設定する
        user.attributes = row.to_hash.slice(*updatable_attributes)
        if !user.save
          errors = " 【エラー】csvファイル #{line}行目 : "
          user.errors.full_messages.each do |msg|
            errors += msg
          end 
        end

        raise ActiveRecord::Rollback if errors.present?
      end
    end
    
    return errors.presence || nil
  end
  
  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid", "basic_work_time", "designated_work_start_time", "designated_work_end_time", "superior", "admin", "password"]
  end

end