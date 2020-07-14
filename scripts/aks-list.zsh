# Get AKS clusters
function aks-list {
  az account list | jq -c '.[] | { name: .name,  id: .id }' |  while read -r accountList; do
    subName=$(echo ${accountList} | jq '.name'|  tr -d \")
    subId=$(echo ${accountList} | jq '.id'|  tr -d \")
    clusterList=$(az aks list --subscription $subId -o table)
    
    if [ ${#clusterList} -gt 0 ]
    then
      echo && printf "\e[1m\e[32m$subName ($subId)\e[0m\n"
      echo ${clusterList}
    fi
  done
  echo ""
}