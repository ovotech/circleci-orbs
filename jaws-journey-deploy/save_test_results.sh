SERVICE_NAME="<< parameters.serviceName >>"
IS_LIB=true
mkdir -p ~/test-results/junit/
find . -type f -regex ".*/build/test-results/.*xml" -exec cp {} ~/test-results/junit/ \;

mkdir -p ./reports/jacoco/"$SERVICE_NAME"/
mv "$SERVICE_NAME"/build/jacoco-reports/test/jacocoTestReport.csv ./reports/jacoco/"$SERVICE_NAME".csv
mv "$SERVICE_NAME"/build/jacoco-reports/test/* ./reports/jacoco/"$SERVICE_NAME"

if [[ "$IS_LIB" = true ]] ; then
  for proj in $(find . -type f -regex "./libs/.*/build/jacoco-reports/test/jacocoTestReport.csv" | cut -d/ -f3); do
    mkdir -p ./reports/jacoco/"$proj"/
    mv libs/"$proj"/build/jacoco-reports/test/jacocoTestReport.csv ./reports/jacoco/"$proj".csv
    mv libs/"$proj"/build/jacoco-reports/test/* ./reports/jacoco/"$proj"
  done
fi
