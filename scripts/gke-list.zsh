# Get GKE clusters
function gke-list {
  gcloud projects list --format=json | jq -c '.[] | { name: .name, id: .projectId }' |  while read -r accountList; do
    projectName=$(echo ${accountList} | jq '.name'|  tr -d \")
    projectId=$(echo ${accountList} | jq '.id'|  tr -d \")
    clusterList=$(gcloud container clusters list --project=$projectId)
    
    if [ ${#clusterList} -gt 0 ]
    then
      echo && printf "\e[1m\e[32m$projectName ($projectId)\e[0m\n"
      echo ${clusterList}
    fi
  done
  echo ""
}
