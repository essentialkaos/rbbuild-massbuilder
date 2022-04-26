#!/bin/bash

#######################################################################################

RBENV_DIR="/usr/local/rbenv"
CACHE_DIR="/root/rbbuild-cache"
VERSIONS_DIR="$RBENV_DIR/versions"
GLOBAL_RUBY_VER="2.7.5-p0"

COMPRESSION_VER=9
COMPRESSION_FULL=0

#######################################################################################

main() {
  case "$1" in
    "prepare" ) prepare && exit 0 ;;
    "check"   ) check && exit 0 ;;
    "pack"    ) pack && exit 0 ;;
    *         ) process "$@"
  esac
}

prepare() {
  yum -y install "https://yum.kaos.st/get/$(uname -r).rpm"

  # Clean metadata and cache
  yum clean all

  # Update system
  yum -y update

  # Install basic tools
  yum -y install epel-release rbenv rbinstall p7zip nano

  # Install unstable version of rbbuild
  yum -y --enablerepo=kaos-testing install rbbuild

  # Install tools required for build
  yum -y install autoconf git patch bison gcc gcc-c++ jre8 \
                 openssl-devel glibc-devel jemalloc-devel libffi-devel \
                 ncurses-devel readline-devel tk-devel zlib-devel

  rbinstall "$GLOBAL_RUBY_VER"

  echo "$GLOBAL_RUBY_VER" > /usr/local/rbenv/version

  echo -e "\n\nNow you should execute 'exec \$SHELL' command for rbenv init\n\n"
}

process() {
  local versions="$1"

  if [[ -z "$versions" || ! -f $versions || ! -s $versions ]] ; then
    echo "Usage: ./builder.sh versions-list-file"
    exit 1
  fi

  if ! rpm -q rbbuild &> /dev/null ; then
    echo "System is not configured yet. Run \"./builder.sh prepare\" before building rubies."
    exit 1
  fi

  build "$versions"
  separator
  check "$versions"
  separator
  pack "$versions"
}

build() {
  local versions="$1"

  while read -r version ; do
    if [[ "$version" == "$GLOBAL_RUBY_VER" || "${version}-p0" == "$GLOBAL_RUBY_VER" ]] ; then
      rm -rf "${VERSIONS_DIR:?}/$GLOBAL_RUBY_VER"
    fi

    [[ -z "$version" ]] && continue
    [[ -d "$VERSIONS_DIR/$version" ]] && continue

    echo -e "\n-- $version --"

    rbbuild "$version" -y -m essentialkaos -p "$(getPrefix "$version")" -dc "$CACHE_DIR"

  done < "$versions"
}

check() {
  for version in $(getBuiltVersions) ; do

    printf "%s → \n" "$(rbenv local "$version")"
    printf "  %s\n" "$(ruby -v)"
    printf "  %s\n" "$(ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION')"

  done
  
  rm -f .ruby-version &> /dev/null
}

pack() {
  local version os_version
  
  os_version=$(getOSVersion)

  pushd "$VERSIONS_DIR" &> /dev/null || exit 1

    for version in $(getBuiltVersions) ; do

      if [[ ! -e "$version" || -e "${version}.7z" ]] ; then
        continue
      fi

      if ! 7za -mx=$COMPRESSION_VER a "${version}.7z" "$version "&>/dev/null ; then
        echo "Can't pack $version"
      else
        echo "$version packed"
      fi

    done

    7za a -mx=$COMPRESSION_FULL "/root/ruby-c${os_version}.7z" ./*.7z

  popd &> /dev/null || exit 1
}

getBuiltVersions() {
  local version

  for version in $(find "$VERSIONS_DIR" -maxdepth 1 -type d | sort -n) ; do
    if [[ ! -e $version/bin/ruby ]] ; then
      continue
    fi

    basename "$version"
  done
}

getOSVersion() {
  if [[ $(uname -r | cut -c1) == "3" ]] ; then
    echo "7"
  fi
}

getPrefix() {
  local version

  if [[ $1 =~ ^(1|2|3)\.[0-9]+\.[0-9]+ ]] ; then
    if [[ $1 =~ \-p ]] ; then
      version="$1"
    else
      version=$(echo "$1" | sed -E 's/([1-3]+\.[0-9]+\.[0-9]+)/\1-p0/')
    fi
  else
    version="$1"
  fi

  echo "$VERSIONS_DIR/$version"
}

separator() {
  echo -e "\n--------------------------------------------------------------------------------\n"
}

#######################################################################################

main "$@"
