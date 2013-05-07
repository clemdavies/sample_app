require 'spec_helper'

describe "Static pages" do

  subject { page }


  shared_examples_for "all static pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        valid_signin user
        visit root_path
      end


      it "should render plural microposts counter" do
        page.should have_selector("aside.span4 span",text: user.feed.count.to_s + " microposts")
      end#render microposts counter



      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end#render feed


      describe "singular feed counter" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          FactoryGirl.create(:micropost, user: other_user, content: "Lorem ipsum")
          click_link 'Sign out'
          valid_signin other_user
          visit root_path
        end

        it "should render singular microposts counter" do
          page.should have_selector("aside.span4 span",text: other_user.feed.count.to_s + " micropost")
        end#render microposts counter
      end#singular counter

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end#follow[er][ing] counts


    end#signed-in users





  end#home

  describe "Help page" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }
    it_should_behave_like "all static pages"
  end#help

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About Us' }
    let(:page_title) { 'About Us' }
    it_should_behave_like "all static pages"
  end#about

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact Us' }
    let(:page_title) { 'Contact Us' }
    it_should_behave_like "all static pages"
  end#contact

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    page.should have_selector 'title', text: full_title('')
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end#right links

end
