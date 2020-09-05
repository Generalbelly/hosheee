#! /bin/bash

if [[ $APP_ENV == *"dev"* ]]; then
  cp $PRODUCT_NAME/GoogleService-Info-Dev.plist $PRODUCT_NAME/GoogleService-Info.plist
elif [[ $APP_ENV == *"prod"* ]]; then
  cp $PRODUCT_NAME/GoogleService-Info-Prod.plist $PRODUCT_NAME/GoogleService-Info.plist
else
  echo "configuration didn't match any of the followings; dev, prod."
  echo $APP_ENV
  exit 1
fi
