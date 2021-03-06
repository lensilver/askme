require 'openssl'

class User < ApplicationRecord
  ITERATIONS = 20_000
  DIGEST = OpenSSL::Digest::SHA256.new
  USERNAME_VALIDATION = /\A\w+\z/
  
  attr_accessor :password
  has_many :questions, dependent: :destroy

  validates :email, :username, presence: true
  validates :email, :username, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :username, length: { maximum: 40 }
  validates :username, format: { with: USERNAME_VALIDATION }  

  validates :password, presence: true, on: :create
  validates :password, confirmation: true

  before_validation :username_downcase, :email_downcase
  before_save :encrypt_password

  # Служебный метод, преобразующий бинарную строку в шестнадцатиричный формат,
  # для удобства хранения.
  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  # Основной метод для аутентификации юзера (логина). Проверяет email и пароль,
  # если пользователь с такой комбинацией есть в базе, возвращает этого
  # пользователя. Если нет — возвращает nil.
  def self.authenticate(email, password)
    # Сперва находим кандидата по email
    user = find_by(email: email&.downcase)

    # Если пользователь не найден, возвращает nil
    return unless user.present?

    # Формируем хэш пароля из того, что передали в метод
    hashed_password = User.hash_to_string(
    OpenSSL::PKCS5.pbkdf2_hmac(
      password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )

    # Обратите внимание: сравнивается password_hash, а оригинальный пароль так
    # никогда и не сохраняется нигде. Если пароли совпали, возвращаем
    # пользователя.
    user if user.password_hash == hashed_password
  end

private

def encrypt_password
  if password.present?
    # Создаем т.н. «соль» — случайная строка, усложняющая задачу хакерам по
    # взлому пароля, даже если у них окажется наша БД.
    # У каждого юзера своя «соль», это значит, что если подобрать перебором пароль
    # одного юзера, нельзя разгадать, по какому принципу
    # зашифрованы пароли остальных пользователей
    self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

    # Создаем хэш пароля — длинная уникальная строка, из которой невозможно
    # восстановить исходный пароль. Однако, если правильный пароль у нас есть,
    # мы легко можем получить такую же строку и сравнить её с той, что в базе.
    self.password_hash = User.hash_to_string(
      OpenSSL::PKCS5.pbkdf2_hmac(
        password, password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )

    # Оба поля попадут в базу при сохранении (save).
    end
  end

  def username_downcase
    username&.downcase!
  end

  def email_downcase
    email&.downcase!
  end
end