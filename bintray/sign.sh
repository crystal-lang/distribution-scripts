#!/bin/sh
set -e

# # Environment
#
# - `$CRYSTAL_SIGNING_KEY` Path to the private signing key file
# - `$CRYSTAL_SIGNING_PASSPHRASE_FILE` Path to signing key passphrase
#
# # Steps
#
# ```
# ./sign.sh build
# ./sign.sh up
# ./sign.sh import-key-deb
# ./sign.sh import-key-rpm
# ./sign.sh sign-deb build/unsigned/crystal_[VERSION]-[ITERATION]_[ARCH].deb
#   # Output at build/signed/crystal_[VERSION]-[ITERATION]_[ARCH].deb
# ./sign.sh sign-rpm build/unsigned/crystal-[VERSION]-[ITERATION].[distro].[ARCH].rpm
#   # Output at build/signed/crystal-[VERSION]-[ITERATION].[distro].[ARCH].rpm
# ./sign.sh clean
# ```

function debian() {
  docker-compose exec debian /bin/sh -c "$@"
}

function centos() {
  docker-compose exec centos /bin/sh -c "$@"
}

case $1 in
  build)
    docker-compose build
    ;;

  up)
    docker-compose up ${@:2} &
    sleep 5
    ;;

  down)
    docker-compose down -v
    ;;

  clean)
    docker-compose down -v
    docker-compose rm
    ;;

  import-key-deb)
    cat $CRYSTAL_SIGNING_KEY | docker-compose exec -T debian gpg --import
    ;;

  import-key-rpm)
    cat $CRYSTAL_SIGNING_KEY | docker-compose exec -T centos gpg --import
    centos "gpg --export -a '7CC06B54' > /root/RPM-GPG-KEY-crystal"
    centos "rpm --import /root/RPM-GPG-KEY-crystal"
    ;;

  sign-deb)
    debian "mkdir -p /build/signed && cp /$2 /build/signed/$(basename $2)"
    docker cp $CRYSTAL_SIGNING_PASSPHRASE_FILE $(docker-compose ps -q debian):/tmp/passphrase_file
    debian "dpkg-sig --gpg-options '--passphrase-file /tmp/passphrase_file' --sign builder -m 7CC06B54 /build/signed/$(basename $2)"
    debian "dpkg-sig --verify /build/signed/$(basename $2)"
    ;;

  sign-rpm)
    centos "mkdir -p /build/signed && cp /$2 /build/signed/$(basename $2)"
    docker cp $CRYSTAL_SIGNING_PASSPHRASE_FILE $(docker-compose ps -q centos):/tmp/passphrase_file
    centos "/support/rpm-resign-unnatended.sh /build/signed/$(basename $2)"
    centos "rpm --checksig /build/signed/$(basename $2)"
    ;;

  skip-sign)
    mkdir -p build/signed
    cp $2 build/signed/$(basename $2)
    ;;

  *)
    echo "Invalid option"
    exit 1
    ;;
esac
