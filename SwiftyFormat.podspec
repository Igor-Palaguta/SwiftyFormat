Pod::Spec.new do |s|
  s.name             = 'SwiftyFormat'
  s.version          = '0.2.0'
  s.summary          = 'String and NSAttributedString with format'

  s.description      = <<-DESC
Provides simple and customizable way for formatting strings and attributed strings.
                       DESC

  s.homepage         = 'https://github.com/Igor-Palaguta/SwiftyFormat'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Igor Palaguta' => 'igor.palaguta@gmail.com' }
  s.source           = { :git => 'https://github.com/Igor-Palaguta/SwiftyFormat.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/igor_palaguta'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/*.swift'
end
