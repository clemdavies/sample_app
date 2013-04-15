include ApplicationHelper

def valid_signin(user_in)
  visit signin_path
  fill_in "Email",    with: user_in.email
  fill_in "Password", with: user_in.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user_in.remember_token
end

def fill_form(user_in)

                             # if (object has key){ user_in[:name] }else{ 'Example User' }
  fill_in "Name",         with: user_in.key?(:name) ? user_in[:name] : 'Example User'
  fill_in "Email",        with: user_in.key?(:email) ? user_in[:email] : 'user@example.com'
  fill_in "Password",     with: user_in.key?(:password) ? user_in[:password] : 'foobar'
  fill_in "Confirmation", with: user_in.key?(:confirmation) ? user_in[:confirmation] : 'foobar'

end


def blank_all
  fill_form ( { name:nil, email:nil, password:nil, confirmation:nil } )
end

def valid
  fill_form ( { } )
end

def blank_name
  fill_form ( { name: nil } )
end

def long_name
  fill_form ( { name: 'a'*51 } )
end

def blank_email
  fill_form ( { email: nil } )
end

def blank_passwords
  fill_form ( { password: nil, confirmation: nil} )
end

def password_mismatch
  fill_form ( { password: 'a'*6, confirmation: 'b'*6 } )
end

def short_password
  fill_form ( { password: 'a'*3, confirmation: 'a'*3 } )
end


RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_specific_error_message do |message|
  match do |page|
    page.should have_selector('div#error_explanation ul', text: message)
  end
end
