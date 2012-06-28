require File.expand_path('../../test_helper', __FILE__)

class ArturoGlobalFeatureTest < ActiveSupport::TestCase
  def setup
    reset_translations!
  end

  def feature
    @feature ||= Factory(:global_feature)
  end

  def test_correct_class_name_used
    assert_equal feature.class_name, "Arturo::GlobalFeature"
  end

  def test_responds_to_feature_enabled_helper
    feature.enable!
    assert ::Arturo.feature_enabled?(feature.symbol)
  end

  def test_feature_enabled_false_for_nil_feature
    assert !::Arturo.feature_enabled?(:not_found)
  end

  def test_to_feature_finds_global_feature
    assert_equal feature, ::Arturo::Feature.to_feature(feature)
    assert_equal feature, ::Arturo::Feature.to_feature(feature.symbol)
    assert_equal Arturo::GlobalFeature, feature.class
  end

  def test_enable_feature
    feature.enable!
    assert_equal 100, feature.deployment_percentage
    assert feature.enabled?, "Feature should be enabled"
  end

  def test_disable_feature
    feature.deployment_percentage == 100

    feature.disable!
    assert_equal 0, feature.deployment_percentage
    assert !feature.enabled?, "Feature should be disabled."
  end

  def test_global_feature_overrides_enabled_for
    feature.update_attribute(:deployment_percentage, 100)
    recipient = stub('User', :to_s => 'Paula', :id => 12)
    assert ::Arturo.feature_enabled_for?(feature.symbol, recipient), "#{feature} should be enabled for #{recipient}"

    feature.update_attribute(:deployment_percentage, 99)
    assert !::Arturo.feature_enabled_for?(feature.symbol, recipient), "#{feature} should not be enabled for #{recipient}"
  end

  def test_global_feature_enabled_only_for_full_engagement
    feature.update_attribute(:deployment_percentage, 22)
    assert !feature.enabled?

    feature.update_attribute(:deployment_percentage, 100)
    assert feature.enabled?
  end
end
