require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_controller'

class ArturoFeaturesControllerAdminTest < ActionController::IntegrationTest
  def setup
    @current_user = Object.new.tap { |u| u.stubs(:admin?).returns(true) }
    Arturo::FeaturesController.any_instance.
      stubs(:current_user).
      returns(@current_user)
    @features = [
      Factory(:feature),
      Factory(:feature),
      Factory(:feature)
    ]
  end

  def test_get_index
    get "/arturo/features"
    assert_response :success
    assert_select 'table tbody tr input[type=range]'
    assert_select 'table tfoot a[href=?]', arturo_engine.new_feature_path
    assert_select 'table tfoot input[type=submit]'
  end

  def test_put_update_all
    put "/arturo/features", :features => {
      @features.first.id => { :deployment_percentage => '14' },
      @features.last.id  => { :deployment_percentage => '98' }
    }
    assert_equal '14', @features.first.reload.deployment_percentage.to_s
    assert_equal '98', @features.last.reload.deployment_percentage.to_s
    assert_redirected_to arturo_engine.features_path
  end

  def test_get_new
    get "/arturo/features/new"
    assert_response :success
  end

  def test_post_create
    post "/arturo/features", :feature => { :symbol => 'anything' }
    assert Arturo::Feature.find_by_symbol('anything').present?
    assert_redirected_to arturo_engine.features_path
  end

  def test_get_show
    get "/arturo/features/#{@features.first.id}"
    assert_response :success
  end

  def test_get_edit
    get "/arturo/features/#{@features.first.id}/edit"
    assert_response :success
  end

  def test_put_update
    put "/arturo/features/#{@features.first.id}", :feature => { :deployment_percentage => '2' }
    assert_redirected_to arturo_engine.feature_path(@features.first.reload)
  end

  def test_delete_destroy
    delete "/arturo/features/#{@features.first.id}"
    assert_redirected_to arturo_engine.features_path
  end

end
