//
//  QHUtil.swift
//  swift_project
//
//  Created by 高庆华 on 2018/4/2.
//  Copyright © 2018年 高庆华. All rights reserved.
//

import Kingfisher
import Photos
import SVProgressHUD
import UIKit

enum DirectionType {
    case up
    case left
    case down
    case right
}

class QHUtil: NSObject {
    static let share = QHUtil()

    var keyboardIsVisible: Bool = false

    override init() {
        super.init()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    @objc func keyboardDidShow() {
        keyboardIsVisible = true
    }

    @objc func keyboardDidHide() {
        keyboardIsVisible = false
    }

    

    // MARK: 存入偏好设置

    class func SET_USER_DEFAULTS(Key key: String, Value value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    // MARK: 取偏好设置

    class func GET_USER_DEFAULTS(Key key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key) ?? ""
    }

    // MARK: 打电话

    class func callTelNumber(number: String?) {
        guard let _ = number else { return }
        let string = "tel:\(number!)"
        if let url = URL(string: string) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    // MARK: 使用‘*’隐藏部分信息

    /// prefixLength：前面几位不隐藏  suffixLength：后面几位不隐藏
    class func hiddenInfoWithAsterisk(_ originString: String, _ prefixLength: Int, _ suffixLength: Int) -> String {
        if prefixLength + suffixLength >= originString.count {
            return originString
        }
        let preString = originString.prefix(prefixLength)
        let sufString = originString.suffix(suffixLength)
        var hiddenString = ""
        let starCount = originString.count - prefixLength - suffixLength
        for _ in 0 ..< starCount {
            hiddenString.append("*")
        }
        return preString + hiddenString + sufString
    }

    // MARK: 保留几位小数

    class func getDigitsNumberAfterDecimalPoint(digitsNumber: Int, sourceString: Any, roundingMode: NSDecimalNumber.RoundingMode) -> String {
        let sourceStrFormat = "\(sourceString)"
        guard sourceStrFormat.contains(".") else { return sourceStrFormat }

        guard let decimalPart = sourceStrFormat.components(separatedBy: ".").last else { return sourceStrFormat }
        if decimalPart.count < digitsNumber {
            return sourceStrFormat
        } else {
            let roundingBehavior = NSDecimalNumberHandler(roundingMode: roundingMode, scale: Int16(digitsNumber), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
            let ouncesDecimal = NSDecimalNumber(value: Double(sourceStrFormat) ?? 0)
            let roundedOunces = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
            return "\(roundedOunces)"
        }
    }
    // MARK: 保留0-x位小数，默认2位，1.069->1.07 1.06->1.06 1.50->1.5 1.000->1
    class func getNumberString(afterPoint count: Int = 2, number: Double, numberStyle: NumberFormatter.Style = .decimal) -> String?{
        let formatter = NumberFormatter()
        formatter.numberStyle = numberStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = count
        if let result = formatter.string(from: NSNumber(value: number)) {
            if result.hasPrefix(".") {
                return "0" + result
            }else {
                return result
            }
        }else {
            return nil
        }

    }
    // MARK: MD5加密

    class func md5(Str str: String) -> String {
        let cStr = str.cString(using: String.Encoding.utf8)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!, (CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString()
        for i in 0 ..< 16 {
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }

    // MARK: base64加密

    class func encodingBase64(String str: String) -> String {
        let data = str.data(using: String.Encoding.utf8)
        return (data?.base64EncodedString(options: .lineLength64Characters))!
    }

    // MARK: 将当前时间转换成毫秒时间

    class func changeNowDateToTimeStamp() -> Int {
        return Int(Date().timeIntervalSince1970)
    }

    // MARK: 根据给定颜色返回一张纯色图片

    class func createImageFrom(Color color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    // MARK: 根据给定颜色、尺寸、方向渐变的图层，至少两种颜色

    class func createGradientLayerWithFrame(frame: CGRect, colors: Array<UIColor>, direction: DirectionType) -> CALayer {
        let gradient = CAGradientLayer()
        switch direction {
        case .up:
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
        case .left:
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)
        case .down:
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 0, y: 0)
        case .right:
            gradient.startPoint = CGPoint(x: 1, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 0)
        }
        var mColors: Array<CGColor> = []
        for color in colors {
            mColors.append(color.cgColor)
        }
        gradient.colors = mColors
        gradient.frame = frame

        return gradient
    }

    // MARK: 全屏截图

    class func shotScreen() -> UIImage? {
        let window = UIApplication.shared.keyWindow
        guard let _ = window else { return nil }
        UIGraphicsBeginImageContext(window!.bounds.size)
        window!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    

    // MARK: 获取图片缓存的大小

    class func getImageCacheSize(_ block: @escaping (String) -> Void) {
        ImageCache.default.calculateDiskStorageSize { result in
            switch result {
            case let .success(size):
                var dataSize: String {
                    return "\(size / (1024 * 1024)) M"
//                    guard size >= 1024 else { return "\(size) bytes" }
//                    guard size >= 1024*1024 else { return "\(size/1024) KB" }
//                    guard size >= 1024*1024*1024 else { return "\(size/(1024*1024)) MB" }
//                    return "\(size / (1024*1024*1024)) GB"
                }
                block(dataSize)
            case let .failure(error):
                log.debug("获取图片缓存错误：\(error.localizedDescription)")
            }
        }
    }

    class func clearImageCache(_ block: @escaping () -> Void) {
        ImageCache.default.clearDiskCache {
            block()
        }
    }

    // MARK: 提示

    class func showSuccessHud(status: String?) {
        DispatchQueue.main.async {
            SVProgressHUD.showSuccess(withStatus: status)
        }
    }

    class func showInfoHud(status: String?) {
        DispatchQueue.main.async {
            SVProgressHUD.showInfo(withStatus: status)
        }
    }

    class func showErrorHud(status: String?) {
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: status)
        }
    }

    class func showHud(status: String? = nil) {
        if let text = status, !text.isEmpty {
            DispatchQueue.main.async {
                SVProgressHUD.show(withStatus: text)
            }
        } else {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
    }

    class func showProgress(progress: Float, status: String?) {
        SVProgressHUD.showProgress(progress, status: status)
    }

    class func hideHud() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }

    // MARK: 富文本

    class func changeToAttributeStringWith(String string: String, IndexOfString index: Int, LengthOfString length: Int, StringFont font: UIFont, StringColor color: UIColor) -> NSMutableAttributedString {
        let attriString = NSMutableAttributedString(string: string)
        attriString.addAttribute(.font, value: font, range: NSMakeRange(index, length))
        attriString.addAttribute(.foregroundColor, value: color, range: NSMakeRange(index, length))
        return attriString
    }

    class func stringToPinyin(string: String) -> String {
        var mutableString = NSMutableString(string: string)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)

        mutableString = NSMutableString(string: mutableString.folding(options: .diacriticInsensitive, locale: Locale.current))
        mutableString = NSMutableString(string: mutableString.replacingOccurrences(of: " ", with: ""))
        return mutableString.lowercased
    }

    // MARK: 图片处理

    class func compressOriginalImage(image: UIImage, toLength: Int, completion: @escaping (Data) -> Void) {
        DispatchQueue.global().async {
            var scale = 0.9
            var scaleData = image.jpegData(compressionQuality: CGFloat(scale))
            while scaleData!.count > toLength {
                scale -= 0.1
                if scale < 0 {
                    break
                }
                scaleData = image.jpegData(compressionQuality: CGFloat(scale))!
            }

            DispatchQueue.main.async {
                completion(scaleData!)
            }
        }
    }

    class func downLoadImage(imageUrl: String, completion: ((String) -> Void)? = nil) {
        ImageDownloader.default.downloadImage(with: URL(string: imageUrl)!, options: nil) { result in
            switch result {
            case let .success(result):
                saveImageToLocal(image: result.image) { string in
                    if let block = completion {
                        block(string)
                    }
                }
            case .failure:
                showErrorHud(status: "图片下载失败")
            }
        }
    }

    class func writeImageToLocal(image: UIImage?, completion: ((String) -> Void)? = nil) {
        var imgIds = [String]()
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest.creationRequestForAsset(from: image!)
            imgIds.append(req.placeholderForCreatedAsset!.localIdentifier)
        }) { success, error in
            DispatchQueue.main.async {
                if error != nil {
                    QHUtil.showErrorHud(status: "保存失败")
                } else {
                    QHUtil.showSuccessHud(status: "保存成功")
                }
            }
            if success {
                var imageAsset: PHAsset?
                let result = PHAsset.fetchAssets(withLocalIdentifiers: imgIds, options: nil)
                result.enumerateObjects { obj, _, _ in
                    imageAsset = obj
                }
                if let asset = imageAsset {
                    if let block = completion {
                        block(asset.localIdentifier)
                    }
                }
            }
        }
    }

