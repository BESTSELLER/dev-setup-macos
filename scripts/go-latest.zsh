# GET GO VERSION
function go-latest {
  url="$(wget -qO- https://golang.org/dl/ | grep -oE 'https:\/\/dl\.google\.com\/go\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )"
  latest="$(echo $url | grep -oE 'go[0-9\.]+' | grep -oE '[0-9\.]+')"
  echo "Latest Go for AMD64: ${latest}"
}