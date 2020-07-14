# Login to all GKE clusters
function gke-login {
  currentContext=$(kubectl config current-context)
  allProjects=$(gcloud projects list --format=json | jq -c '.[] | { name: .name, id: .projectId }')
  
  for row in $(echo "${allProjects}" | jq -r -c '. | @base64'); do
    decoded=$(echo ${row} | base64 --decode)
    projectId=$(echo ${decoded} | jq '.id'|  tr -d \")
    projectName=$(echo ${decoded} | jq '.name' | tr -d \")
    clusterArray=$(gcloud container clusters list --project=$projectId --format=json | jq -c '.[] | { name: .name, zone: .zone }')


    if [ ${#clusterArray} -gt 0 ]
    then
      echo && printf "\e[1m\e[32m$projectName \e[0m\n"
      for cluster in $(echo "${clusterArray}" | jq -r -c '. | @base64'); do
        decoded=$(echo ${cluster} | base64 --decode)
        clusterName=$(echo ${decoded} | jq '.name' | tr -d \")
        clusterZone=$(echo ${decoded} | jq '.zone' | tr -d \")

        echo $clusterName

        gcloud container clusters get-credentials $clusterName --zone $clusterZone --project=$projectId
        
        currentCluster=$(kubectx -c)
        a=("${(@s/_/)currentCluster}")
        newName="$a[-1]"
        kubectx $newName=$currentCluster > /dev/null

      done
    fi

  done
  kubectl config use-context $currentContext > /dev/null
  echo ""
}