    /// completion：保存完图片 有个localIdentifier
    class func saveImageToLocal(image: UIImage?, completion: ((String) -> Void)? = nil) {
        guard let image = image else {
            QHUtil.showInfoHud(status: "请保存正确的图片")
            return
        }
        guard image.isKind(of: UIImage.self) else {
            QHUtil.showInfoHud(status: "请保存正确的图片")
            return
        }
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        if authorizationStatus == .authorized {
            writeImageToLocal(image: image, completion: completion)
        } else if authorizationStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    writeImageToLocal(image: image, completion: completion)
                } else {
                    (QHUtil.getCurrentVC() as! BaseVC).presentAlertControllerWith(Title: "提示", Message: "请在\"设置 - 隐私 - 照片\"选项中，允许鑫案场访问您的照片", CancelTitle: "取消", ConfirmTitle: "确定") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        } else {
            SVProgressHUD.dismiss()
            if let currentVC = QHUtil.getCurrentVC() as? BaseVC {
                currentVC.presentAlertControllerWith(Title: "提示", Message: "请在\"设置 - 隐私 - 照片\"选项中，允许鑫案场访问您的照片", CancelTitle: "取消", ConfirmTitle: "确定") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }

//
//
//    //MARK: 字典转模型
//    class func model(With dictionary:[String:Any]? , model:NSObject) -> NSObject{
//        guard let dict = dictionary else { return NSObject() }
//        model.setValuesForKeys(dict)
//        return model
//    }

    // MARK: - Json相关

    class func jsonToDictionary(json: String?) -> [String: Any] {
        if let json = json {
            if let jsonData = json.data(using: .utf8) {
                if let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                    return dic
                } else {
                    return [String: Any]()
                }
            } else {
                return [String: Any]()
            }
        } else {
            return [String: Any]()
        }
    }

    
    // MARK: - 其他

