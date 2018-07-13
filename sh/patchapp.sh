BUNDLEIDENTIFIER=com.neo.SingleEmpty
ORIGINAL_IPA=./app/wx661.ipa
LIBNAME=WeChatRedEnvelop.dylib
LIBSUBSTRATE=libsubstrate.dylib

workspace=./result

APP_PATH=$(pwd)
TOOL=$APP_PATH/tool
LIB_PATH=../.theos/obj/debug/

payloadDirectory=${workspace}/Payload
entitlementsPlistPath=${workspace}/entitlements.plist

appName=WeChat.app

user='iPhone Developer: ineo6@qq.com (VE5R5X5W42)'

appBundlePath=${payloadDirectory}/${appName}
appBundleInfoPlist=${appBundlePath}/Info.plist
appBundleProvisioningFilePath=${appBundlePath}/embedded.mobileprovision

function blue(){
    echo "\033[34m[ $1 ]\033[0m"
}


#rm -rf payloadDirectory
#mkdir payloadDirectory

# 1.unzip ipa
blue '解压ipa'
unzip -qo ${ORIGINAL_IPA} -d $workspace

# 将新的embedded.mobileprovision复制到app中
blue '生成 entitlements.plist'
cp ./embedded.mobileprovision $appBundleProvisioningFilePath
# cp ./entitlements.plist $workspace/

#解析新的embedded.mobileprovision
security cms -D -i $appBundleProvisioningFilePath > ${workspace}/t_entitlements_full.plist 
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' ${workspace}/t_entitlements_full.plist > ${entitlementsPlistPath}

# 复制tweak dylib以及libsubstrate
blue '复制tweak和libsubstrate'
cp $LIB_PATH/${LIBNAME} $appBundlePath/
cp $TOOL/${LIBSUBSTRATE} $appBundlePath/

# 3.resign

blue '开始签名'
#plutil -replace application-identifier -string ${APPLICATIONIDENTIFIER} entitlements.plist
plutil -replace CFBundleIdentifier -string ${BUNDLEIDENTIFIER} $appBundleInfoPlist

#insert_dylib --all-yes @executable_path/${LIBNAME} Payload/WeChat.app/WeChat
$TOOL/yololib $appBundlePath$/{LIBNAME}

#确保文件可执行
chmod +x $appBundlePath

# 删除存在的签名文件，以及无法签名项
rm -rf $appBundlePath/_CodeSignature
rm -rf $appBundlePath/PlugIns
rm -rf $appBundlePath/Watch

# 签名
codesign -fs "$user" --no-strict --entitlements=${entitlementsPlistPath} $appBundlePath/${LIBNAME}
codesign -fs "$user" --no-strict --entitlements=${entitlementsPlistPath} $appBundlePath/${LIBSUBSTRATE}

# framework 签名
for file in `ls $appBundlePath/Frameworks` 
do
     codesign -vvv -fs "$user" --no-strict --entitlements=${entitlementsPlistPath} $appBundlePath/Frameworks/$file
done

codesign -fs "$user" --no-strict --entitlements=${entitlementsPlistPath} $appBundlePath

blue '签名结束'

# 4.end

#mv Payload/WeChat.app ${RESULT}
# zip -r $APP_PATH/wechat.ipa Payload/

# rm -rf ${workspace}

ios-deploy --debug --bundle $appBundlePath
