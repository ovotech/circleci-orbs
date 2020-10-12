SERVICE_NAME="<< parameters.serviceName >>"
mkdir -p ~/test-results/junit/
find . -type f -regex ".*/build/test-results/.*xml" -exec cp {} ~/test-results/junit/ \;
mkdir -p ~/reports/jacoco/
find . -type f -regex ".*/build/jacoco-reports/test/.*xml" -exec cp {} ~/reports/jacoco \;
cp -r ${SERVICE_NAME}/build/jacoco-reports/html ~/reports/jacoco