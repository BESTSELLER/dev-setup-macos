function config-clean {
  currentContext=$(kubectl config current-context)
  kubectl config-cleanup --raw > ~/.kube/kubeconfig-clean.yaml
  cp ~/.kube/config ~/.kube/config.old
  mv ~/.kube/kubeconfig-clean.yaml ~/.kube/config
  kubectl config use-context $currentContext > /dev/null
}
