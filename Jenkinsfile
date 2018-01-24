node('ng-runner') {
    checkout([
        $class: 'GitSCM',
        branches: [[name: '*/minio']],
        doGenerateSubmoduleConfigurations: false,
        extensions: [],
        submoduleCfg: [],
        userRemoteConfigs: [[
            credentialsId: 'c556c8d8-1fe0-47f4-94a5-d9e676915680',
            url: 'git@github.com:redBorder/repoinit.git']]
    ])
    sh "./build_module -m ${MODULE}"
}
