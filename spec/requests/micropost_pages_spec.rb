require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { valid_signin user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end#should not create

      describe "has error message" do
        before { click_button "Post" }
        it { should have_content('error') }
      end#error msg

    end#invalid information

    describe "with valid information" do
      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end#should create
    end#valid information

  end#micropost creation

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end#correct user


    describe "no delete link as incorrect user" do

      let(:other_user){FactoryGirl.create(:user)}
      before { visit "/users/"+other_user.id.to_s }
      it {should_not have_link("delete")}

    end#correct user

  end#micropost destruction

  describe "micropost pagination" do

    before do
      for i in 1..90
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum" + i.to_s)
      end
      visit root_path
    end

    it "should render 30 microposts" do
      page.should have_selector("ol li", :count=>30)
    end

    it "should render correct links" do

      page.should have_link("Previous", href:"#")
      page.should have_selector("div.pagination li.previous_page.disabled",text:"Previous")

      page.should have_link("Next", href:"/?page=2")
      page.should have_selector("div.pagination li.next_page",text:"Next")

      page.should have_link("1", href:"/?page=1")
      page.should have_selector("div.pagination li a",text:"1")

      page.should have_link("2", href:"/?page=2")
      page.should have_selector("div.pagination li a",text:"2")

      page.should_not have_link("4", href:"/?page=4")
      page.should_not have_selector("div.pagination li a",text:"4")
    end


  end#micropost pagination



end
