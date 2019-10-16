class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[facebook google_oauth2]

  validates :nickname, presence: true
  validates :password_confirmation, presence: true
  validates :password, presence: true, length: { in: 7..128 }
  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :last_kana_name, presence: true
  validates :first_kana_name, presence: true
  # validates :birthday, presence: true
  validate :add_error
  def add_error
    unless password.match(/([0-9].*[a-zA-Z]|[a-zA-Z].*[0-9])/)
      errors.add(:password, "は、英字と数字両方を含むものを設定してください")
    end
  end  

  has_one :card, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :orders
  has_many :todo_lists
  has_many :sales, dependent: :destroy
  has_many :transfer_applications
  has_many :points, dependent: :destroy
  has_many :contacts
  has_many :informations
  has_many :notices
  has_many :likes
  has_many :comments
  has_one :bank_account
  has_one :address

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.omniauth_data']
        user.email = data['email'] if user.email.blank?
        user.nickname = data['name'] if user.nickname.blank?
        user.uid = data['uid'] if user.uid.blank?
        user.provider = data['provider'] if user.provider.blank?
        user.password = Devise.friendly_token[0,20] if user.password.blank?
      end
    end
  end
end