    class func makeTag(string: String?) -> String {
        if let s = string {
            return " " + s + " "
        }
        return ""
        
    }

    // MARK: 判断图片地址是不是绝对路径

    class func checkImageString(imageUrl: String) -> String {
        if imageUrl.hasPrefix("http") {
            return imageUrl
        } else {
            return IMAGEHOST + imageUrl
        }
    }

    // MARK: 修改html样式

    class func configHTMLStyle(html: String) -> String {
        return "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'><meta name='apple-mobile-web-app-capable' content='yes'><meta name='apple-mobile-web-app-status-bar-style' content='black'><meta name='format-detection' content='telephone=no'><style type='text/css'>img{width:100%} p{font-size:12px;color:#666666}</style>\(html)"
    }

    // MARK: 当前控制器

    class func getCurrentVC() -> UIViewController {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != .normal {
            let windows = UIApplication.shared.windows
            for tempwin in windows {
                if tempwin.windowLevel == .normal {
                    window = tempwin
                    break
                }
            }
        }
        if (window?.rootViewController?.isKind(of: UITabBarController.self))! {
            let tabbarViewCtrl = window?.rootViewController as! UITabBarController as UITabBarController
            if (tabbarViewCtrl.selectedViewController?.isKind(of: UINavigationController.self))! {
                let navigationViewCtrl = tabbarViewCtrl.selectedViewController as! UINavigationController
                return navigationViewCtrl.visibleViewController!
            } else {
                return tabbarViewCtrl.selectedViewController!
            }
        } else if (window?.rootViewController?.isKind(of: UINavigationController.self))! {
            let navigationViewCtrl = window?.rootViewController as! UINavigationController
            return navigationViewCtrl.visibleViewController!
        } else {
            return (window?.rootViewController)!
        }
    }

    // MARK: 是否是ipad

