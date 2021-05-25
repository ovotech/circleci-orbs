
SERVICE_NAME="<< parameters.serviceName >>"
IS_LIB="<< parameters.save_libs >>"

mkdir -p ~/test-results/junit/
find . -type f -regex ".*/build/test-results/.*xml" -exec cp {} ~/test-results/junit/ \;
mkdir -p ./reports/jacoco/
mkdir -p ./reports/jacoco/"$SERVICE_NAME"/
rm -rf ./reports/jacoco/

REPORT_FOLDER=""
if [[ "$IS_LIB" = true ]] ; then
  REPORT_FOLDER="libs/$SERVICE_NAME/build/jacoco-reports/test"
else
  REPORT_FOLDER="$SERVICE_NAME/build/jacoco-reports/test"
fi


if [ -e "$REPORT_FOLDER"/jacocoTestReport.csv ]; then
  mv "$REPORT_FOLDER"/jacocoTestReport.csv ./reports/jacoco/"$SERVICE_NAME".csv
  mv "$REPORT_FOLDER"/* ./reports/jacoco/"$SERVICE_NAME"
else
   echo file does not exist or is not executable
fi
