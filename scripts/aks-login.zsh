# Login to all AKS clusters
function aks-login {
  currentContext=$(kubectl config current-context)
  myAccounts=$(az account list | jq -c '.[] | { name: .name,  id: .id }')
  
  for row in $(echo "${myAccounts}" | jq -r -c '. | @base64'); do
    decoded=$(echo ${row} | base64 --decode)
    subId=$(echo ${decoded} | jq '.id'|  tr -d \")
    subName=$(echo ${decoded} | jq '.name' | tr -d \")
    clusterArray=$(az aks list --subscription $subId | jq -c '.[] | { name: .name,  resourceGroup: .resourceGroup }')

    if [ ${#clusterArray} -gt 0 ]
    then
      echo && printf "\e[1m\e[32m$subName \e[0m\n"
      for cluster in $(echo "${clusterArray}" | jq -r -c '. | @base64'); do
        decoded=$(echo ${cluster} | base64 --decode)
        clusterName=$(echo ${decoded} | jq '.name' | tr -d \")
        resourceGroup=$(echo ${decoded} | jq '.resourceGroup' | tr -d \")

        echo $clusterName
        az aks get-credentials -n $clusterName -g $resourceGroup --subscription $subId --overwrite > /dev/null
      done
    fi

  done
  kubectl config use-context $currentContext > /dev/null
  echo ""
}