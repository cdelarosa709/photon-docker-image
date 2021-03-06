#!/bin/bash
set -e

versions="2.0 1.0"

self="$(basename "$BASH_SOURCE")"

# get the most recent commit which modified any of "$@"
fileCommit() {
  git log -1 --format='format:%H' HEAD -- "$@"
}

aarch64_branch() {
  version=$1
  x86_64branchLine=$(git ls-remote --heads origin x86_64\/$version\* | sort -r -k2 | head -n1)
  x86_64branch=${x86_64branchLine: -12}
  x86_64commit=${x86_64branchLine:0:40}
  aarch64branchLine=$(git ls-remote --heads origin aarch64\/$version\* | sort -r -k2 | head -n1)
  aarch64branch=${aarch64branchLine: -12}
  aarch64commit=${aarch64branchLine:0:40}
  if [ -n "$x86_64branch" -a -n "$aarch64branch" ] ; then
    test "$x86_64branch" \> "$aarch64branch" && tag=$x86_64branch || tag=$aarch64branch
    echo >> photon
    echo "Tags: $version, $tag" >> photon
    echo "Architectures: amd64, arm64v8" >> photon
    echo "GitFetch: refs/heads/x86_64/$x86_64branch" >> photon
    echo "GitCommit: $x86_64commit" >> photon
    echo "arm64v8-GitFetch: refs/heads/aarch64/$aarch64branch" >> photon
    echo "arm64v8-GitCommit: $aarch64commit" >> photon
  fi
}

cat > photon << EOF
# this file is generated via https://github.com/vmware/photon-docker-image/blob/$(fileCommit "$self")/$self
Maintainers: Fabio Rapposelli <fabio@vmware.com> (@frapposelli),
             Alexey Makhalov <amakhalov@vmware.com> (@YustasSwamp)
GitRepo: https://github.com/vmware/photon-docker-image.git
Directory: docker
EOF

latestTag=", latest"

for version in $versions ; do
  branchLine=$(git ls-remote --heads origin $version\* | sort -r -k2 | head -n1)
  branch=${branchLine: -12}
  commit=${branchLine:0:40}
  echo >> photon
  echo "Tags: $version, $branch$latestTag" >> photon
  echo "GitFetch: refs/heads/$branch" >> photon
  echo "GitCommit: $commit" >> photon
  latestTag=""
done

# dev branch handling
aarch64_branch "dev"

# 3.0- branch handling
aarch64_branch "3.0"