    class func isIpad() -> Bool {
        let deviceType = UIDevice.current.model
        if deviceType == "iPad" {
            return true
        }
        return false
    }

    // MARK: 是不是所有子元素都是空
    class func elementsEmpty(array: Array<Any>) -> Bool {
        if array.count == 0 {
            return true
        }
        for datas in array {
            if datas is Array<Any> {
                if !elementsEmpty(array: datas as! Array<Any>) {
                    return false
                }
            }else {
                return false
            }
        }
        return true
    }
}
// MARK: - 字符串判断
extension QHUtil {
    // MARK: 判断手机号码合法性

    class func isValid(MobilePhone phone: String?) -> Bool {
        guard let _ = phone else {
            return false
        }
        if phone!.count != 11 {
            return false
        }

        let mobile = "^1[3|4|5|6|7|8|9]\\d{9}$"
        let regextestMoblie = NSPredicate(format: "SELF MATCHES %@", mobile)
        return regextestMoblie.evaluate(with: phone)
    }

    // MARK: 是否合法密码

    class func isValid(Password password: String?) -> Bool {
        guard let _ = password else {
            return false
        }
        let pattern = "^[A-Za-z0-9_]{6,16}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: password)
    }

    // MARK: 判断邮箱格式

    class func isValid(Email email: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

    // MARK: 判断身份证号

    class func isValid(IdentityNumber number: String) -> Bool {
        // 判断位数
        if number.count != 15 && number.count != 18 {
            return false
        }
        var carid = number
        var lSumQT = 0
        // 加权因子
        let R = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        // 校验码
        let sChecker: [Int8] = [49, 48, 88, 57, 56, 55, 54, 53, 52, 51, 50]
        // 将15位身份证号转换成18位
        let mString = NSMutableString(string: number)

        if number.count == 15 {
            mString.insert("19", at: 6)
            var p = 0
            let pid = mString.utf8String
            for i in 0 ... 16 {
                let t = Int(pid![i])
                p += (t - 48) * R[i]
            }
            let o = p % 11
            let stringContent = NSString(format: "%c", sChecker[o])
            mString.insert(stringContent as String, at: mString.length)
            carid = mString as String
        }

        let cStartIndex = carid.startIndex
        let cEndIndex = carid.endIndex
        let index = carid.index(cStartIndex, offsetBy: 2)
        // 判断地区码
        let sProvince = String(carid[cStartIndex ..< index])
        if !areaCodeAt(sProvince) {
            return false
        }

        // 判断年月日是否有效
        // 年份
        let yStartIndex = carid.index(cStartIndex, offsetBy: 6)
        let yEndIndex = carid.index(yStartIndex, offsetBy: 4)
        let strYear = Int(carid[yStartIndex ..< yEndIndex])

        // 月份
        let mStartIndex = carid.index(yEndIndex, offsetBy: 0)
        let mEndIndex = carid.index(mStartIndex, offsetBy: 2)
        let strMonth = Int(carid[mStartIndex ..< mEndIndex])

        // 日
        let dStartIndex = carid.index(mEndIndex, offsetBy: 0)
        let dEndIndex = carid.index(dStartIndex, offsetBy: 2)
        let strDay = Int(carid[dStartIndex ..< dEndIndex])

        let localZone = NSTimeZone.local

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = localZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let date = dateFormatter.date(from: "\(String(format: "%02d", strYear!))-\(String(format: "%02d", strMonth!))-\(String(format: "%02d", strDay!)) 12:01:01")
        if date == nil {
            return false
        }
        let paperId = carid.utf8CString
        // 检验长度
        if 18 != carid.count {
            return false
        }
        // 校验数字
        func isDigit(c: Int) -> Bool {
            return 0 <= c && c <= 9
        }
        for i in 0 ... 18 {
            let id = Int(paperId[i])
            if isDigit(c: id) && !(88 == id || 120 == id) && 17 == i {
                return false
            }
        }
        // 验证最末的校验码
        for i in 0 ... 16 {
            let v = Int(paperId[i])
            lSumQT += (v - 48) * R[i]
        }
        if sChecker[lSumQT % 11] != paperId[17] {
            return false
        }
        return true
    }

    class func areaCodeAt(_ code: String) -> Bool {
        var dic: [String: String] = [:]
        dic["11"] = "北京"
        dic["12"] = "天津"
        dic["13"] = "河北"
        dic["14"] = "山西"
        dic["15"] = "内蒙古"
        dic["21"] = "辽宁"
        dic["22"] = "吉林"
        dic["23"] = "黑龙江"
        dic["31"] = "上海"
        dic["32"] = "江苏"
        dic["33"] = "浙江"
        dic["34"] = "安徽"
        dic["35"] = "福建"
        dic["36"] = "江西"
        dic["37"] = "山东"
        dic["41"] = "河南"
        dic["42"] = "湖北"
        dic["43"] = "湖南"
        dic["44"] = "广东"
        dic["45"] = "广西"
        dic["46"] = "海南"
        dic["50"] = "重庆"
        dic["51"] = "四川"
        dic["52"] = "贵州"
        dic["53"] = "云南"
        dic["54"] = "西藏"
        dic["61"] = "陕西"
        dic["62"] = "甘肃"
        dic["63"] = "青海"
        dic["64"] = "宁夏"
        dic["65"] = "新疆"
        dic["71"] = "台湾"
        dic["81"] = "香港"
        dic["82"] = "澳门"
        dic["91"] = "国外"
        if dic[code] == nil {
            return false
        }
        return true
    }

    // MARK: 判断身份证号

    class func isValid(BankCard cardNumber: String?) -> Bool {
        var oddSum: Int = 0 // 奇数和
        var evenSum: Int = 0 // 偶数和
        var allSum: Int = 0 // 总和
        guard let _ = cardNumber else { return false }
        guard !cardNumber!.isEmpty else { return false }
        // 循环加和
        for i in 1 ... (cardNumber!.count) {
            guard let theNumber = (cardNumber as NSString?)?.substring(with: NSRange(location: (cardNumber?.count ?? 0) - i, length: 1)) else { return false }
            guard let theNumberInt = Int(theNumber) else { return false }
            var lastNumber = Int(truncating: NSNumber(value: theNumberInt))
            if i % 2 == 0 {
                // 偶数位
                lastNumber *= 2
                if lastNumber > 9 {
                    lastNumber -= 9
                }
                evenSum += lastNumber
            } else {
                // 奇数位
                oddSum += lastNumber
            }
        }
        allSum = oddSum + evenSum
        // 是否合法
        if allSum % 10 == 0 {
            return true
        } else {
            return false
        }
    }

    // MARK: 判断字符串中是否全是汉字

    class func isAllChineseInString(string: String) -> Bool {
        for (_, value) in string.enumerated() {
            if "\u{4E00}" > value || value > "\u{9FA5}" {
                return false
            }
        }
        return true
    }

    // MARK: 判断是否为整型

    class func isPureInteger(string: String?) -> Bool {
        guard let str = string else { return false }
        let scanner = Scanner(string: str)
        var val: Int = 0
        return scanner.scanInt(&val) && scanner.isAtEnd
    }

    // MARK: 判断字符串条件 1:数字 2:英文 3:符合的英文+数字

    class func isHaveNumAndLetter(String string: String) -> Int {
        do {
            let tNumRegularExpression = try NSRegularExpression(pattern: "[0-9]", options: .caseInsensitive)
            let tNumMatchCount: Int = tNumRegularExpression.numberOfMatches(in: string, options: .reportProgress, range: NSMakeRange(0, string.count))

            let tLetterRegularExpression = try NSRegularExpression(pattern: "[A-Za-z]", options: .caseInsensitive)
            let tLetterMatchCount: Int = tLetterRegularExpression.numberOfMatches(in: string, options: .reportProgress, range: NSMakeRange(0, string.count))

            if tNumMatchCount == string.count {
                return 1
            } else if tLetterMatchCount == string.count {
                return 2
            } else if tNumMatchCount + tLetterMatchCount == string.count {
                return 3
            } else {
                return 4
            }
        } catch { return 0 }
    }

    // MARK: 判断字符串是否存在

    class func isBlankString(String string: String?) -> String {
        if nil == string {
            return ""
        }

        return string!
    }
}
// MARK: - 工厂
extension QHUtil {
    // MARK: 创建label

