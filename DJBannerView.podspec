Pod::Spec.new do |s|
  s.name        = 'DJBannerView'
  s.version     = '1.0'
  s.authors     = { 'Dennis Deng' => 'iunion@live.cn' }
  s.homepage    = 'https://github.com/iunion/DJBannerView'
  s.summary     = 'A ViewPager that can scroll automatically.'
  s.source      = { :git => 'https://github.com/iunion/DJBannerView.git', :tag => s.version.to_s }
  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.platform = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'DJBannerView'
  s.public_header_files = 'DJBannerView/*.h'
  s.resources = ['DJBannerView/Images/*.png']

  s.ios.deployment_target = '7.0'

  s.dependency 'SDWebImage', '~> 4.0.0'
end
