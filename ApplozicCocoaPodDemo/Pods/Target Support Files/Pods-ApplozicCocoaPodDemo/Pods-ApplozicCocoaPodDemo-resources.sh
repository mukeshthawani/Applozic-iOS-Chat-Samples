#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\""
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "Applozic/Applozic/Base.lproj/Applozic.storyboard"
  install_resource "Applozic/Applozic/Images.xcassets/AppIcon.appiconset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_about.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_attachment.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_attachment2.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_camera.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_message_delivered.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_message_sent.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_read.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_contact_picture_holo_light.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_map_no_data.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/location_filled.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/mobicom_social_forward.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/mobicom_social_reply.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/applozic_group_icon.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/attachments.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/audio_mic.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/bbb.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/beak3.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DELETEIOSX.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DLTT.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/documentReceive.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/documentSend.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/downloadI6.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DownloadiOS.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DTDT.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/itmusic1.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/online_show.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/Path.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/PAUSE.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/PhoneIcon.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/PLAY.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/playImage.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/Plus_PNG.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/SendButton20.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/TYMSGBG.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/uploadI1.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/UploadiOS2.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/VIDEO.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/applozic_edit.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/applozic_uploadCamera.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/ic_action_video.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/ic_phone_gray.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Contents.json"
  install_resource "Applozic/Applozic/TSMessagesDefaultDesign.json"
  install_resource "Applozic/Applozic/AppLozic.xcdatamodeld"
  install_resource "Applozic/Applozic/Base.lproj"
  install_resource "Applozic/Applozic/en.lproj"
  install_resource "Applozic/Applozic/hu.lproj"
  install_resource "Applozic/Applozic/Images.xcassets"
  install_resource "Applozic/Applozic/Resources/Base.lproj"
  install_resource "Applozic/Applozic/Resources/en.lproj"
  install_resource "Applozic/Applozic/Resources/Files/en.lproj"
  install_resource "Applozic/Applozic/Resources/hu.lproj"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "Applozic/Applozic/Base.lproj/Applozic.storyboard"
  install_resource "Applozic/Applozic/Images.xcassets/AppIcon.appiconset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_about.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_attachment.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_attachment2.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_camera.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_message_delivered.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_message_sent.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_action_read.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_contact_picture_holo_light.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/ic_map_no_data.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/location_filled.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/mobicom_social_forward.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image/mobicom_social_reply.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/applozic_group_icon.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/attachments.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/audio_mic.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/bbb.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/beak3.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DELETEIOSX.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DLTT.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/documentReceive.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/documentSend.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/downloadI6.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DownloadiOS.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/DTDT.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/itmusic1.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/online_show.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/Path.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/PAUSE.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/PhoneIcon.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/PLAY.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/playImage.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/Plus_PNG.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/SendButton20.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/TYMSGBG.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/uploadI1.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/UploadiOS2.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/applogic_image2/VIDEO.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/applozic_edit.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/applozic_uploadCamera.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/ic_action_video.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Applozic_img_store/ic_phone_gray.imageset/Contents.json"
  install_resource "Applozic/Applozic/Images.xcassets/Contents.json"
  install_resource "Applozic/Applozic/TSMessagesDefaultDesign.json"
  install_resource "Applozic/Applozic/AppLozic.xcdatamodeld"
  install_resource "Applozic/Applozic/Base.lproj"
  install_resource "Applozic/Applozic/en.lproj"
  install_resource "Applozic/Applozic/hu.lproj"
  install_resource "Applozic/Applozic/Images.xcassets"
  install_resource "Applozic/Applozic/Resources/Base.lproj"
  install_resource "Applozic/Applozic/Resources/en.lproj"
  install_resource "Applozic/Applozic/Resources/Files/en.lproj"
  install_resource "Applozic/Applozic/Resources/hu.lproj"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
