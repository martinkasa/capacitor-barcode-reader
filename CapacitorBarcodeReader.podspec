
  Pod::Spec.new do |s|
    s.name = 'CapacitorBarcodeReader'
    s.version = '0.0.1'
    s.summary = 'Capacitor barcode reader plugin'
    s.license = 'MIT'
    s.homepage = 'https://github.com/martinkasa/capacitor-barcode-reader'
    s.author = 'Martin Kasa'
    s.source = { :git => 'https://github.com/martinkasa/capacitor-barcode-reader', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end