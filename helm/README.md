![Logo](https://helm.sh/img/helm.svg)

# blue-iac-helmfile

**official docs**

https://github.com/roboll/helmfile

**installation of helmfile**


>curl -fsSL -o helmfile https://github.com/roboll/helmfile/releases/download/v0.135.0/helmfile_<your-platform> when "your-platform" could be x86,amd64,arm64 etc.. 
chmod 700 helmfile
mv helmfile  /usr/local/bin
helm plugin install https://github.com/databus23/helm-diff --version v3.1.3 && \
helm plugin install https://github.com/futuresimple/helm-secrets && \
helm plugin install https://github.com/hypnoglow/helm-s3.git && \
helm plugin install https://github.com/aslafy-z/helm-git.git


**Use / common cases**

#### install charts (deploy release)

>helmfile apply

#### view diferences on release

>helmfile diff

#### refresh charmuseum repositories.

>helmfile repos
