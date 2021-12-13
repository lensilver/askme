module ApplicationHelper
	# Этот метод возвращает ссылку на аватарку пользователя, если она у него есть.
  # Или ссылку на дефолтную аватарку, которую положим в app/assets/images
  def user_avatar(user)
    if user.avatar_url.present?
      user.avatar_url
    else
      asset_path 'avatar.jpg'
    end
  end

  def inclination(number, vopros, voprosa, voprosov)
    result = number % 10 unless (11..14).include?(number % 100)
      case result
      when 1 then vopros
      when 2..4 then voprosa
      else voprosov
      end
  end

  def fa_icon(icon_class)
    content_tag 'span', '', class: "fa fa-#{icon_class}"
  end
end