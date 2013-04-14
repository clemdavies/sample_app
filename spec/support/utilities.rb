include ApplicationHelper

def valid_signin(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

def signup(user_in)
                             # if (object has key){ user_in[:name] }else{ 'Example User' }
  fill_in "Name",         with: user_in.key?(:name) ? user_in[:name] : 'Example User'
  fill_in "Email",        with: user_in.key?(:email) ? user_in[:email] : 'user@example.com'
  fill_in "Password",     with: user_in.key?(:password) ? user_in[:password] : 'foobar'
  fill_in "Confirmation", with: user_in.key?(:confirmation) ? user_in[:confirmation] : 'foobar'
end

def valid_signup
  signup ( { } )
end

def blank_name_signup
  signup ( { name: nil } )
end

def blank_email_signup
  signup ( { email: nil } )
end

def blank_passwords_signup
  signup ({ password: nil, confirmation: nil})
end

def password_mismatch_signup
  signup ({ password: "foobar", confirmation: "raboof" })
end

def short_password_signup
  signup ({ password: "foo", confirmation: "foo" })
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
