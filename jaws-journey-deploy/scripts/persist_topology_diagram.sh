mkdir -p ~/test-results/junit/

DIAGRAM_FOLDER=~/test-results/junit/

mkdir -p ./reports/diagrams/

if [ -e "$DIAGRAM_FOLDER"/journeyCotTopologyDiagram.png ]; then
  mv "$DIAGRAM_FOLDER"/journeyCotTopologyDiagram.png ./reports/diagrams/topologyDiagram.png
  mv "$DIAGRAM_FOLDER"/* ./reports/diagrams
else
   echo file does not exist or is not executable
fi
