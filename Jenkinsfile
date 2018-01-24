node('ng-runner') {
    checkout([
        $class: 'GitSCM',
        branches: [[name: '*/minio']],
        doGenerateSubmoduleConfigurations: false,
        extensions: [],
        submoduleCfg: [],
        userRemoteConfigs: [[
            credentialsId: "${CREDENTIALS_ID}",
            url: 'git@github.com:redBorder/repoinit.git']]
    ])
    sh "./build_module.sh -m ${MODULE}"
}
