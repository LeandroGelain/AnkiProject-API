class Users::Create
  attr_accessor :params

  def initialize(params)
    @params = params.merge(params_devise_skip)
  end

  def execute
    return unless can_create_user?

    create_user
  end

  private

  def can_create_user?
    raise_error('CPF inválido', 422) unless valid_cpf?
    raise_error('Email já está em uso.', 422) if User.find_by(email: params[:email]).present?
    raise_error('Senha é difenrente da sua confirmção.', 422) unless params[:password] == params[:password_confirmation]

    true
  end

  def valid_cpf?
    return false if CPF.valid?(params[:cpf]).nil?

    true
  end

  def create_user
    User.create!(params.except(:password_confirmation))
  end

  def params_devise_skip
    {
      confirmed_at: DateTime.now
    }
  end

  def raise_error(message, status)
    raise Errors::CustomException.new(message, status)
  end
end
