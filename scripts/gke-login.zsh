# Login to all GKE clusters
function gke-login {
  currentContext=$(kubectl config current-context)
  allProjects=$(gcloud projects list --format=json | jq -c '.[] | { name: .name, id: .projectId }')

  gcloud projects list --format=json | jq -c '.[] | { name: .name, id: .projectId }' |  while read -r accountList; do
    projectId=$(echo ${accountList} | jq '.id'|  tr -d \")
    projectName=$(echo ${accountList} | jq '.name'|  tr -d \")
    clusterArray=$()

    echo && printf "\e[1m\e[32m$projectName \e[0m\n"
    gcloud container clusters list --project=$projectId --format=json | jq -c '.[] | { name: .name, zone: .zone }' | while read -r clusters; do
      clusterName=$(echo ${clusters} | jq '.name' | tr -d \")
      clusterZone=$(echo ${clusters} | jq '.zone' | tr -d \")

      echo $clusterName

      if [[ -n $(kubectl config view -o jsonpath='{.contexts[?(@.name == "'$clusterName'")]}') ]]
      then
        echo "cluster is there, skipping"
        continue
      fi

      gcloud container clusters get-credentials $clusterName --zone $clusterZone --project=$projectId

      currentCluster=$(kubectx -c)
      a=("${(@s/_/)currentCluster}")
      newName="$a[-1]"
      kubectx $newName=$currentCluster > /dev/null

    done

  done
  kubectl config use-context $currentContext > /dev/null
  echo ""
}
