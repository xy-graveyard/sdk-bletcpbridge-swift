pod trunk register arie.trouw@xyo.network 'XYO Team' --description='Deploy Script'
pod lib lint
pod --allow-warnings trunk push sdk-bletcpbridge-swift.podspec
