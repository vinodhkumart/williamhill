#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
BUILD_DIR=${SCRIPT_DIR}/build
DOCKER_REG=${DOCKER_REG:-docker-artifactory.my}
DOCKER_USR=${DOCKER_USR:-admin}
DOCKER_PSW=${DOCKER_PSW:-password}
DOCKER_REPO=${DOCKER_REPO:-vinodh141}
DOCKER_TAG=${DOCKER_TAG:-dev}

errorExit () {
    echo -e "\nERROR: $1"; echo
    exit 1
}

usage () {
    cat << END_USAGE

${SCRIPT_NAME} - Script for building the  web application and Docker image

Usage: ./${SCRIPT_NAME} <options>

--build             : [optional] Build the Docker image
--push              : [optional] Push the Docker image
--registry reg      : [optional] A custom docker registry
--docker_usr user   : [optional] Docker registry username
--docker_psw pass   : [optional] Docker registry password
--tag tag           : [optional] A custom app version


-h | --help         : Show this usage

END_USAGE

    exit 1
}

# Docker login
dockerLogin () {
    echo -e "\nDocker login"

    if [ ! -z "${DOCKER_REG}" ]; then
        # Make sure credentials are set
        if [ -z "${DOCKER_USR}" ] || [ -z "${DOCKER_PSW}" ]; then
            errorExit "Docker credentials not set (DOCKER_USR and DOCKER_PSW)"
        fi

        docker login ${DOCKER_REG} -u ${DOCKER_USR} -p ${DOCKER_PSW} || errorExit "Docker login to ${DOCKER_REG} failed"
    else
        echo "Docker registry not set. Skipping"
    fi
}

# Build Docker images
buildDockerImage () {
    echo -e "\nBuilding ${DOCKER_REPO}:${DOCKER_TAG}"

    # Prepare build directory
    echo -e "\nPreparing files"
    mkdir -p ${BUILD_DIR}/site
    cp -v  ${SCRIPT_DIR}/docker/Dockerfile ${BUILD_DIR}
    cp -rv ${SCRIPT_DIR}/src/* ${BUILD_DIR}/site/

    # Embed the app version
    echo -e "\nWriting version ${DOCKER_TAG} to files"
    sed -i.org "s/__APP_VERSION__/${DOCKER_TAG}/g" ${BUILD_DIR}/site/*.html
    rm -f ${BUILD_DIR}/site/*.org

    echo -e "\nBuilding Docker image"
    docker build -t ${DOCKER_REG}/${DOCKER_REPO}:${DOCKER_TAG} ${BUILD_DIR} || errorExit "Building ${DOCKER_REPO}:${DOCKER_TAG} failed"
}

# Push Docker images
pushDockerImage () {
    echo -e "\nPushing ${DOCKER_REPO}:${DOCKER_TAG}"

    docker push ${DOCKER_REG}/${DOCKER_REPO}:${DOCKER_TAG} || errorExit "Pushing ${DOCKER_REPO}:${DOCKER_TAG} failed"
}

# Process command line options. See usage above for supported options
processOptions () {
    if [ $# -eq 0 ]; then
        usage
    fi

    while [[ $# > 0 ]]; do
        case "$1" in
            --build)
                BUILD="true"; shift
            ;;
            --push)
                PUSH="true"; shift
            ;;
            --registry)
                DOCKER_REG=${2}; shift 2
            ;;
            --docker_usr)
                DOCKER_USR=${2}; shift 2
            ;;
            --docker_psw)
                DOCKER_PSW=${2}; shift 2
            ;;
            --tag)
                DOCKER_TAG=${2}; shift 2
            ;;
            -h | --help)
                usage
            ;;
            *)
                usage
            ;;
        esac
    done
}

main () {
    echo -e "\nRunning"

    echo "DOCKER_REG:   ${DOCKER_REG}"
    echo "DOCKER_USR:   ${DOCKER_USR}"
    echo "DOCKER_REPO:  ${DOCKER_REPO}"
    echo "DOCKER_TAG:   ${DOCKER_TAG}"

    # Cleanup
    rm -rf ${BUILD_DIR}

    # Build and push docker images if needed
    if [ "${BUILD}" == "true" ]; then
        buildDockerImage
    fi
    if [ "${PUSH}" == "true" ]; then
        # Attempt docker login
        dockerLogin
        pushDockerImage
    fi

############## Main
processOptions $*
main

