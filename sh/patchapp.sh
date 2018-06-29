BUNDLEIDENTIFIER=com.neo.SingleEmpty
ORIGINAL_IPA=./app/wx661.ipa
LIBNAME=WeChatRedEnvelop.dylib
LIBSUBSTRATE=libsubstrate.dylib
#TEMPDIR=$(mktemp -d)
TEMPDIR=./result/
APP_PATH=$(pwd)
TOOL=$APP_PATH/tool
LIB_PATH=../.theos/obj/debug/

# 1.unzip ipa

unzip -qo ${ORIGINAL_IPA} -d $TEMPDIR

# 2.copy files
cp ./embedded.mobileprovision $TEMPDIR/
cp ./entitlements.plist $TEMPDIR/
cp $LIB_PATH/${LIBNAME} $TEMPDIR/
cp $TOOL/${LIBSUBSTRATE} $TEMPDIR/

# 3.resign
cd $TEMPDIR
#plutil -replace application-identifier -string ${APPLICATIONIDENTIFIER} entitlements.plist
plutil -replace CFBundleIdentifier -string ${BUNDLEIDENTIFIER} Payload/WeChat.app/Info.plist

mv ${LIBNAME} Payload/WeChat.app/
mv ${LIBSUBSTRATE} Payload/WeChat.app/

#insert_dylib --all-yes @executable_path/${LIBNAME} Payload/WeChat.app/WeChat
$TOOL/yololib Payload/WeChat.app/WeChat ${LIBNAME}
#mv Payload/WeChat.app/WeChat_patched Payload/WeChat.app/WeChat
chmod +x Payload/WeChat.app/WeChat

rm -rf Payload/WeChat.app/_CodeSignature
rm -rf Payload/WeChat.app/PlugIns
rm -rf Payload/WeChat.app/Watch
cp embedded.mobileprovision Payload/WeChat.app/
codesign -fs "iPhone Developer: ineo6@qq.com (VE5R5X5W42)" --no-strict --entitlements=entitlements.plist Payload/WeChat.app/${LIBNAME}
codesign -fs "iPhone Developer: ineo6@qq.com (VE5R5X5W42)" --no-strict --entitlements=entitlements.plist Payload/WeChat.app/${LIBSUBSTRATE}

# framework
codesign -fs "iPhone Developer: ineo6@qq.com (VE5R5X5W42)" --no-strict --entitlements=entitlements.plist Payload/WeChat.app/Frameworks/mars.framework
codesign -fs "iPhone Developer: ineo6@qq.com (VE5R5X5W42)" --no-strict --entitlements=entitlements.plist Payload/WeChat.app/Frameworks/MMCommon.framework
codesign -fs "iPhone Developer: ineo6@qq.com (VE5R5X5W42)" --no-strict --entitlements=entitlements.plist Payload/WeChat.app/Frameworks/MultiMedia.framework
codesign -fs "iPhone Developer: ineo6@qq.com (VE5R5X5W42)" --no-strict --entitlements=entitlements.plist Payload/WeChat.app/Frameworks/WCDB.framework

codesign -fs "iPhone Developer: ineo6@qq.com (VE5R5X5W42)" --no-strict --entitlements=entitlements.plist Payload/WeChat.app



# 4.end

#mv Payload/WeChat.app ${RESULT}
# zip -r $APP_PATH/wechat.ipa Payload/

# rm -rf ${TEMPDIR}

ios-deploy --debug --bundle Payload/WeChat.app