    class func createLabelWith(Text text: String?, Frame frame: CGRect, TextColor textColor: UIColor?, Font font: UIFont?, TextAligtment textAlightment: NSTextAlignment?) -> UILabel {
        let label = UILabel(frame: frame)
        if textColor != nil {
            label.textColor = textColor
        }
        if text != nil {
            label.text = text
        }
        if font != nil {
            label.font = font
        }
        if textAlightment != nil {
            label.textAlignment = textAlightment!
        }
        return label
    }

    // MARK: 创建button

    class func createButtonWith(Title title: String?, ImageName imageName: String?, Frame frame: CGRect, TitleColor titleColor: UIColor?, Font font: UIFont?, BackgroundColor backgroundColor: UIColor?, Target target: Any?, Action action: Selector?, TextAligtment textAlightment: NSTextAlignment?) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        if title != nil {
            button.setTitle(title, for: .normal)
        }
        if imageName != nil {
            button.setImage(UIImage(named: imageName!), for: .normal)
        }
        if backgroundColor != nil {
            button.backgroundColor = backgroundColor
        }
        if titleColor != nil {
            button.setTitleColor(titleColor, for: .normal)
        }
        if font != nil {
            button.titleLabel?.font = font
        }
        if target != nil && action != nil {
            button.addTarget(target, action: action!, for: .touchUpInside)
        }
        if textAlightment != nil {
            button.titleLabel?.textAlignment = textAlightment!
        }
        return button
    }

