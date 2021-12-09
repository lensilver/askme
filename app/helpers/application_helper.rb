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
end

def inclination(number, vopros, voprosa, voprosov)
  if (11..14).include?(number % 100)
    return voprosov
  end
    ostatok = number % 10
  if ostatok == 1
    return vopros
  end
  if ostatok.between?(2,4)
    return voprosa
  end
  if ostatok.between?(5,9) || ostatok == 0
    return voprosov
  end
end