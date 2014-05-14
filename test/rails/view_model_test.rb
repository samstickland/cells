require 'test_helper'

# TODO: test if nested state renders are html_safe.

class Song < OpenStruct
  extend ActiveModel::Naming

  def persisted?
    true
  end

  def to_param
    id
  end
end



class SongCell < Cell::Rails
    include Cell::Rails::ViewModel

    def show
      render
    end

    def title
      song.title.upcase
    end

    def self_url
      url_for(song)
    end

    def details
      render
    end

    def stats
      render :details
    end

    def info
      render :info
    end

    def dashboard
      render :dashboard
    end

    def scale
      render :layout => 'b'
    end

    class Lyrics < self
      def show
        render :lyrics
      end
    end

    class PlaysCell < self
    end
  end

class ViewModelTest < MiniTest::Spec
  # class PianoSongCell < Cell::Rails
  #   include ViewModel

  #   property :title
  # end

  # views :show, :create #=> wrap in render_state(:show, *)
  let (:cell) { SongCell.new(nil, :title => "Shades Of Truth") }

  it { cell.title.must_equal "Shades Of Truth" }

  class HitCell < Cell::Base
    include Cell::Rails::ViewModel
    property :title, :artist
  end

  let (:song) { Song.new(:title => "65", artist: "Boss") }
  it { HitCell.new(song).title.must_equal "65" }
  it { HitCell.new(song).artist.must_equal "Boss" }
 end

if Cell.rails_version >= "3.2"
  class ViewModelIntegrationTest < ActionController::TestCase
    tests MusicianController

    #let (:song) { Song.new(:title => "Blindfold", :id => 1) }
    #let (:html) { %{<h1>Shades Of Truth</h1>\n} }
    #let (:cell) {  }

    setup do
      @cell = SongCell.new(@controller, :song => Song.new(:title => "Blindfold", :id => "1"))

      @url = "/songs/1"
      @url = "http://test.host/songs/1" if Cell.rails_version.>=("4.0")
    end


    # test "instantiating without model, but call to ::property" do
    #   assert_raises do
    #     @controller.cell("view_model_test/piano_song")
    #   end
    # end


    test "URL helpers in view" do
        @cell.show.must_equal %{<h1>BLINDFOLD</h1>
<a href=\"#{@url}\">Permalink</a>
} end

    test "URL helper in instance" do
      @cell.self_url.must_equal @url
    end

    test "implicit #render" do
      @cell.details.must_equal "<h3>BLINDFOLD</h3>\n"
      SongCell.new(@controller, :song => Song.new(:title => "Blindfold", :id => 1)).details
    end

    test "explicit #render with one arg" do
      @cell = SongCell.new(@controller, :song => Song.new(:title => "Blindfold", :id => 1))
      @cell.stats.must_equal "<h3>BLINDFOLD</h3>\n"
    end

    test "nested render" do
      @cell.info.must_equal "<li>BLINDFOLD\n</li>\n"
    end

    test "nested rendering method" do
      @cell.dashboard.must_equal "<h1>Dashboard</h1>\n<h3>Lyrics for BLINDFOLD</h3>\n<li>\nIn the Mirror\n</li>\n<li>\nI can see\n</li>\n\nPlays: 99\n\nPlays: 99\n\n"
    end

    test( "layout") { @cell.scale.must_equal "<b>A Minor!\n</b>" }

    # TODO: when we don't pass :song into Lyrics
  end
end

class CollectionTest < MiniTest::Spec
  class ReleasePartyCell < Cell::Rails
    include ViewModel

    def show
      "Party on, #{model}!"
    end

    def show_more
      "Go nuts, #{model}!"
    end
  end
  describe "::collection" do
    it { Cell::Rails::ViewModel.collection("collection_test/release_party", @controller, %w{Garth Wayne}).must_equal "Party on, Garth!\nParty on, Wayne!" }
    it { Cell::Rails::ViewModel.collection("collection_test/release_party", @controller, %w{Garth Wayne}, :show_more).must_equal "Go nuts, Garth!\nGo nuts, Wayne!" }
  end

  # TODO: test with builders ("polymorphic collections") and document that.

end