    // MARK: 创建通用的button

    class func createCommonButton(_ title: String?, frame: CGRect, target: Any?, action: Selector?) -> UIButton {
        let button = createButtonWith(Title: title, ImageName: nil, Frame: frame, TitleColor: .white, Font: FONT(16), BackgroundColor: MAIN_BLUE_COLOR, Target: target, Action: action, TextAligtment: nil)
        button.layer.cornerRadius = 4 * H_multiple
        button.layer.masksToBounds = true
        return button
    }

    // MARK: 创建输入框

    class func createTextFieldWith(Frame frame: CGRect, BoardStyle boardStyle: UITextField.BorderStyle, PlaceHolder placeHolder: String?, BackgroundColor backgroundColor: UIColor?, TextColor textColor: UIColor?, IsPWD isPwd: Bool) -> UITextField {
        let textField = UITextField(frame: frame)
        textField.borderStyle = boardStyle
        if placeHolder != nil {
            textField.placeholder = placeHolder
        }
        if backgroundColor != nil {
            textField.backgroundColor = backgroundColor
        }
        if textColor != nil {
            textField.textColor = textColor
        }
        textField.clearButtonMode = .always
        if isPwd {
            textField.isSecureTextEntry = true
        }
        return textField
    }

    // MARK: 创建图片

    class func createImageViewWith(Frame frame: CGRect, ImageName imageName: String, CornarRadius radius: Float) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.image = UIImage(named: imageName)
        imageView.layer.cornerRadius = CGFloat(radius)
        return imageView
    }

    // MARK: 创建view

    class func createViewWith(Frame frame: CGRect, BackgroundColor backgroundColor: UIColor?) -> UIView {
        let view = UIView(frame: frame)
        if backgroundColor != nil {
            view.backgroundColor = backgroundColor
        }
        return view
    }
}
// MARK: - Date相关
extension QHUtil {
    //MARK: 日期转字符串
    class func dateToString(date: Date, formatter: String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = NSTimeZone.local
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    //MARK:  字符串转日期
    class func stringToDate(string: String, formatter: String? = "yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = formatter
        let date = dateFormatter.date(from: string)
        return date!
    }

    //MARK:  字符串转字符串  useMillisecond是否含毫秒
    class func fullDateStringToYMDDateString(fullString: String, fullFormatter: String = "yyyy-MM-dd HH:mm:ss", formatter: String = "yyyy-MM-dd", useMillisecond: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        if useMillisecond {
            dateFormatter.dateFormat = fullFormatter + ".SSS"
        } else {
            dateFormatter.dateFormat = fullFormatter
        }
        if let date = dateFormatter.date(from: fullString) {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = formatter

            let dateString = dateFormatter2.string(from: date)
            return dateString
        }
        return "无"
    }

}
