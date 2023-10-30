# CosmosLoginPrioritySDK-iOS
## 接入一键登录


添加source:
* source 'https://github.com/cosmos33/MMSpecs'

0.1.4 mob测试版:
* pod 'CosmosLoginPrioritySDK', :git => 'git@github.com:cosmos33/CosmosLoginPrioritySDK-iOS.git', :branch => 'dev'

0.1.3:
* pod 'CosmosLoginPrioritySDK'


## 代码接入 
## 初始化
```
    // 设置cosmosid
    CosmosOperatorLoginManager.initSDK("cosmos id")

    // 设置每一家运营商id
    CosmosOperatorLoginManager.registerAppId(BusinessConst.InhouseOneClickMobileAppID, appKey: BusinessConst.InhouseOneClickMobileAppKey, type: .mobile, encrypType: nil)

    // 是否使用mob登陆  
    CosmosOperatorLoginManager.setMobEnagle(true)


```

## 预登录
```
    func preLogin() {

        CosmosOperatorLoginManager.requestPreLogin(5) { [weak self] resultDic, error in
            guard let strongSelf = self else { return }
            DiscordOneClickLoginClient.hasCheck = true

            if error == nil {
                strongSelf.phoneNum = resultDic?["securityPhone"] as? String ?? ""
                strongSelf.source = resultDic?["source"] as? String ?? ""
                DiscordOneClickLoginClient.isPrelogin = true
            } else {
                DiscordOneClickLoginClient.isPrelogin = false
            }
            DispatchQueue.main.async {
                strongSelf.preLoginFinishHandler?()
                strongSelf.preLoginFinishHandler = nil
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.preLoginFinishHandler?()
            self.preLoginFinishHandler = nil
        }
    }
```

## 登陆验证
```
    func startAuth(completionHandler: ((AuthStyle, String?) -> Void)?) {
        self.authHandler = completionHandler
        let viewController = MMChannelManager.visibleNavigationController()?.visibleViewController ?? UIViewController()
        let vc = DiscordOneClickedLoginViewController()
        vc.phoneNum = self.phoneNum
        vc.source = self.source ?? ""
        vc.goAuthHandler = {
            CosmosOperatorLoginManager.getAuthorizationCompletion { [weak self] resultDic, error in
                guard let strongSelf = self else { return }
                if error == nil, let result = resultDic?.jsonString {
                    strongSelf.authHandler?(.mobile, result)
                    vc.dismiss(animated: true)
                } else {
                    toast(title: "操作失败，请使用默认登录")
                    vc.dismiss(animated: true)
                }
            }
        }
        viewController.present(vc, animated: true)
    }

```



