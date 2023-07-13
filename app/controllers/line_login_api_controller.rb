class LineLoginApiController < ApplicationController
  require 'json'
  require 'typhoeus'
  require 'securerandom'

  def login

    # CSRF対策用の固有な英数字の文字列
    # ログインセッションごとにWebアプリでランダムに生成する
    session[:state] = SecureRandom.urlsafe_base64

    # ユーザーに認証と認可を要求する
    # https://developers.line.biz/ja/docs/line-login/integrate-line-login/#making-an-authorization-request

    base_authorization_url = 'https://access.line.me/oauth2/v2.1/authorize'
    response_type = 'code'
    client_id = '1661284652' #本番環境では環境変数などに保管する
    redirect_uri = CGI.escape(line_login_api_callback_url)
    state = session[:state]
    scope = 'profile%20openid' #ユーザーに付与を依頼する権限

    authorization_url = "#{base_authorization_url}?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"

    redirect_to authorization_url, allow_other_host: true
  end

  def callback

    # CSRF対策のトークンが一致する場合のみ、ログイン処理を続ける
    if params[:state] == session[:state]

      line_user_id, line_user_name = get_line_user_id(params[:code])
      line_user = User.find_or_initialize_by(line_user_id: line_user_id)

      if line_user.new_record?
        line_user.name = line_user_name
        line_user.password = "password"
        line_user.password_confirmation = "password"
      end

      if line_user.save
        session[:user_id] = line_user.id
        flash[:success] = 'ログインしました。'
        redirect_to line_user
        
      else
        flash[:danger] = 'ログインに失敗しました。'
        redirect_to root_path
      end

    else
      flash[:danger] = '不正なアクセスです'
      redirect_to root_path
    end

  end

  private

  def get_line_user_id(code)

    # ユーザーのIDトークンからプロフィール情報（ユーザーID）を取得する
    # https://developers.line.biz/ja/docs/line-login/verify-id-token/

    line_user_id_token = get_line_user_id_token(code)

    if line_user_id_token.present?

      url = 'https://api.line.me/oauth2/v2.1/verify'
      options = {
        body: {
          id_token: line_user_id_token,
          client_id: '1661284652' # 本番環境では環境変数などに保管
        }
      }

      response = Typhoeus::Request.post(url, options)

      if response.code == 200
        return JSON.parse(response.body)['sub'], JSON.parse(response.body)['name']
      else
        nil
      end
    
    else
      nil
    end

  end

  def get_line_user_id_token(code)

    # ユーザーのアクセストークン（IDトークン）を取得する
    # https://developers.line.biz/ja/reference/line-login/#issue-access-token

    url = 'https://api.line.me/oauth2/v2.1/token'
    redirect_uri = line_login_api_callback_url

    options = {
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      },
      body: {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirect_uri,
        client_id: '1661284652', # 本番環境では環境変数などに保管
        client_secret: '0bb82ca7c77fad5cbacec7fddde12e7f' # 本番環境では環境変数などに保管
      }
    }
    response = Typhoeus::Request.post(url, options)

    if response.code == 200
      JSON.parse(response.body)['id_token'] # ユーザー情報を含むJSONウェブトークン（JWT）
    else
      nil
    end
  end

end
